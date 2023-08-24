//
//  NetworkManager.swift
//  CitiApps
//
//  Created by Balaji Babu Modugumudi on 22/08/23.
//

import Foundation


class NetworkManager {
    
    static let shared = NetworkManager()

    var bankerEmailId:String! = ""
    var custUserName:String! = ""
    
    
    func getCommunicationToken () {
        
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
                    //completion Handler success responnse
                    completion(responseModel, error)
                    
                } catch {
                    //completion Handler error responnse
                    completion(nil, error)
                }
                
            }
        }
        task.resume()
    }
}