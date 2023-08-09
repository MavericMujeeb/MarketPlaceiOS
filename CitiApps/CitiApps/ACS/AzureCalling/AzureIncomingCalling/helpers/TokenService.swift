//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class TokenService {
    
    private var tokenString : String
    private var communicationTokenFetchUrl: String
    private var getAuthTokenFunction: () -> String?

    init(tokenACS:String, communicationTokenFetchUrl: String, getAuthTokenFunction: @escaping () -> String?) {
        self.communicationTokenFetchUrl = communicationTokenFetchUrl
        self.getAuthTokenFunction = getAuthTokenFunction
        self.tokenString = tokenACS
    }
    
    
    func getCustomerCommunicationToken(completionHandler: @escaping (String?, Error?) -> Void) {
        CircleLoader.sharedInstance.show()
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
        urlRequest.httpMethod = "GET"

        if let authToken = getAuthTokenFunction() {
            urlRequest.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
            CircleLoader.sharedInstance.hide()
            if let error = error {
                completionHandler(nil, error)
            } else if let data = data {
                do {
                    let res = try JSONDecoder().decode(AcsUserIdToken.self, from: data)
                    completionHandler(res.customerUserToken, nil)
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

    func getCommunicationToken(completionHandler: @escaping (String?, Error?) -> Void) {
        print("getCommunicationToken")
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
        urlRequest.httpMethod = "GET"

        if let authToken = getAuthTokenFunction() {
            urlRequest.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
            if let error = error {
                completionHandler(nil, error)
            } else if let data = data {
                do {
                    let res = try JSONDecoder().decode(TokenResponse.self, from: data)
                    completionHandler(res.token, nil)
                } catch let error {
                    print(error)
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
