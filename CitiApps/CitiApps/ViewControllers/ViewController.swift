//
//  HomeViewController.swift
//  in_view
//
//  Created by Balaji Babu Modugumudi on 17/10/22.
//

var users = [
    "veronicastephens838@gmail.com": ["name":"Veronica Stephens","email":"veronicastephens838@gmail.com","userid":"fc123292-abe0-4629-982e-1cfe16759cbb"],
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
import SwiftUI

class LoginViewController : UIViewController {
    
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
    let storageUserDefaults = UserDefaults.standard

    @IBAction func onLoginAction(_ sender: Any) {
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
        let userInfo = UserInfoData(name: users[self.username.text!]?["name"], email: users[self.username.text!]?["email"], id: users[self.username.text!]?["userid"])
        let data = try! JSONEncoder().encode(userInfo)
        let userStr = String(data: data, encoding: .utf8)
        flutterMethodChannel(passArgs: userStr);
        
        //set acs hardcode values for call logs histroy api calling
        setACSValues()
        
        self.registerIncomingCallHandler()
        self.registerChatClient()

        
        if(handleExternalLinks == true) {
            let dashViewController = DashboardViewController(nibName: nil, bundle: nil)
            dashViewController.handleExternalLinks = true
            dashViewController.meetingLink = self.meetingLink
            self.navigationController?.pushViewController(dashViewController, animated: false)
        }
        else {
            let dashViewController = DashboardViewController(nibName: nil, bundle: nil)
            dashViewController.isFromNotificationTray = CitiConstants.isFromNotification
            self.navigationController?.pushViewController(dashViewController, animated: false)
        }
    }
    
    
    func registerChatClient() {
        let rootVC = UIApplication.shared.keyWindow?.rootViewController
        let chatController = ChatController(rootViewController: rootVC)
        chatController.initChatClient()
    }
    

    func registerIncomingCallHandler () {
        storageUserDefaults.set(true, forKey: "isCallKitInSDKEnabled")
        
        let incomingCallController = ACSIncomingCallController()
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        incomingCallController.resigterIncomingCallClient(appPubs: appDelegate.appPubs)
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
    }
    
    func customizeTextFields(){
        username.delegate = self
        password.delegate = self
        
        username.customize()
        password.customize()

        password.isSecureTextEntry = true
        
        username.text = "veronicastephens838@gmail.com"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        customizeNavBar()
        customizeTextFields()
        
    }
    
    func flutterMethodChannel (passArgs: String?) {
        let controller : FlutterViewController = (UIApplication.shared.delegate as! AppDelegate).controller

        let acsChannel = FlutterMethodChannel(
            name: CitiConstants.method_channel_name,
            binaryMessenger: controller.binaryMessenger
        )
        
        acsChannel.invokeMethod("loginUserDetails", arguments: passArgs)
    }
    
    func setACSValues() {
        UserDefaults.standard.set(ACSResources.bankerAcsId, forKey: StorageKeys.bankerAcsId)
        UserDefaults.standard.set(ACSResources.bankerUserName, forKey: StorageKeys.bankerUserName)
        UserDefaults.standard.set(ACSResources.bankerUserEmail, forKey: StorageKeys.bankerUserEmail)
        UserDefaults.standard.set(ACSResources.customerAcsId, forKey: StorageKeys.customerAcsId)
        UserDefaults.standard.set(ACSResources.customerUserName, forKey: StorageKeys.customerUserName)
        UserDefaults.standard.set(ACSResources.customerUserEmail, forKey: StorageKeys.customerUserEmail)
        UserDefaults.standard.set(ACSResources.threadId, forKey: StorageKeys.threadId)
    }
}

extension LoginViewController : UITextFieldDelegate{}

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
