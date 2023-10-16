//
//  ChatView.swift
//  CitiApps
//
//  Created by Balaji Babu Modugumudi on 12/10/23.
//

import SwiftUI
import Foundation


struct ChatView: View {
    
    var teamsMeetingLink:String?
    
    var body: some View {
        Text("Hello, World!")
            .onAppear{
                
            }
    }
    
//    init(meetingLink:String) {
//        self.teamsMeetingLink = meetingLink
//    }
    
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
