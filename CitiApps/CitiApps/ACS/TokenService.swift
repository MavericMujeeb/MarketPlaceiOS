//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class TokenService {
    private var communicationTokenFetchUrl: String
    private var getAuthTokenFunction: () -> String?

    init(communicationTokenFetchUrl: String, getAuthTokenFunction: @escaping () -> String?) {
        self.communicationTokenFetchUrl = communicationTokenFetchUrl
        self.getAuthTokenFunction = getAuthTokenFunction
    }

    func getCommunicationToken(completionHandler: @escaping (String?, Error?) -> Void) {
        guard let url = URL(string: communicationTokenFetchUrl),
              url.host != nil else {
            assertionFailure(
"""
\n
        You need to provide the URL for the endpoint to fetch the ACS token.
        This should be set in a AppSettings.xcconfig file.
\n
"""
            )
            return
        }
        var urlRequest = URLRequest(url: url)
        print(url)
        urlRequest.httpMethod = "GET"
//        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

//        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        

        let req_body: [String: String] = [
            "client_id": "e6197263-b986-4f08-9a27-08a4ec1b5c8e",
            "scope": "https://graph.microsoft.com/.default",
            "client_secret":"4k48Q~wbivlxdFIbyVcNg3ykunlNdI.vcyC2Kbi0",
            "grant_type":"client_credentials"
        ]
        
        let jsonReqBody = try? JSONSerialization.data(withJSONObject: req_body, options: [])
        
//        urlRequest.httpBody = jsonReqBody
        
        if let authToken = getAuthTokenFunction() {
            urlRequest.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
            if let error = error {
                print(error)
                completionHandler(nil, error)
            } else if let data = data {
                do {
                    let res = try JSONDecoder().decode(TokenResponse.self, from: data)
                    completionHandler(res.token, nil)
                } catch let error {
                    if let parsedPayload = data.asPrettyJson {
                        print("Payload:\n\(parsedPayload)")
                    }
                    assertionFailure(
"""
\n
        JSON Parsing of the token response failed.
        This code expects a top level key named 'token' with a string value
        Please modify TokenResponse to match as necessary
\n
"""
                    )
                    completionHandler(nil, error)
                }
            }
        }.resume()
    }
}

private struct TokenResponse: Decodable {
    var token: String

    private enum CodingKeys: String, CodingKey {
        case token
    }
}
