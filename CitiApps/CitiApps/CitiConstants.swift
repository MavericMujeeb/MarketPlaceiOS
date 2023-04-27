//
//  CitiConstants.swift
//  CitiApps
//
//  Created by Mohamad Mujeeb Urahaman on 21/02/23.
//

struct CitiConstants {
    static let method_channel_name: String = "com.maveric.citiacsdemo"
}

struct StorageKeys {
    static let bankerEmailId: String = "bankerEmailId"
    static let loginUserName: String = "loginUserName"
}

struct ACSResources {
    
    static var bankerAcsId:String = ""
    static var customerAcsId:String = ""
    
    static let acs_token_fetch_api:String = "https://acstokenfuncapp.azurewebsites.net/api/acschatcallingfunction/"
    static let acs_chat_participantdetails_api:String = "https://acsinfo.azurewebsites.net/api/participantDetails/"
    static let acs_chat_api_url:String = "https://acstokenfuncapp.azurewebsites.net/api/acsuserdetailsfunction?bankerAcsId="+bankerAcsId+"&customerAcsId="+customerAcsId
}

