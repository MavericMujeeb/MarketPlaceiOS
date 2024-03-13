//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCommon
import SwiftUI

extension CommunicationIdentifier {
    var stringValue: String? {
        switch self {
        case is CommunicationUserIdentifier:
            return (self as? CommunicationUserIdentifier)?.identifier
        case is UnknownIdentifier:
            return (self as? UnknownIdentifier)?.identifier
        case is PhoneNumberIdentifier:
            return (self as? PhoneNumberIdentifier)?.phoneNumber
        case is MicrosoftTeamsUserIdentifier:
            return (self as? MicrosoftTeamsUserIdentifier)?.userId
        default:
            return nil
        }
    }

}

class CallingSDKErrorCode {
    static func getErrorMessage(code:Int32 = 0, subCode:Int32 = 0) -> String {
        if(code == 0) {
            return ""
        }
        
        var codeMessage:String
        var subcodeMessage:String
        switch code {
        case 403:
            codeMessage = "Forbidden / Authentication failure."
        case 404:
            codeMessage = "Call not found."
        case 408:
            codeMessage = "Call controller timed out."
        case 410:
            codeMessage = "Local media stack or media infrastructure error."
        case 430:
            codeMessage = "Unable to deliver message to client application."
        case 480:
            codeMessage = "Remote client endpoint not registered."
        case 481:
            codeMessage = "Failed to handle incoming call."
        case 487:
            codeMessage = "Call canceled, locally declined, ended due to an endpoint mismatch issue, or failed to generate media offer."
        case 490, 491, 496, 497, 498:
            codeMessage = "Local endpoint network issues."
        case 500, 503, 504:
            codeMessage = "Communication Services infrastructure error."
        case 603:
            codeMessage = "Call globally declined by remote Communication Services participant."
        default:
            codeMessage = ""
        }
        
        switch subCode {
        case 403:
            subcodeMessage = "Forbidden / Authentication failure."
        default:
            subcodeMessage = ""
        }
        return "\(codeMessage)\(subcodeMessage)"
    }
}

class CallLogs {
    
    static var callStartTime:Double = 0.0
    static var callEndTime:Double = 0.0
    
    static func logCallsHistory(callername: String, calleremail: String, calleracsid: String,calleename: String, calleeemail: String, calleeacsid: String,callType: String, startTime: String, endTime: String) {
        
        // declare the parameter as a dictionary that contains string as key and value combination. considering inputs are valid
        
        let callerParam:[String: Any] = ["id": calleracsid, "name": callername, "email": calleremail]
        let calleeParam:[String: Any] = ["id": calleeacsid, "name": calleename, "email": calleeemail]
        let parameters: [String: Any] = ["caller": callerParam, "callee": calleeParam, "call-type": callType, "start-time": startTime, "end-time": endTime]
        
        // create the url with URL
        let url = URL(string: "https://appian-backend.azurewebsites.net/call-log")! // change server url accordingly
        
        // create the session object
        let session = URLSession.shared
        
        // now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //set http method as POST
        
        // add headers for the request
        request.addValue("application/json", forHTTPHeaderField: "Content-Type") // change as per server requirements
        request.addValue("*/*", forHTTPHeaderField: "Accept")
        
        do {
            // convert parameters to Data and assign dictionary to httpBody of request
//            request.httpBody = try! JSONEncoder().encode(parameters)
            request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            return
        }
        
        // create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("Post Request Error: \(error.localizedDescription)")
                return
            }
            
            // ensure there is valid response code returned from this HTTP response
            if let httpResponse = response as? HTTPURLResponse {
                print("httpResponse.statusCode")
                print(httpResponse.statusCode)
            } else {
                print("Invalid Response received from the server")
                return
            }
            
            // ensure there is data returned
            guard let responseData = data else {
                print("nil Data received from the server")
                return
            }
            
            do {
                // create json object from data or use JSONDecoder to convert to Model stuct
                if let jsonResponse = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers) as? [String: Any] {
                    print(jsonResponse)
                    // handle json response
                } else {
                    print("data maybe corrupted or in wrong format")
                    throw URLError(.badServerResponse)
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
        // perform the task
        task.resume()
    }
}

//struct CallLogData: Codable {
//    let caller, callee: Calle
//    let callType, startTime, endTime: String
//    
//    enum CodingKeys: String, CodingKey {
//        case caller, callee
//        case callType = "call-type"
//        case startTime = "start-time"
//        case endTime = "end-time"
//    }
//}
//
//struct Calle: Codable {
//    let name, email, id: String
//}

extension Double {
    var removeDecimalValue: String {
        return String(format: "%.0f", self)
    }
}

