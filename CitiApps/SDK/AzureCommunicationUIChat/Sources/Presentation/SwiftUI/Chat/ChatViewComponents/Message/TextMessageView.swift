//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI
import WebKit
import UniformTypeIdentifiers


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
    
    @State private var showDocView: Bool = false
    
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
//            let _ = print("hi! its a message view and has url")
            if let url =  messageModel.checkContentIsUrl()  {
              
                Text(messageModel.getContentLabel()).foregroundColor(.blue)
                    .underline()
                    .onTapGesture {
                        guard let url = URL(string: String(url)) else { return }
                        UIApplication.shared.open(url)
                    }
                    .font(.body)
                    .contextMenu {
                        Button( action: {
                            UIPasteboard.general.setValue(messageModel.getContentLabel(), forPasteboardType: "public.plain-text")
                        }) {
                            Text("Copy to clipboard")
                            Image(systemName: "doc.on.doc")
                        }
                    }
            }else {
                Text(messageModel.getContentLabel())
                    .font(.body).contextMenu{
                        Button( action: {
                            UIPasteboard.general.setValue(messageModel.getContentLabel(), forPasteboardType: "public.plain-text")
                        }) {
                            Text("Copy to clipboard")
                            Image(systemName: "doc.on.doc")
                        }
                    }
            }
           
        }
    }
    
    var documentview: some View {
        VStack(alignment: .leading) {
            ACSDocumentView(url: messageModel.getAttachmentUrl()!, showFullScreen: false)
        }.padding([.bottom], Constants.contentVerticalPadding)
            .frame(width: TextMessageView.documentViewWidth, height: TextMessageView.documentViewHeight)
            .onTapGesture {
                self.showDocView.toggle()
            }
            .sheet(isPresented: self.$showDocView) {
                VStack(alignment: .leading, spacing: 20) {
                    Spacer()
                    HStack(spacing: 20) {
                        Button(action: self.onBackClicked) {
                            Icon(name: .leftArrow, size: 26.0)
                                .contentShape(Rectangle())
                                .foregroundColor(Color(StyleProvider.color.iconSecondary))
                        }
                        Text(getFileName(fileUrl:messageModel.getAttachmentUrl()!))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.black)
                    }
                    ACSDocumentView(url: messageModel.getAttachmentUrl()!, showFullScreen: true)
                }
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
    
    private func getFileName(fileUrl: String) -> String {
        let splitUrl = fileUrl.components(separatedBy: "/")
        return splitUrl[splitUrl.count-1]
    }
    
    private func onBackClicked() {
        self.showDocView.toggle()
    }
}

struct ACSDocumentView: UIViewControllerRepresentable {
    
    var url : String!
    var showFullScreen: Bool = false
    
    init(url: String!, showFullScreen: Bool = false) {
        self.url = url
        self.showFullScreen = showFullScreen
    }
    
    func makeUIViewController(context: Context) -> ACSDocumentViewController {
        let vc = ACSDocumentViewController()
        vc.url = self.url;
        vc.showFullScreen = self.showFullScreen
        return vc
    }
    
    func updateUIViewController(_ uiViewController: ACSDocumentViewController, context: Context) {
        // Updates the state of the specified view controller with new information from SwiftUI.
    }
}

class ACSDocumentViewController : UIViewController{
    
    var url:String!
    
    var showFullScreen: Bool!
    
    var webView: CustomWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startDocumentViewComposite()
    }
    
    @objc private func startDocumentViewComposite() {
        var viewWidth = TextMessageView.documentViewWidth
        var viewHeight = TextMessageView.documentViewHeight
        
        if self.showFullScreen {
            viewWidth =  UIScreen.main.bounds.size.width
            viewHeight = UIScreen.main.bounds.size.height
        }
        let size = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        let url = URL(string: self.url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))!
        if self.url.lowercased().contains("jpeg")
            || self.url.lowercased().contains("jpg")
            || self.url.lowercased().contains("png")
            || self.url.lowercased().contains("heic"){
            // Fetch Image Data
            // Create Data Task
            let imageView = UIImageView()
            imageView.downloadImage(with: self.url, contentMode: UIView.ContentMode.scaleAspectFit)
            imageView.frame = size
            self.view.addSubview(imageView)
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

extension UIImageView {
    
    func downloadImage(with url: String, contentMode: UIView.ContentMode) {
        let activityIndicator = self.activityIndicator
        DispatchQueue.main.async {
            activityIndicator.startAnimating()
        }
        guard let nsUrl = NSURL(string: url) else {return}
        URLSession.shared.dataTask(with: nsUrl as URL, completionHandler: {
            (data, response, error) -> Void in
            DispatchQueue.main.async {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
                self.contentMode =  contentMode
                if let data = data, let imageData = UIImage(data: data) {
                    self.image = imageData
                }
            }
        }).resume()
    }
}

extension UIView {
    var activityIndicator: UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.black
        self.addSubview(activityIndicator)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        let centerX = NSLayoutConstraint(item: self,
                                         attribute: .centerX,
                                         relatedBy: .equal,
                                         toItem: activityIndicator,
                                         attribute: .centerX,
                                         multiplier: 1,
                                         constant: 0)
        let centerY = NSLayoutConstraint(item: self,
                                         attribute: .centerY,
                                         relatedBy: .equal,
                                         toItem: activityIndicator,
                                         attribute: .centerY,
                                         multiplier: 1,
                                         constant: 0)
        self.addConstraints([centerX, centerY])
        return activityIndicator
    }
}
