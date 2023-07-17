//
//  UserInfoData.swift
//  CitiApps
//
//  Created by Mohamad Mujeeb Urahaman on 01/02/23.
//

import Foundation

struct UserInfoData: Codable {
    
    private var userName: String? = ""
    private var userEmail: String? = ""
    private var userId: String? = ""
    
    init(name: String?, email: String?, id: String?) {
        self.userName = name
        self.userEmail = email
        self.userId = id
    }	
    
}
