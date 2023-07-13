//
//  IncomingCallViewModel.swift
//  CitiApps
//
//  Created by Balaji Babu Modugumudi on 07/07/23.
//

import Foundation


class IncomingCallViewModel : NSObject, ObservableObject{
    @Published var isIncomingCall:Bool = false
 
    func setIsIncomingCall(incoming:Bool) {
        self.isIncomingCall = incoming
    }
}
