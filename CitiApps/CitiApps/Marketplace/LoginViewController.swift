//
//  ViewController.swift
//  in_view
//
//  Created by Balaji Babu Modugumudi on 17/10/22.
//

import UIKit
import LocalAuthentication

class LoginViewController: UIViewController {
    
    
    // MARK: - Stored Properties
    var loginViewModel: LoginViewModel!
    
    
    //MARK: - IBOutlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var faceDetectIV: UIImageView!
    
    //MARK: - IBActions
    @IBAction func loginButtonPressed(_ sender: UIButton) {
//        //Here we ask viewModel to update model with existing credentials from text fields
        loginViewModel.updateCredentials(username: usernameTextField.text!, password: passwordTextField.text!)
//
//        //Here we check user's credentials input - if it's correct we call login()
        switch loginViewModel.validateInput() {

        case true:
            login()
        case false:
            return
        }
    }
    
    func login() {
        let yourVc = DashboardViewController.init(nibName: nil, bundle: nil)
        self.navigationController?.pushViewController(yourVc, animated: true)
    }
    
    func setupButton() {
        loginButton.layer.cornerRadius = 5
    }
    
    
    func setDelegates() {
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    
    func highlightTextField(_ textField: UITextField) {
        textField.resignFirstResponder()
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.red.cgColor
        textField.layer.cornerRadius = 3
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegates()
        setupButton()
    }
    
}

//MARK: - Text Field Delegate Methods
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        usernameTextField.layer.borderWidth = 0
        passwordTextField.layer.borderWidth = 0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension UIViewController {
    
    func authenticationWithTouchFaceID() {
        let localAuthenticationContext = LAContext()
        localAuthenticationContext.localizedFallbackTitle = "Use Passcode"

        var authError: NSError?
        let reasonString = "To access the secure data"

        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            
            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString) { success, evaluateError in
                
                if success {
                    
                    //TODO: User authenticated successfully, take appropriate action
                    
                } else {
                    //TODO: User did not authenticate successfully, look at error and take appropriate action
                    guard let error = evaluateError else {
                        return
                    }
                    //TODO: If you have choosen the 'Fallback authentication mechanism selected' (LAError.userFallback). Handle gracefully
                    self.authenticationWithPasscode()
                    
                    print("Face Recog 2->")
                    print(self.evaluateAuthenticationPolicyMessageForLA(errorCode: error._code))
                }
            }
        } else {
            guard let error = authError else {
                return
            }
            //TODO: Show appropriate alert if biometry/TouchID/FaceID is lockout or not enrolled
            print("Face Recog 3->")
            print(self.evaluateAuthenticationPolicyMessageForLA(errorCode: error.code))
            self.authenticationWithPasscode()
        }
    }
    
    func authenticationWithPasscode() {
        let localAuthenticationContext = LAContext()
        localAuthenticationContext.localizedFallbackTitle = "Use Passcode"

        var authError: NSError?
        let reasonString = "To access the secure data"

        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authError) {
            
            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reasonString) { success, evaluateError in
                
                if success {
                    
                    //TODO: User authenticated successfully, take appropriate action
                    
                } else {
                    //TODO: User did not authenticate successfully, look at error and take appropriate action
                    guard let error = evaluateError else {
                        return
                    }
                    //TODO: If you have choosen the 'Fallback authentication mechanism selected' (LAError.userFallback). Handle gracefully
                    self.errorAlertMsg(title: "Authentication failed", message: "You could not be verified; please try again.")
                    
                    print("Face Recog 2->")
                    print(self.evaluateAuthenticationPolicyMessageForLA(errorCode: error._code))
                }
            }
        } else {
            guard let error = authError else {
                return
            }
            //TODO: Show appropriate alert if biometry/TouchID/FaceID is lockout or not enrolled
            print("Face Recog 3->")
            print(self.evaluateAuthenticationPolicyMessageForLA(errorCode: error.code))
            self.errorAlertMsg(title: "Biometry unavailable", message: "Your device is not configured for biometric authentication.")
        }
    }
    
    func evaluatePolicyFailErrorMessageForLA(errorCode: Int) -> String {
        var message = ""
        if #available(iOS 11.0, macOS 10.13, *) {
            switch errorCode {
                case LAError.biometryNotAvailable.rawValue:
                    message = "Authentication could not start because the device does not support biometric authentication."
                
                case LAError.biometryLockout.rawValue:
                    message = "Authentication could not continue because the user has been locked out of biometric authentication, due to failing authentication too many times."
                
                case LAError.biometryNotEnrolled.rawValue:
                    message = "Authentication could not start because the user has not enrolled in biometric authentication."
                
                default:
                    message = "Did not find error code on LAError object"
            }
        } else {
            switch errorCode {
                case LAError.touchIDLockout.rawValue:
                    message = "Too many failed attempts."
                
                case LAError.touchIDNotAvailable.rawValue:
                    message = "TouchID is not available on the device"
                
                case LAError.touchIDNotEnrolled.rawValue:
                    message = "TouchID is not enrolled on the device"
                
                default:
                    message = "Did not find error code on LAError object"
            }
        }
        return message;
    }
    
    func evaluateAuthenticationPolicyMessageForLA(errorCode: Int) -> String {
        
        var message = ""
        
        switch errorCode {
            
        case LAError.authenticationFailed.rawValue:
            message = "The user failed to provide valid credentials"
            
        case LAError.appCancel.rawValue:
            message = "Authentication was cancelled by application"
            
        case LAError.invalidContext.rawValue:
            message = "The context is invalid"
            
        case LAError.notInteractive.rawValue:
            message = "Not interactive"
            
        case LAError.passcodeNotSet.rawValue:
            message = "Passcode is not set on the device"
            
        case LAError.systemCancel.rawValue:
            message = "Authentication was cancelled by the system"
            
        case LAError.userCancel.rawValue:
            message = "The user did cancel"
            
        case LAError.userFallback.rawValue:
            message = "The user chose to use the fallback"

        default:
            message = evaluatePolicyFailErrorMessageForLA(errorCode: errorCode)
        }
        return message
    }
    
    func errorAlertMsg(title: String, message:String ) {
        DispatchQueue.main.async {
            let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
        }
    }
}

