//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCalling
import Foundation
import Combine

class CallingSDKEventsHandler: NSObject, CallingSDKEventsHandling {
    var participantsInfoListSubject: CurrentValueSubject<[ParticipantInfoModel], Never> = .init([])
    var callInfoSubject = PassthroughSubject<CallInfoModel, Never>()
    var isRecordingActiveSubject = PassthroughSubject<Bool, Never>()
    var isTranscriptionActiveSubject = PassthroughSubject<Bool, Never>()
    var isLocalUserMutedSubject = PassthroughSubject<Bool, Never>()

    private let logger: Logger
    private var remoteParticipantEventAdapter = RemoteParticipantsEventsAdapter()
    private var recordingCallFeature: RecordingCallFeature?
    private var transcriptionCallFeature: TranscriptionCallFeature?
    private var previousCallingStatus: CallingStatus = .none
    private var remoteParticipants = MappedSequence<String, AzureCommunicationCalling.RemoteParticipant>()

    var acsParticipantsIds: Set<String> = []

    
    init(logger: Logger) {
        self.logger = logger
        super.init()
        setupRemoteParticipantEventsAdapter()
    }

    func assign(_ recordingCallFeature: RecordingCallFeature) {
        self.recordingCallFeature = recordingCallFeature
        recordingCallFeature.delegate = self
    }

    func assign(_ transcriptionCallFeature: TranscriptionCallFeature) {
        self.transcriptionCallFeature = transcriptionCallFeature
        transcriptionCallFeature.delegate = self
    }

    func setupProperties() {
        participantsInfoListSubject.value.removeAll()
        recordingCallFeature = nil
        transcriptionCallFeature = nil
        remoteParticipants = MappedSequence<String, AzureCommunicationCalling.RemoteParticipant>()
        previousCallingStatus = .none
    }

    private func setupRemoteParticipantEventsAdapter() {
        let participantUpdate: ((AzureCommunicationCalling.RemoteParticipant)
                                -> Void) = { [weak self] remoteParticipant in
            guard let self = self,
                  let userIdentifier = remoteParticipant.identifier.stringValue else {
                return
            }
            self.updateRemoteParticipant(userIdentifier: userIdentifier, updateSpeakingStamp: false)
        }

        remoteParticipantEventAdapter.onIsMutedChanged = participantUpdate
        remoteParticipantEventAdapter.onVideoStreamsUpdated = participantUpdate
        remoteParticipantEventAdapter.onStateChanged = participantUpdate

        remoteParticipantEventAdapter.onIsSpeakingChanged = { [weak self] remoteParticipant in
            guard let self = self,
                  let userIdentifier = remoteParticipant.identifier.stringValue else {
                return
            }
            let updateSpeakingStamp = remoteParticipant.isSpeaking
            self.updateRemoteParticipant(userIdentifier: userIdentifier, updateSpeakingStamp: updateSpeakingStamp)
        }
    }

    private func removeRemoteParticipants(
        _ remoteParticipants: [AzureCommunicationCalling.RemoteParticipant]
    ) {
        for participant in remoteParticipants {
            if let userIdentifier = participant.identifier.stringValue {
                self.remoteParticipants.removeValue(forKey: userIdentifier)?.delegate = nil
            }
        }
        removeRemoteParticipantsInfoModel(remoteParticipants)
    }

    private func removeRemoteParticipantsInfoModel(
        _ remoteParticipants: [AzureCommunicationCalling.RemoteParticipant]
    ) {
        guard !remoteParticipants.isEmpty
        else { return }

        var remoteParticipantsInfoList = participantsInfoListSubject.value
        remoteParticipantsInfoList =
            remoteParticipantsInfoList.filter { infoModel in
                !remoteParticipants.contains(where: {
                    $0.identifier.stringValue == infoModel.userIdentifier
                })
            }
        participantsInfoListSubject.send(remoteParticipantsInfoList)
    }

    private func addRemoteParticipants(
        _ remoteParticipants: [AzureCommunicationCalling.RemoteParticipant]
    ) {
        for participant in remoteParticipants {
            if let userIdentifier = participant.identifier.stringValue {
                participant.delegate = remoteParticipantEventAdapter
                self.remoteParticipants.append(forKey: userIdentifier, value: participant)
            }
        }
        addRemoteParticipantsInfoModel(remoteParticipants)
    }

    private func addRemoteParticipantsInfoModel(
        _ remoteParticipants: [AzureCommunicationCalling.RemoteParticipant]
    ) {
        guard !remoteParticipants.isEmpty
        else { return }

        var remoteParticipantsInfoList = participantsInfoListSubject.value
        remoteParticipants.forEach {
            let infoModel = $0.toParticipantInfoModel(recentSpeakingStamp: Date(timeIntervalSince1970: 0))
            remoteParticipantsInfoList.append(infoModel)
        }
        participantsInfoListSubject.send(remoteParticipantsInfoList)
    }

    private func updateRemoteParticipant(userIdentifier: String,
                                         updateSpeakingStamp: Bool) {
        var remoteParticipantsInfoList = participantsInfoListSubject.value
        if let remoteParticipant = remoteParticipants.value(forKey: userIdentifier),
           let index = remoteParticipantsInfoList.firstIndex(where: {
               $0.userIdentifier == userIdentifier
           }) {
            let speakingStamp = remoteParticipantsInfoList[index].recentSpeakingStamp
            let timeStamp = updateSpeakingStamp ? Date() : speakingStamp
            let newInfoModel = remoteParticipant.toParticipantInfoModel(recentSpeakingStamp: timeStamp)
            remoteParticipantsInfoList[index] = newInfoModel

            participantsInfoListSubject.send(remoteParticipantsInfoList)
        }
    }

    private func wasCallConnected() -> Bool {
        return previousCallingStatus == .connected ||
              previousCallingStatus == .localHold ||
              previousCallingStatus == .remoteHold
    }
}

extension CallingSDKEventsHandler: CallDelegate, IncomingCallDelegate,
    RecordingCallFeatureDelegate,
    TranscriptionCallFeatureDelegate {
        
    func call(_ call: Call, didUpdateRemoteParticipant args: ParticipantsUpdatedEventArgs) {
        if !args.removedParticipants.isEmpty {
            removeRemoteParticipants(args.removedParticipants)
        }
        if !args.addedParticipants.isEmpty {
            addRemoteParticipants(args.addedParticipants)
        }
    }
    
    //Event raised when there is an incoming call
    public func callAgent(_ callAgent: CallAgent, didRecieveIncomingCall incomingCall: IncomingCall) {
        print("didRecieveIncomingCall")
        
        incomingCall.accept(options: AcceptCallOptions()) { (call, error) in
           if (error == nil) {
               print("Successfully accepted incoming call")
           } else {
               print("Failed to accept incoming call")
           }
        }
    }

    //Event raised when incoming call was not answered
    public func incomingCall(_ incomingCall: IncomingCall, didEnd args: PropertyChangedEventArgs) {
       print("Incoming call was not answered")
    }


    func call(_ call: Call, didChangeState args: PropertyChangedEventArgs) {
        
        for participant in call.remoteParticipants {
            if(!self.acsParticipantsIds.contains(participant.identifier.rawId)){
                self.acsParticipantsIds.insert(participant.identifier.rawId)
                addRemoteParticipants([participant])
            }
        }
        
        let currentStatus = call.state.toCallingStatus()
        
        if(currentStatus == .connected || currentStatus == .ringing) {
            CallLogs.callStartTime = Date().timeIntervalSince1970
        }
        
        if(currentStatus == .disconnected && (previousCallingStatus == .connected || previousCallingStatus == .ringing)) {
            CallLogs.callEndTime = Date().timeIntervalSince1970
            let storageUserDefaults = UserDefaults.standard
            let bankerAcsId = storageUserDefaults.string(forKey: "bankerAcsId")!
            let bankerUserName = storageUserDefaults.string(forKey: "bankerUserName")!
            let bankerUserEmail = storageUserDefaults.string(forKey: "bankerUserEmail")!
            let customerAcsId = storageUserDefaults.string(forKey: "customerAcsId")!
            let customerUserName = storageUserDefaults.string(forKey: "customerUserName")!
            let customerUserEmail = storageUserDefaults.string(forKey: "customerUserEmail")!
            let callType:String = previousCallingStatus == .connected ? "incoming" : "missed"
            let startTime:String = CallLogs.callStartTime.removeDecimalValue
            let endTime:String = previousCallingStatus == .connected ? CallLogs.callEndTime.removeDecimalValue : "0"
            
            CallLogs.logCallsHistory(callername: bankerUserName, calleremail: bankerUserEmail, calleracsid: bankerAcsId, calleename: customerUserName, calleeemail: customerUserEmail, calleeacsid: customerAcsId, callType: callType, startTime: startTime, endTime: endTime)
        }
        
        let internalError = call.callEndReason.toCompositeInternalError(wasCallConnected())

        if internalError != nil {
            let code = call.callEndReason.code
            let subcode = call.callEndReason.subcode
            logger.error("Receive vaildate CallEndReason:\(code), subcode:\(subcode)")
        }
        let callInfoModel = CallInfoModel(status: currentStatus,
                                          internalError: internalError)
        callInfoSubject.send(callInfoModel)
        self.previousCallingStatus = currentStatus
    }

    func recordingCallFeature(_ recordingCallFeature: RecordingCallFeature,
                              didChangeRecordingState args: PropertyChangedEventArgs) {
        let newRecordingActive = recordingCallFeature.isRecordingActive
        isRecordingActiveSubject.send(newRecordingActive)
    }

    func transcriptionCallFeature(_ transcriptionCallFeature: TranscriptionCallFeature,
                                  didChangeTranscriptionState args: PropertyChangedEventArgs) {
        let newTranscriptionActive = transcriptionCallFeature.isTranscriptionActive
        isTranscriptionActiveSubject.send(newTranscriptionActive)
    }

    func call(_ call: Call, didChangeMuteState args: PropertyChangedEventArgs) {
        isLocalUserMutedSubject.send(call.isMuted)
    }

}
