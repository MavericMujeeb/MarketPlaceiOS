//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCore
import UIKit
import Foundation

enum MessageType: Equatable {
    case custom(String)
    case text
    case html
    case topicUpdated
    case participantsAdded
    case participantsRemoved

    var isSystemMessage: Bool {
        switch self {
        case .topicUpdated,
                .participantsAdded,
                .participantsRemoved:
            return true
        default:
            return false
        }
    }
}

struct MetaData: Equatable {
    //ios
    let hasAttachment: String
    let attachmentUrl: String
}

enum MessageSendStatus: Equatable {
    case sending
    case sent
    case seen
    case failed
}

struct ChatMessageInfoModel: BaseInfoModel, Identifiable, Equatable, Hashable {
    var id: String
    let version: String
    let type: MessageType
    var senderId: String?
    var senderDisplayName: String?
    var rawContent: String?
    var content: String?
    var createdOn: Iso8601Date
    var editedOn: Iso8601Date?
    var deletedOn: Iso8601Date?
    var sendStatus: MessageSendStatus?
    var isLocalUser: Bool
    var metadata: [String: String?]?

    // for participant added/removed only
    var participants: [ParticipantInfoModel]

    init(id: String? = nil,
         version: String = "",
         type: MessageType = .text,
         senderId: String? = nil,
         senderDisplayName: String? = nil,
         content: String? = nil,
         createdOn: Iso8601Date? = nil,
         editedOn: Iso8601Date? = nil,
         deletedOn: Iso8601Date? = nil,
         participants: [ParticipantInfoModel] = [],
         sendStatus: MessageSendStatus? = nil,
         isLocalUser: Bool = false,
         metadata: [String: String?]? = nil) {
        self.id = id ?? UUID().uuidString
        self.version = version
        self.type = type
        self.senderId = senderId
        self.senderDisplayName = senderDisplayName
        self.rawContent = content
        if type == .html {
            self.content = content?.unescapeHtmlString
        } else {
            self.content = content
        }

        self.createdOn = createdOn ?? Iso8601Date()
        self.editedOn = editedOn
        self.deletedOn = deletedOn
        self.participants = participants
        self.sendStatus = sendStatus
        print("Setting is LocalUser")
        print(Thread.callStackSymbols)
        print(isLocalUser)
        self.isLocalUser = isLocalUser
        self.metadata = metadata
    }

    mutating func replace(id: String) {
        self.id = id
    }

    mutating func edit(content: String) {
        self.content = content
    }

    mutating func update(editedOn: Iso8601Date) {
        self.editedOn = editedOn
    }

    mutating func update(deletedOn: Iso8601Date) {
        self.deletedOn = deletedOn
    }

    mutating func update(sendStatus: MessageSendStatus) {
        self.sendStatus = sendStatus
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension ChatMessageInfoModel {
    // Inject localization into method
    var dateHeaderLabel: String {
        let numberOfDaysSinceToday = createdOn.value.numberOfDays()
        if numberOfDaysSinceToday == 0 {
            return "Today" // Localization
        } else if numberOfDaysSinceToday == 1 {
            return "Yesterday" // Locatization
        } else if numberOfDaysSinceToday < 365 {
            let format = DateFormatter()
            format.dateFormat = "MMMM d"
            let formattedDate = format.string(from: createdOn.value)
            return formattedDate
        } else {
            let format = DateFormatter()
            format.dateFormat = "MMMM d, yyyy"
            let formattedDate = format.string(from: createdOn.value)
            return formattedDate
        }
    }

    // MARK: Text Message

    // Inject localization into method
    var timestamp: String {
        let createdOn = createdOn.value
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.amSymbol = "a.m." // Localization?
        dateFormatter.pmSymbol = "p.m." // Localization?

        return dateFormatter.string(from: createdOn)
    }

    func getIconNameForMessageSendStatus() -> CompositeIcon? {
        guard isLocalUser, let sendStatus = sendStatus else {
            return nil
        }

        switch sendStatus {
        case .sending:
            return .messageSending
        case .sent:
            return .messageSent
        case .seen:
            return .readReceipt
        case .failed:
            return .messageSendFailed
        }
    }

    func getContentLabel() -> String {
        return content ?? "Text not available" // Localization
    }

    private func getTopicLabel() -> String {
        guard let topic = content else {
            // Localization
            return "Topic updated"
        }
        // Localization
        return "Topic updated to \"\(topic)\""
    }

    // MARK: System Message

    // Inject localization into method
    var systemLabel: String {
        switch type {
        case .participantsAdded:
            return "\(participantsLabel) joined the chat" // Localization
        case .participantsRemoved:
            if isLocalUser {
                return "You were removed from the chat" // Localization
            }
            return "\(participantsLabel) left the chat" // Localization
        case .topicUpdated:
            return getTopicLabel()
        default:
            return ""
        }
    }

    var participantsLabel: String {
        return participants.map {$0.displayName}
            .joined(separator: ", ")
    }

    var systemIcon: CompositeIcon? {
        switch type {
        case .participantsAdded:
            return .systemJoin
        case .participantsRemoved:
            return .systemLeave
        case .topicUpdated:
            return nil
        default:
            return nil
        }
    }
    
    func isAttachmentReceived ()-> Bool{
        let fileMeta = self.metadata?["fileSharingMetadata"] ?? nil
        return fileMeta != nil
    }
    
    func hasAttachmentUrl() -> Bool? {
        print("hasAttachmentUrl --- api call")
        print(isAttachmentReceived() ?? "no value")
        if(isAttachmentReceived() == true){
            print("Crash-1")
            let fileMeta = self.metadata?["fileSharingMetadata"] ?? nil
            print("Crash-2")
            let fileInfo =  fileMeta?.data(using: .utf8) ?? nil
            print("Crash-3")
            do {
                print("Crash-4")
                let IntArray = try JSONSerialization.jsonObject(with: fileInfo!, options:[]) as? [Any]
                print("Crash-5")
                if IntArray?.count == 0 {
                    return false
                }
                let fileDetails = IntArray![0] as? [String:String]
                print("Crash-6")
                let url = fileDetails!["url"] ?? nil
                print("Crash-7")
                return url != nil                
            } catch {
                print("Error in Serialization")
            }
            print("Crash-9")
            return false
        }
        else{
            print("Crash-10")
            let value:String? = self.metadata?["hasAttachment"] ?? "false"
            print("Crash-11")
            let boolString = NSString(string: value!)
            print("Crash-12")
            return boolString.boolValue
        }
    }
    
    func getAttachmentUrl() -> String? {
        var value:String? = ""
        if(isAttachmentReceived() == true){
            let fileMeta = self.metadata?["fileSharingMetadata"] ?? nil
            let fileInfo =  fileMeta?.data(using: .utf8) ?? nil
            
            do {
                let IntArray = try JSONSerialization.jsonObject(with: fileInfo!, options:[]) as? [Any]
                let fileDetails = IntArray![0] as? [String:String]
                let url = fileDetails!["url"] ?? ""
                value = url
                
            } catch {
                print("Error in Serialization")
            }
        }
        else{
            value = self.metadata?["attachmentUrl"] ?? ""
        }
        let htmlString = "<html><b><a href=\(value)>\(value)</a></b></html>"
        var htmlToAttributedString: NSAttributedString? {
            guard let data = htmlString.data(using: String.Encoding.utf8, allowLossyConversion: true) else { return nil }
                do {
                    return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
                } catch {
                    return nil
                }
            }
        //return htmlToAttributedString?.string // Localization
        print("htmlToAttributedString ---- ")
        print(value)
        return value
    }
}

extension ChatMessageInfoModel {
    func toChatMessage() -> ChatMessageModel {
        return ChatMessageModel(
            id: self.id,
            content: self.content ?? "not available",
            senderId: self.senderId ?? "",
            senderDisplayName: self.senderDisplayName ?? "")
    }
}

// To be public for event handlers
struct ChatMessageModel {
    let id: String
    let content: String
    let senderId: String
    let senderDisplayName: String
}

extension Iso8601Date {
    var dayOfYear: Int {
        return Calendar.current.ordinality(of: .day, in: .year, for: self.value)!
    }
}

extension Date {
    func numberOfDays() -> Int {
        let calendar = Calendar.current

        let from = calendar.startOfDay(for: self)
        let to = calendar.startOfDay(for: Date())

        let components = calendar.dateComponents([.day], from: from, to: to)
        return components.day!
    }
}
