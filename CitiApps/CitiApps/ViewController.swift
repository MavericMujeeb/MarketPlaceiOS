//
//  HomeViewController.swift
//  in_view
//
//  Created by Balaji Babu Modugumudi on 17/10/22.
//

var users = [
    "janetjohnsonfamily83@gmail.com": ["name":"Janet Johnson","email":"janetjohnsonfamily83@gmail.com","userid":"a2194b29-07bb-48bb-8607-6151334cf904"],
    "johnwilliamsfamily9@gmail.com": ["name":"Johnson williams","email":"johnwilliamsfamily9@gmail.com","userid":"8294e32a-d846-440d-b875-87b171b80787"],
]

var loggedInUser : String!
var loginDate : NSDate!
var userid : String!


import UIKit
import FluentUI
import Flutter
import PIPKit

import AzureCommunicationCalling
import AVFoundation

class CallHandler: NSObject, CallDelegate, CallAgentDelegate {
    
    private static var instance: CallHandler?
    static func getOrCreateInstance() -> CallHandler {
        if let c = instance {
          return c
        }
        instance = CallHandler()
        return instance!
    }
    
    public func call(_ call: Call, didChangeState args: PropertyChangedEventArgs) {
        print("didChangeState")
        print("state")
        print(call.state)
    }
    

    func callAgent(_ callAgent: CallAgent, didUpdateCalls args: CallsUpdatedEventArgs) {
        print(callAgent)
        print("callAgent ---------- ")
    }
}


class ViewController : UIViewController {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var forgotPasswordLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordRevealer: UIButton!
    
    @IBAction func revealPassword(_ sender: Any) {
        password.togglePasswordVisibility()
    }
    
    var handleExternalLinks: Bool!
    var meetingLink : String!
    
    //Added for testing purpose
    var callClient: CallClient?
    var callAgent: CallAgent?
    
    //Added for testing purpose
    func makeCallToClient(){
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
                let callHandler = CallHandler.getOrCreateInstance()
                self.callAgent?.delegate = callHandler
                
                print("Call agent successfully created.")
                self.callClient?.getDeviceManager { (deviceManager, error) in
                    if (error == nil) {
                        let callees:[CommunicationIdentifier] = [CommunicationUserIdentifier("8:acs:64a38d52-33fb-4407-a8fa-cb327efdf7d5_00000017-c35a-58a8-bcc9-3e3a0d008f97")]
                        print("startCall")
                        self.callAgent?.startCall(participants: callees, options: StartCallOptions()) { (call, error) in
                            print("ACS call ---- ")
                            print(call ?? "Call empty")
                            print("ACS call ---- ")
                        }
                        
                    } else {
                        print("Failed to get device manager instance")
                    }
                }
            }
        }
    }
    let storageUserDefaults = UserDefaults.standard
    
    @IBAction func onLoginAction(_ sender: Any) {
        //Added for testing purpose
//        makeCallToClient()
//        return
        if(self.username.text == "" || self.password.text == "") {
            return
        }
        if(users[self.username.text!]?["name"] == nil) {
            let alert = UIAlertController(title: "User not found", message: "Please enter valid user credentials", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                switch action.style{
                    case .default:
                    self.dismiss(animated: true)
                    case .cancel:
                    self.dismiss(animated: true)
                    
                    case .destructive:
                    self.dismiss(animated: true)
                    
                @unknown default:
                    self.dismiss(animated: true)
                }
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        //TODO:Setting this info globally, might change it later.
        loggedInUser = self.username.text
        userid = users[self.username.text!]?["userid"]
        storageUserDefaults.set(users[self.username.text!]?["name"], forKey: StorageKeys.loginUserName)
        var userInfo = UserInfoData(name: users[self.username.text!]?["name"], email: users[self.username.text!]?["email"], id: users[self.username.text!]?["userid"])
        var data = try! JSONEncoder().encode(userInfo)
        var userStr = String(data: data, encoding: .utf8)
        flutterMethodChannel(passArgs: userStr);
        
        if(handleExternalLinks == true){
//            let teamsCallingViewController = TeamsCallingViewController()
//            teamsCallingViewController.teamsLink = self.meetingLink
//            teamsCallingViewController.startCall()
            
            let dashViewController = DashboardViewController(nibName: nil, bundle: nil)
            dashViewController.handleExternalLinks = true
            dashViewController.meetingLink = self.meetingLink
            self.navigationController?.pushViewController(dashViewController, animated: false)
        }
        else{
            let dashViewController = DashboardViewController(nibName: nil, bundle: nil)
            self.navigationController?.pushViewController(dashViewController, animated: false)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        username.resignFirstResponder()
        password.resignFirstResponder()
        return true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if(handleExternalLinks == true) {
            handleExternalLinks = false
            meetingLink=""
        }
    }
    
    
    func customizeNavBar(){
        let logoImageView = UIImageView.init()
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.contentMode =  UIView.ContentMode.scaleAspectFit
            
        let logoBarButtonItem = UIBarButtonItem.init(customView: logoImageView);
        
        let width = self.view.frame.size.width * 0.3;
        let height = width * 178/794;
        
        logoImageView.widthAnchor.constraint(equalToConstant: width).isActive = true;
        logoImageView.heightAnchor.constraint(equalToConstant: height).isActive = true;
        
  
        self.navigationController?.navigationBar.topItem?.leftBarButtonItem = logoBarButtonItem;
        
//        let trailingButton = UIBarButtonItem.init(customView: UIImageView(image: UIImage(systemName: "line.horizontal.3")))
//
//        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = trailingButton;
    }
    
    func customizeTextFields(){
        username.delegate = self
        password.delegate = self
        
        username.customize()
        password.customize()

        password.isSecureTextEntry = true
        
        username.text = "janetjohnsonfamily83@gmail.com"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        customizeNavBar()
        customizeTextFields()
        
    }
    
    func flutterMethodChannel (passArgs: String?) {
        let flutterEngine = (UIApplication.shared.delegate as! AppDelegate).flutterEngine
        let controller : FlutterViewController = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)

        
        let acsChannel = FlutterMethodChannel(
            name: CitiConstants.method_channel_name,
            binaryMessenger: controller.binaryMessenger
        )
        
        acsChannel.invokeMethod("loginUserDetails", arguments: passArgs)
    }
}

extension ViewController : UITextFieldDelegate{}

extension UITextField {
    
    func customize(){
        self.spellCheckingType = .no
        self.autocorrectionType = .no
        self.autocapitalizationType = .none
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 10
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.setLeftPaddingPoints(20)
        self.setRightPaddingPoints(20)
    }
    
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    
    func togglePasswordVisibility() {
            isSecureTextEntry = !isSecureTextEntry

            if let existingText = text, isSecureTextEntry {
                /* When toggling to secure text, all text will be purged if the user
                 continues typing unless we intervene. This is prevented by first
                 deleting the existing text and then recovering the original text. */
                deleteBackward()

                if let textRange = textRange(from: beginningOfDocument, to: endOfDocument) {
                    replace(textRange, withText: existingText)
                }
            }

            /* Reset the selected text range since the cursor can end up in the wrong
             position after a toggle because the text might vary in width */
            if let existingSelectedTextRange = selectedTextRange {
                selectedTextRange = nil
                selectedTextRange = existingSelectedTextRange
            }
        }
}
