//
//  CitiConstants.swift
//  CitiApps
//
//  Created by Mohamad Mujeeb Urahaman on 21/02/23.
//

struct CitiConstants {
    static let method_channel_name: String = "com.maveric.citiacsdemo"
    static var isFromNotification: Bool = false
}

struct StorageKeys {
    static let bankerEmailId: String = "bankerEmailId"
    static let loginUserName: String = "loginUserName"
    static let acsToken: String = "acsToken"
    
    static let bankerAcsId:String = "bankerAcsId"
    static let bankerUserName:String = "bankerUserName"
    static let bankerUserEmail:String = "bankerUserEmail"
    static let customerAcsId:String = "customerAcsId"
    static let customerUserName:String = "customerUserName"
    static let customerUserEmail:String = "customerUserEmail"
    static let threadId:String = "threadId"
}

struct ACSResources {
    
    static var bankerAcsId:String = "8:acs:ea7ee9db-4146-4c6c-8ffd-8bff35bdd986_00000018-59b7-8f91-eaf3-543a0d000ff3"
    static var bankerUserName:String = "Richard Jones"
    static var bankerUserEmail:String = "chantal@acsteamsciti.onmicrosoft.com"
    static var customerAcsId:String = "8:acs:ea7ee9db-4146-4c6c-8ffd-8bff35bdd986_0000001a-33b0-777b-b5bb-a43a0d005750"
    static var customerUserName:String = "Veronica Stephens"
    //static var customerUserEmail:String = "veronicastephens838@gmail.com"
    static var customerUserEmail:String = "veronicastephens@acsteamsciti.onmicrosoft.com"
    static var threadId:String = "19:1528f625680a4d9989b5becc04f01798@thread.v2"
    
    static let acs_token_fetch_api:String = "https://acstokenfuncapp.azurewebsites.net/api/acschatcallingfunction/"
    static let acs_chat_participantdetails_api:String = "https://acsinfonodb.azurewebsites.net/api/participantDetails"
    static let acs_chat_api_url:String = "https://acstokenfuncapp.azurewebsites.net/api/acsuserdetailsfunction?bankerAcsId="+bankerAcsId+"&customerAcsId="+customerAcsId
    
    static let acs_notificationHub_endpoint:String = "Endpoint=sb://ACSCitiPushServiceNew.servicebus.windows.net/;SharedAccessKeyName=DefaultFullSharedAccessSignature;SharedAccessKey=hPhXI6h3xPKb0MhtNq60mM9hsXVtC1Ia8ty6R4V4Dc8="
    static let acs_notificationHub_namespace:String = "ACSCitiPushServiceNew"
}

