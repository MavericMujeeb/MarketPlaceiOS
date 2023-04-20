//
//  IncomingCallController.swift
//  CitiApps
//
//  Created by Balaji Babu Modugumudi on 20/04/23.
//

import Foundation
import AzureCommunicationCalling

class IncomingCallController {
    
    var callAgent:CallAgent?
    var callClient:CallClient?
    var deviceManager: DeviceManager?

    
    func resigterIncomingCallClient(){
        self.callClient = CallClient()
        let incomingCallHandler = IncomingCallHandler.getOrCreateInstance()

        var userCredential: CommunicationTokenCredential?
        do {
            userCredential = try CommunicationTokenCredential(token: "eyJhbGciOiJSUzI1NiIsImtpZCI6IjEwNiIsIng1dCI6Im9QMWFxQnlfR3hZU3pSaXhuQ25zdE5PU2p2cyIsInR5cCI6IkpXVCJ9.eyJza3lwZWlkIjoiYWNzOjY0YTM4ZDUyLTMzZmItNDQwNy1hOGZhLWNiMzI3ZWZkZjdkNV8wMDAwMDAxOC0zZTE2LWU3YjItODBmNS04YjNhMGQwMDU3ZTciLCJzY3AiOjE3OTIsImNzaSI6IjE2ODE5ODY1MDMiLCJleHAiOjE2ODIwNzI5MDMsInJnbiI6ImFtZXIiLCJhY3NTY29wZSI6InZvaXAsY2hhdCIsInJlc291cmNlSWQiOiI2NGEzOGQ1Mi0zM2ZiLTQ0MDctYThmYS1jYjMyN2VmZGY3ZDUiLCJyZXNvdXJjZUxvY2F0aW9uIjoidW5pdGVkc3RhdGVzIiwiaWF0IjoxNjgxOTg2NTAzfQ.Ex7gzBu9_tASSO4gBUwC4QJ70J3hUEfy6SvJ5LG323P0NImuQM1XwnSWGykWHO1YX2cnVEOMzy38Vp_eMv57EkoSur3T4abbvQPqheLpYch-B7BkOUQpEDnraWZl4sUE8xbCyHi05OtMAJFcWRbmEUnWYNMJAe3sZ9Yy1BPaZf_yJJDh5BbfgchoRBt4ambKnqamzwKN8RJO3j_0BA7_F5NnZlENeuyF1zxOwPWTl9HL0HWLu7LGxz0UkYngcVvWFvELViaS-3VN0N30tg4VuYLhrV70IrmwTdVvPYZiNOgQN3cwVidzhFurl888Ee-dmkBLCw-Ukitj5nw1CJo-ug")
        } catch {
            print("ERROR: It was not possible to create user credential.")
            return
        }
        
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
                    } else {
                        print("Failed to get device manager instance")
                    }
                }
            }
        }
    }
}

final class IncomingCallHandler: NSObject, CallAgentDelegate, IncomingCallDelegate {
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
