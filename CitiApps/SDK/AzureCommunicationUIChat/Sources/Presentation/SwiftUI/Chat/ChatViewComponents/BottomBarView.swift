//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct DocumentPicker : UIViewControllerRepresentable {

    @Binding var added: Bool
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let controller = UIDocumentPickerViewController(forOpeningContentTypes: [.text, .pdf, .png, .jpeg])
        controller.allowsMultipleSelection = false
        controller.shouldShowFileExtensions = true
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    func makeCoordinator() -> () {
        DocumentPickerCoordinator(added: $added)
    }
}

class FilePickerViewController : UIViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

class DocumentPickerCoordinator: NSObject, UIDocumentPickerDelegate{
    @Binding var added: Bool
    
    init(added: Binding<Bool>) {
        self._added = added
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {
            return
        }
        print(url)
        added = true
    }
    
}

struct BottomBarView: View {
    
    private enum Constants {
        static let minimumHeight: CGFloat = 50
        static let focusDelay: CGFloat = 1.0
        static let topPadding: CGFloat = 10
        static let padding: CGFloat = 12
    }
    @StateObject var viewModel: BottomBarViewModel
    
    @State var textEditorHeight: CGFloat = 20
    
    var body: some View {
        HStack(alignment: .bottom, spacing: Constants.padding) {
            if viewModel.isLocalUserRemoved {
                localParticipantRemovedBanner
            } else {
                messageTextField
                attachmentButton
                sendButton
            }
        }
        .padding([.top], Constants.topPadding)
        .padding([.leading, .trailing, .bottom], Constants.padding)
    }
    
    var messageTextField: some View {
        TextEditorView(text: $viewModel.message)
    }
    
    var sendButton: some View {
        IconButton(viewModel: viewModel.sendButtonViewModel)
            .flipsForRightToLeftLayoutDirection(true)
    }
    
    @State var shouldPresentChat = false
    
    var attachmentButton: some View {
        Button(action: {
            shouldPresentChat.toggle()
        }) {
            Icon(name: .attachmentIcon, size: 24)
                .contentShape(Rectangle())
        }.fileImporter(isPresented: $shouldPresentChat, allowedContentTypes: [.text, .pdf, .png, .jpeg, .heic], allowsMultipleSelection: false, onCompletion: { results in
            
            switch results {
            case .success(let fileurls):
                
                for fileurl in fileurls {
                    let url = fileurl as URL
                    guard url.startAccessingSecurityScopedResource() else {return}
                    
                    do {
                        let fileData = try Data(contentsOf: url)
                        //let fileStream:String = fileData.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))
                        //let convertedString = NSString(data: fileData, encoding: NSUTF8StringEncoding)
                        uploadFile(file: fileData, fileName: url.lastPathComponent, fileExtension: url.pathExtension)
                    }
                    catch {
                        print("FileImporter Error: \(error)")
                    }
                }
                
            case .failure(let error):
                print(error)
            }
            
        })
        
        //        IconButton(viewModel: viewModel.attachmentButtonViewModel)
        //            .flipsForRightToLeftLayoutDirection(true)
    }
    
    func uploadFile(file:Data, fileName: String, fileExtension: String){
        let editedFilename = fileName.removeWhitespaces.stripped
        let request = MultipartFormDataRequest(fileName:  editedFilename)
        request.addDataField(fieldName:  "file", fileName: editedFilename, data: file, mimeType: request.getMimeType(filenameORfileExtension: fileExtension))
        
        URLSession.shared.dataTask(with: request, completionHandler: {data,urlResponse,error in
            
            if let response = urlResponse as? HTTPURLResponse {
                if response.statusCode == 201 {
                    let fileFullUrl = request.storageAccountEndPoint+request.containerName+editedFilename
                    viewModel.sendMessage(fileUrl: fileFullUrl, fileName: editedFilename, fileExtension: fileExtension)
                }
            }
            if let data = data {
                do {
                    //let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    //print("Server Data")
                    //print(json)
                } catch {
                    //print("Server Error")
                    //print("Error Code: \(error._code)")
                    //print("Error Messsage: \(error.localizedDescription)")
                    //if let str = String(data: data, encoding: String.Encoding.utf8){
                    //print("Print Server data:- " + str)
                    //}
                }
            }
        }).resume()
    }
    
    var localParticipantRemovedBanner: some View {
        Text("You're no longer a participant")
            .foregroundColor(Color(StyleProvider.color.textSecondary))
    }
}

// Workaround due to no support for multiline text in SwiftUI Textfield.
// Multiline support was added in iOS 16 but has a new issue of lack of
// support for padding
// This uses an invisible text view to measure the text size and then pass
// that to the texteditor to use for it's height
struct TextEditorView: View {
    private enum Constants {
        static let cornerRadius: CGFloat = 10
        static let minimumHeight: CGFloat = 40
        // Extra padding needed when more that one line displayed
        static let multilineHeightOffset: CGFloat = 14
        static let leadingPadding: CGFloat = 4
        static let padding: CGFloat = 6
        static let placeHolderPadding: CGFloat = 8
    }
    
    @Binding var text: String
    @State var textEditorHeight: CGFloat = Constants.minimumHeight
    
    var body: some View {
        ZStack(alignment: .leading) {
            heightMeasureWorkAround
            ZStack(alignment: .leading) {
                textEditor
                placeHolder
            }
        }.onPreferenceChange(ViewHeightKey.self) {
            textEditorHeight = $0 + (text.numberOfLines() > 1 ? Constants.multilineHeightOffset : 0)
        }
    }
    
    var heightMeasureWorkAround: some View {
        Text(text)
            .font(.system(.body))
            .foregroundColor(.clear)
            .background(GeometryReader {
                Color.clear.preference(key: ViewHeightKey.self,
                                       value: $0.frame(in: .local).size.height)
            })
    }
    
    var textEditor: some View {
        TextEditor(text: $text)
            .font(.system(.body))
            .frame(height: max(Constants.minimumHeight, textEditorHeight))
            .padding([.leading], Constants.leadingPadding)
            .padding([.top], Constants.padding)
            .overlay(RoundedRectangle(cornerRadius: Constants.cornerRadius)
                .stroke(Color(StyleProvider.color.dividerOnPrimary)))
    }
    
    var placeHolder: some View {
        Group {
            if text.isEmpty {
                Text("Type a message") // Localization
                    .foregroundColor(Color(StyleProvider.color.textDisabled))
                    .padding(Constants.placeHolderPadding)
                    .allowsHitTesting(false)
            }
        }
    }
}

extension String {
    func numberOfLines() -> Int {
        return self.numberOfOccurrencesOf(string: "\n") + 1
    }
    
    func numberOfOccurrencesOf(string: String) -> Int {
        return self.components(separatedBy: string).count - 1
    }
    
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
    
    var stripped: String {
        let okayChars = Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-=().!_")
        return self.filter {okayChars.contains($0) }
    }
    
    var removeWhitespaces: String {
        return components(separatedBy: .whitespaces).joined()
    }
}

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}
