//
//  AcsUserIdToken.swift
//  CitiApps
//
//  Created by Mohamad Mujeeb Urahaman on 07/03/23.
//

import Foundation

struct AcsUserIdToken: Codable {
    
    var acsEndpoint: String? = ""
    var bankerUserId: String? = ""
    var bankerUserToken: String? = ""
    var customerUserId: String? = ""
    var customerUserToken: String? = ""
}
