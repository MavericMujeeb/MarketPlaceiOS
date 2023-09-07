//
//  NetworkManager.swift
//  CitiApps
//
//  Created by Balaji Babu Modugumudi on 10/08/23.
//

import Foundation


struct URLResources {
    static let callChatTokenUrl = "https://acstokenfuncapp.azurewebsites.net/api/acschatcallingfunction/"
}


class NetworkManager {
    static let shared = NetworkManager()
    
    var bankerEmailId:String!=""
    var custUserName:String!=""
    
    private func getApi () {}
    private func postApi () {}
    
    func getACSCommunicationToken (completionHandler: (Data, Error) -> Void) {
        
    }
    
    func getAzureCommunicationToken (token: String?, completion:@escaping (String?, Error?)->Void) {
        let url = URLResources.callChatTokenUrl
        
        guard let url = URL(string: url), url.host != nil else {
            assertionFailure("You need to provide the URL for the endpoint to fetch the ACS token.")
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"

        if let authToken = token {
            urlRequest.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }

        print("fetch token")
//        
//        URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
//            if(error == nil){
//                let res = try JSONDecoder().decode(AcsUserIdToken.self, from: data)
//                completion(res.customerUserToken, nil)
//            }
//            else{
//                completion(nil, error)
//            }
//        }
        
    }
    
 
    func getAcsUserDetails(completion: @escaping (ParticipantDetails?, Error?)->Void) {
        
        let storageUserDefaults = UserDefaults.standard
        
        self.bankerEmailId = storageUserDefaults.string(forKey: "bankerEmailId")
        self.custUserName = storageUserDefaults.string(forKey: "loginUserName")
        
        let reqBody = "{" +
        "\"originatorId\":\"\(self.bankerEmailId!)\"," +
        "\"participantName\":\"\(self.custUserName!)\"" +
        
        
        "}"
        
        let fullUrl: String = ACSResources.acs_chat_participantdetails_api
        
        guard let url = try? URL(string: fullUrl) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //set http method as POST
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = reqBody.data(using: .utf8)!
        
        let task = URLSession.shared.dataTask(with: request){
            data, response, error in
            if let data = data, let string = String(data: data, encoding: .utf8){
                do {
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(ParticipantDetails.self, from: data)
                    completion(responseModel, error)
                    
                } catch {
                    completion(nil, error)
                }
                
            }
        }
        task.resume()
    }
    
}
