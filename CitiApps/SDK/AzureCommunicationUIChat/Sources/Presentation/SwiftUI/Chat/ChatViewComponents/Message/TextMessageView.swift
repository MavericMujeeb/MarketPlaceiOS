//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI
import WebKit

struct TextMessageView: View {
    
    static let documentViewWidth: CGFloat = UIScreen.main.bounds.size.width/2
    static let documentViewHeight: CGFloat = UIScreen.main.bounds.size.height/10
    
    private enum Constants {
        static let localLeadingPadding: CGFloat = 60
        static let remoteAvatarLeadingPadding: CGFloat = 6
        static let remoteLeadingPadding: CGFloat = 30
        static let spacing: CGFloat = 4
        static let contentHorizontalPadding: CGFloat = 10
        static let contentVerticalPadding: CGFloat = 8
        static let cornerRadius: CGFloat = 5
    }
    
    let messageModel: ChatMessageInfoModel
    let showUsername: Bool
    let showTime: Bool
    
    var body: some View {
        HStack(spacing: Constants.spacing) {
            if messageModel.isLocalUser {
                Spacer()
            }
            avatar
            VStack(alignment: .leading) {
                bubble
                if messageModel.hasAttachmentUrl() ?? false {
                    documentview
                }
            }.padding([.leading, .trailing], Constants.contentHorizontalPadding)
                .padding([.top, .bottom], Constants.contentVerticalPadding)
                .background(getMessageBubbleBackground(messageModel: messageModel))
                .cornerRadius(Constants.cornerRadius)
            if !messageModel.isLocalUser {
                Spacer()
            }
        }
        .padding(.leading, getLeadingPadding)
    }
    
    var avatar: some View {
        VStack() {
            if showUsername {
                Avatar(style: .outlinedPrimary, size: .small, primaryText: messageModel.senderDisplayName)
                Spacer()
            }
        }
    }
    
    var bubble: some View {
        VStack(alignment: .leading) {
            HStack {
                name
                timeStamp
                edited
            }
            Text(messageModel.getContentLabel())
                .font(.body)
        }
    }
    
    var documentview: some View {
        VStack(alignment: .leading) {
            ACSDocumentView(url: messageModel.getAttachmentUrl()!)
        }.padding([.bottom], Constants.contentVerticalPadding)
            .frame(width: TextMessageView.documentViewWidth, height: TextMessageView.documentViewHeight)
            .onTapGesture {
                print("Document View Clicked")
            }
    }
    
    var name: some View {
        Group {
            if showUsername && messageModel.senderDisplayName != nil {
                Text(messageModel.senderDisplayName!)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Color(StyleProvider.color.textPrimary))
            }
        }
    }
    
    var timeStamp: some View {
        Group {
            if showTime {
                Text(messageModel.timestamp)
                    .font(.caption)
                    .foregroundColor(Color(StyleProvider.color.textSecondary))
            }
        }
    }
    
    var edited: some View {
        Group {
            if messageModel.editedOn != nil {
                Text("Edited")
                    .font(.caption)
                    .foregroundColor(Color(StyleProvider.color.textDisabled))
            }
        }
    }
    
    private var getLeadingPadding: CGFloat {
        if messageModel.isLocalUser {
            return Constants.localLeadingPadding
        }
        
        if showUsername {
            return Constants.remoteAvatarLeadingPadding
        } else {
            return Constants.remoteLeadingPadding
        }
    }
    
    private func getMessageBubbleBackground(messageModel: ChatMessageInfoModel) -> Color {
        print("getMessageBubbleBackground")
        print(messageModel.isLocalUser)
        guard messageModel.isLocalUser else {
            return Color(StyleProvider.color.surfaceTertiary)
        }
        
        if messageModel.sendStatus == .failed {
            return Color(StyleProvider.color.dangerPrimary).opacity(0.2)
        } else {
            return Color(StyleProvider.color.primaryColorTint30)
        }
    }
}

struct ACSDocumentView: UIViewControllerRepresentable {
    
    var url : String!
    
    init(url: String!) {
        self.url = url
    }
    
    func makeUIViewController(context: Context) -> ACSDocumentViewController {
        let vc = ACSDocumentViewController()
        vc.url = self.url;
        return vc
    }
    
    func updateUIViewController(_ uiViewController: ACSDocumentViewController, context: Context) {
        // Updates the state of the specified view controller with new information from SwiftUI.
    }
}

class ACSDocumentViewController : UIViewController{
    
    var url:String!
    
    var webView: CustomWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startDocumentViewComposite()
    }
    
    @objc private func startDocumentViewComposite() {
        
        let size = CGRect(x: 0, y: 0, width: TextMessageView.documentViewWidth, height: TextMessageView.documentViewHeight)
        let url = URL(string: self.url)!
        
        if self.url.lowercased().contains("jpeg")
            || self.url.lowercased().contains("jpg")
            || self.url.lowercased().contains("png")
            || self.url.lowercased().contains("heic"){
            // Fetch Image Data
            // Create Data Task
            let dataTask = URLSession.shared.dataTask(with: url) { [weak self] (data, _, _) in
                if let imgData = data {
                    // Create Image and Update Image View
                    DispatchQueue.main.async {
                        let uiImage = UIImage(data: imgData)
                        let imageView = UIImageView(image: uiImage)
                        imageView.frame = size
                        imageView.contentMode = .scaleAspectFit
                        imageView.startAnimating()
                        self?.view.addSubview(imageView)
                    }
                }
            }
            // Start Data Task
            dataTask.resume()
        } else {
            let urlRequest = URLRequest(url: url)
            webView = CustomWebView(frame: size)
            webView.load(urlRequest)
            self.view.addSubview(webView)
        }
    }
    
    @objc func onBackBtnPressed() {
        self.dismiss(animated: true, completion: nil)
    }
}

class CustomWebView: WKWebView {
    
    init(frame: CGRect) {
        let configuration = WKWebViewConfiguration()
        super.init(frame: frame, configuration: configuration)
        self.scrollView.showsHorizontalScrollIndicator = false;
        self.scrollView.showsVerticalScrollIndicator = false;
        self.navigationDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return self.scrollView.contentSize
    }
}

extension CustomWebView: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        //To hide page count in PDF
        //if condiation not hanlded other than pdf views are hiding/not displying
        //        if webView.url?.pathExtension == "pdf" || webView.url?.pathExtension == "PDF" {
        //            hidePDFPageCount(webView)
        //        }
        webView.evaluateJavaScript("document.readyState", completionHandler: { (_, _) in
            webView.invalidateIntrinsicContentSize()
        })
        webView.evaluateJavaScript("document.querySelector('.HeaderWrapper').remove();", completionHandler: { (response, error) -> Void in
        })
    }
    
    func hidePDFPageCount(_ webView: WKWebView){
        guard let last = webView.subviews.last else {
            return
        }
        last.isHidden = true
    }
}
