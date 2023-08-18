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
    
    private func getApi () {}
    private func postApi () {}
    
    func getACSCommunicationToken (completionHandler: (Data, Error) -> Void) {
        
    }
    
    func getAzureCommunicationToken () {
        let url = URLResources.callChatTokenUrl
        
        guard let url = URL(string: url), url.host != nil else {
            assertionFailure("You need to provide the URL for the endpoint to fetch the ACS token.")
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"

//        if let authToken = getAuthTokenFunction() {
//            urlRequest.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
//        }
//
        URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
            
        }
        
    }
    
    func getACSUserDetails () {
        
    }
    
}
