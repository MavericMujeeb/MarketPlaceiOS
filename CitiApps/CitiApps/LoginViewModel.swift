//
//  LoginViewModel.swift
//  CitiApps
//
//  Created by Balaji Babu Modugumudi on 26/01/23.
//
import Foundation

class LoginViewModel: NSObject {
    
    var email : String?
    var password : String?
    
    
    //MARK: Methods
    func doLogin() {
            
    }
    
    func updateCredentials(username: String, password:String) {
        
    }
    
    func validateInput () -> Bool {
        //handle the email validation here/
        //check for particular user
        return true;
    }
}
