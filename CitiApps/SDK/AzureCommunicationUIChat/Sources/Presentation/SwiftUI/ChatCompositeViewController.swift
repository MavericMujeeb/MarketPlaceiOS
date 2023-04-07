//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import Combine
import SwiftUI

public let myNotificationName = Notification.Name("com.example.startChat")




/// The Chat Composite View Controller is a view component for a single chat thread
public class ChatCompositeViewController: UIViewController {
    var chatView: UIHostingController<ContainerView>!

    /// Create an instance of ChatCompositeViewController with chatAdapter for a single chat thread
    /// - Parameters:
    ///    - chatAdapter: The required parameter to create a view component
    public init(with chatAdapter: ChatAdapter ) {
        super.init(nibName: nil, bundle: nil)
      
        let containerUIHostingController = makeContainerUIHostingController(
            viewFactory: chatAdapter.compositeViewFactory!,
            canDismiss: true)

        addChild(containerUIHostingController)
        
        let closeItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(self.onBackBtnPressed(_ :))
        )
        
        let audioCallBtn = UIButton(type: .custom)
        audioCallBtn.setImage(UIImage(named: "voicecall"), for: .normal)
        audioCallBtn.addTarget(self, action: #selector(self.onCallBtnPressed(_:)), for: .touchUpInside)
        let videoCallBtn = UIButton(type: .custom)
        videoCallBtn.setImage(UIImage(named: "videocall"), for: .normal)
        videoCallBtn.addTarget(self, action: #selector(self.onCallBtnPressed(_:)), for: .touchUpInside)
        let audioCallItem = UIBarButtonItem.init(customView: audioCallBtn)
        let videoCallItem = UIBarButtonItem.init(customView: videoCallBtn)
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            fixedSpace.width = 20
        
        self.title = "Chat"
        self.navigationItem.leftBarButtonItem = closeItem
        self.navigationItem.rightBarButtonItems = [videoCallItem,fixedSpace,audioCallItem]

        self.view.addSubview(containerUIHostingController.view)
        containerUIHostingController.view.frame = view.bounds
        containerUIHostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerUIHostingController.didMove(toParent: self)
    }
    
   

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func onBackBtnPressed (_ sender: UIBarButtonItem){
        self.dismiss(animated: true, completion: nil)
    }
    @objc func onCallBtnPressed (_ sender: UIBarButtonItem){
        print("Call btn pressed")
        NotificationCenter.default.post(name: myNotificationName, object: nil, userInfo: nil)
    }
    

    func makeContainerUIHostingController(viewFactory: CompositeViewFactoryProtocol,
                                          canDismiss: Bool) -> ContainerUIHostingController {
        let rootView = ContainerView(viewFactory: viewFactory)
        let containerUIHostingController = ContainerUIHostingController(rootView: rootView)
        containerUIHostingController.modalPresentationStyle = .fullScreen

        return containerUIHostingController
    }
    
}



