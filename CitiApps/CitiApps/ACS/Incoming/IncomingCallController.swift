//
//  IncomingCallController.swift
//  CitiApps
//
//  Created by Balaji Babu Modugumudi on 20/04/23.
//

import Foundation
import AzureCommunicationCalling
import AVFoundation


class IncomingCallController {
    
    var callAgent:CallAgent?
    var callClient:CallClient?
    var deviceManager: DeviceManager?

    
    func resigterIncomingCallClient(){
        
        let incomingCallHandler = IncomingCallHandler.getOrCreateInstance()

        var userCredential: CommunicationTokenCredential?
        do {
            userCredential = try CommunicationTokenCredential(token: "eyJhbGciOiJSUzI1NiIsImtpZCI6IjEwNiIsIng1dCI6Im9QMWFxQnlfR3hZU3pSaXhuQ25zdE5PU2p2cyIsInR5cCI6IkpXVCJ9.eyJza3lwZWlkIjoiYWNzOjY0YTM4ZDUyLTMzZmItNDQwNy1hOGZhLWNiMzI3ZWZkZjdkNV8wMDAwMDAxOC00MmQ5LTRkZTItZTE2Ny01NjNhMGQwMDFhY2MiLCJzY3AiOjE3OTIsImNzaSI6IjE2ODIwNjYzNTIiLCJleHAiOjE2ODIxNTI3NTIsInJnbiI6ImFtZXIiLCJhY3NTY29wZSI6InZvaXAsY2hhdCIsInJlc291cmNlSWQiOiI2NGEzOGQ1Mi0zM2ZiLTQ0MDctYThmYS1jYjMyN2VmZGY3ZDUiLCJyZXNvdXJjZUxvY2F0aW9uIjoidW5pdGVkc3RhdGVzIiwiaWF0IjoxNjgyMDY2MzUyfQ.IzkAbAZ9m-mysuOH1v6x1dpwKv8sBi5S_bTpB6bcCD5D-VPjf-14poTZ-sEmbz_-3l0k2AxEHmpwE--tSkGcRR3Jdy19XZYxTn_V99QkVyDlgplkjyyhXh8gmFQbzsrQHRfDP-wIy6pKjSu6xrqiVETEijUyej5Zt8F_muHbQ1xcaJQz-3aNyDHxz4rUFbcv6dRtnYtRrSdvijXzZw6dBBfILwrCm4B2gJNacKvACwMWzTsUBLbCkPuS2Ik2RccpIlAAggCDGAZasMIcme8NMmT3JTYr1-PyiXUNIWouikcYtwMKykSTLJtufCi1D_AiLKV-xtQW2WrfPUPWgle25g")
        } catch {
            print("ERROR: It was not possible to create user credential.")
            return
        }
        
        self.callClient = CallClient()
        self.callClient?.createCallAgent(userCredential: userCredential!) { (agent, error) in
            if error != nil {
                print("ERROR: It was not possible to create a call agent.")
                return
            }
            else {
                self.callAgent = agent
                print("-------------Call agent successfully created.---------")
                self.callAgent!.delegate = incomingCallHandler
                
                self.callClient?.getDeviceManager { (deviceManager, error) in
                    if (error == nil) {
                        print("Got device manager instance")
                        self.deviceManager = deviceManager
                        AVAudioSession.sharedInstance().requestRecordPermission { (granted) in
                            if granted {
                                print("granted")
                                print(granted)
                                AVCaptureDevice.requestAccess(for: .video) { (videoGranted) in
                                    /* NO OPERATION */
                                    print(videoGranted)
                                    print("videoGranted")
                                }
                            }
                            else{
                                print("requestRecordPermission")
                            }
                        }
                    } else {
                        print("Failed to get device manager instance")
                    }
                }
            }
        }
    }
}

final class IncomingCallHandler: NSObject, CallAgentDelegate, IncomingCallDelegate, CallDelegate {
    public var contentView: ContentView?
    private var incomingCall: IncomingCall?

    private static var instance: IncomingCallHandler?
    static func getOrCreateInstance() -> IncomingCallHandler {
        if let c = instance {
            return c
        }
        instance = IncomingCallHandler()
        return instance!
    }

    private override init() {}
    
    
    func call(_ call: Call, didChangeState args: PropertyChangedEventArgs) {
        print(call.state)
    }
    
    public func callAgent(_ callAgent: CallAgent, didRecieveIncomingCall incomingCall: IncomingCall) {
        print("didRecieveIncomingCall")
        self.incomingCall = incomingCall
        self.incomingCall?.delegate = self
//        contentView?.showIncomingCallBanner(self.incomingCall!)
    }
    
    public func callAgent(_ callAgent: CallAgent, didUpdateCalls args: CallsUpdatedEventArgs) {
        print("didUpdateCalls")
        if let removedCall = args.removedCalls.first {
//            contentView?.callRemoved(removedCall)
            self.incomingCall = nil
        }
    }
}
