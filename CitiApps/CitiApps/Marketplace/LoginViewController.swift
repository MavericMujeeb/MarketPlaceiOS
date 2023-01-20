//
//  ViewController.swift
//  in_view
//
//  Created by Balaji Babu Modugumudi on 17/10/22.
//

import UIKit

class LoginViewController: UIViewController {
    
    
    // MARK: - Stored Properties
//    var loginViewModel: LoginViewModel!
    
    
    //MARK: - IBOutlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    //MARK: - IBActions
    @IBAction func loginButtonPressed(_ sender: UIButton) {
//        //Here we ask viewModel to update model with existing credentials from text fields
//        loginViewModel.updateCredentials(username: usernameTextField.text!, password: passwordTextField.text!)
//
//        //Here we check user's credentials input - if it's correct we call login()
//        switch loginViewModel.credentialsInput() {
//
//        case .Correct:
//            login()
//        case .Incorrect:
//            return
//        }
        login()
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

