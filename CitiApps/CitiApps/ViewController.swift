//
//  HomeViewController.swift
//  in_view
//
//  Created by Balaji Babu Modugumudi on 17/10/22.
//

var users = [
    "janetjohnsonfamily83@gmail.com": ["name":"Janet Johnson","email":"janetjohnsonfamily83@gmail.com","userid":"a2194b29-07bb-48bb-8607-6151334cf904"],
    "johnwilliamsfamily9@gmail.com": ["name":"Smith Johnson","email":"johnwilliamsfamily9@gmail.com","userid":"8294e32a-d846-440d-b875-87b171b80787"],
]

var loggedInUser : String!
var loginDate : NSDate!


import UIKit
import FluentUI
import Flutter

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
    
    
    @IBAction func onLoginAction(_ sender: Any) {
        
        print(users)
        
//        let dashViewController = DashboardViewController(nibName: nil, bundle: nil)
//        self.navigationController?.pushViewController(dashViewController, animated: false)
//        return
        //Dont navigate to next screen if username or password field is empty
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
        
        loggedInUser = self.username.text
        
        var userInfo = UserInfoData(name: users[self.username.text!]?["name"], email: users[self.username.text!]?["email"], id: users[self.username.text!]?["userid"])
        var data = try! JSONEncoder().encode(userInfo)
        var userStr = String(data: data, encoding: .utf8)
        flutterMethodChannel(passArgs: userStr);
        if(handleExternalLinks == true){
//            let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
//
//            let introVC = IntroViewController();
//            introVC.authHandler = appDelegate.authHandler
//            introVC.createCallingContextFunction = { () -> CallingContext in
//            return CallingContext(tokenFetcher: appDelegate.tokenService.getCommunicationToken)
//            }
//
//            introVC.teamsMeetingLink = self.meetingLink
//
//            let fluentNavVc = PortraitOnlyNavController(rootViewController: introVC)
//            fluentNavVc.view.backgroundColor = FluentUI.Colors.surfaceSecondary
//            fluentNavVc.view.tintColor = FluentUI.Colors.iconPrimary
//            fluentNavVc.navigationBar.topItem?.backButtonDisplayMode = .minimal
//
//            let appearance = UINavigationBarAppearance()
//            appearance.backgroundColor = FluentUI.Colors.surfaceSecondary
//            appearance.titleTextAttributes = [.foregroundColor: FluentUI.Colors.textPrimary]
//            appearance.largeTitleTextAttributes = [.foregroundColor: FluentUI.Colors.textPrimary]
//
//            fluentNavVc.navigationBar.standardAppearance = appearance
//            fluentNavVc.navigationBar.scrollEdgeAppearance = appearance
            
            let teamsCallingViewController = TeamsCallingViewController()
            teamsCallingViewController.teamsLink = self.meetingLink
            self.present(teamsCallingViewController, animated: true)
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
    
    func customizeNavBar(){
        let logoImageView = UIImageView.init()
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.contentMode =  UIView.ContentMode.scaleAspectFit
    
//        logoImageView.image = UIImage.init(named: "citiLogo");
        
        let logoBarButtonItem = UIBarButtonItem.init(customView: logoImageView);
        
        let width = self.view.frame.size.width * 0.3;
        let height = width * 178/794;
        
        logoImageView.widthAnchor.constraint(equalToConstant: width).isActive = true;
        logoImageView.heightAnchor.constraint(equalToConstant: height).isActive = true;
        
  
        self.navigationController?.navigationBar.topItem?.leftBarButtonItem = logoBarButtonItem;
        
        let trailingButton = UIBarButtonItem.init(customView: UIImageView(image: UIImage(systemName: "line.horizontal.3")))
        
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = trailingButton;
    }
    
    func customizeTextFields(){
        username.delegate = self
        password.delegate = self
        
        username.customize()
        password.customize()

        password.isSecureTextEntry = true
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
            name: "com.citi.marketplace.host",
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
