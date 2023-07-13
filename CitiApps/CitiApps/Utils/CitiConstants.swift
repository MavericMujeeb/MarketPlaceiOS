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
    static let acsToken: String = "acsToken"
    
}

struct ACSResources {
    
    static var bankerAcsId:String = ""
    static var customerAcsId:String = ""
    
    static let acs_token_fetch_api:String = "https://acstokenfuncapp.azurewebsites.net/api/acschatcallingfunction/"
    static let acs_chat_participantdetails_api:String = "https://acsinfo.azurewebsites.net/api/participantDetails/"
    static let acs_chat_api_url:String = "https://acstokenfuncapp.azurewebsites.net/api/acsuserdetailsfunction?bankerAcsId="+bankerAcsId+"&customerAcsId="+customerAcsId
    
    static let acs_notificationHub_endpoint:String = "Endpoint=sb://ACSCitiPushServiceNew.servicebus.windows.net/;SharedAccessKeyName=DefaultFullSharedAccessSignature;SharedAccessKey=hPhXI6h3xPKb0MhtNq60mM9hsXVtC1Ia8ty6R4V4Dc8="
    static let acs_notificationHub_namespace:String = "ACSCitiPushServiceNew"
}

