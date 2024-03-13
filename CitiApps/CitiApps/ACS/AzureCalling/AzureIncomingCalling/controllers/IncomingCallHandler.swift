//
//  IncomingCallHandler.swift
//  CitiApps
//
//  Created by Balaji Babu Modugumudi on 09/08/23.
//

import Foundation
import AzureCommunicationCalling
import AVFoundation
import SwiftUI
import PIPKit

final class IncomingCallHandler: NSObject, CallAgentDelegate, IncomingCallDelegate {
    public var contentView: IncomingCallView?
    private var incomingCall: IncomingCall?

    init(contentView: IncomingCallView?) {
        self.contentView = contentView
    }

    public func callAgent(_ callAgent: CallAgent, didRecieveIncomingCall incomingCall: IncomingCall) {
        
        self.incomingCall = incomingCall
        self.incomingCall!.delegate = self
        
        contentView?.showIncomingCallBanner(self.incomingCall!)
        // If there is no CallKitHelper exit
        guard let callKitHelper =  CallKitObjectManager.getCallKitHelper() else {
            return
        }
        Task {
            await CallKitObjectManager.getCallKitHelper()?.addIncomingCall(incomingCall: self.incomingCall!)
        }
        let incomingCallReporter = CallKitIncomingCallReporter()
        incomingCallReporter.reportIncomingCall(callId: self.incomingCall!.id,
                                               callerInfo: self.incomingCall!.callerInfo,
                                               videoEnabled: self.incomingCall!.isVideoEnabled,
                                               completionHandler: { error in
            if error == nil {
                print("Incoming call was reportd successfully")
            } else {
                print("Incoming call was not reported successfully")
            }
        })
    }

    func incomingCall(_ incomingCall: IncomingCall, didEnd args: PropertyChangedEventArgs) {
        self.incomingCall = nil
        Task {
            await CallKitObjectManager.getCallKitHelper()?.removeIncomingCall(callId: incomingCall.id)
        }
        PIPKit.dismiss(animated: true)
        self.contentView = nil
    }
    
    
    func callAgent(_ callAgent: CallAgent, didUpdateCalls args: CallsUpdatedEventArgs) {
        if let removedCall = args.removedCalls.first {
            print("didUpdateCalls")
            contentView?.callRemoved(removedCall)
            self.incomingCall = nil
            PIPKit.dismiss(animated: true)
            self.contentView = nil
        }

        if let addedCall = args.addedCalls.first {
            // This happens when call was accepted via CallKit and not from the app
            // We need to set the call instances and auto-navigate to call in progress screen.
            if addedCall.direction == .incoming {
                contentView?.setCallAndObersever(call: addedCall, error: nil)
            }
        }
    }
}
