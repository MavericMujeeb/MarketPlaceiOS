//
//  CircleLoader.swift
//  CitiApps
//
//  Created by Mohamad Mujeeb Urahaman on 07/02/23.
//

import Foundation
import UIKit

class CircleLoader: NSObject {
    
    static let sharedInstance = CircleLoader()
    
    let indicator: UIActivityIndicatorView? = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
    
    let screen = UIScreen.main.bounds
    
    var appDelegate: SceneDelegate {
        guard let sceneDelegate = UIApplication.shared.connectedScenes
            .first!.delegate as? SceneDelegate else {
            fatalError("sceneDelegate is not UIApplication.shared.delegate")
        }
        return sceneDelegate
    }
    
    var rootController:UIViewController? {
        guard let viewController = appDelegate.window?.rootViewController else {
            fatalError("There is no root controller")
        }
        return viewController
    }
    
    func show() {
        DispatchQueue.main.async {
            self.indicator?.frame = CGRect(x: 0.0, y: 0.0, width: 60.0, height: 60.0)
            self.indicator?.frame.origin.x = (self.screen.width/2 - 20)
            self.indicator?.frame.origin.y = (self.screen.height/2 - 20)
            self.rootController?.view.addSubview(self.indicator!)
            self.indicator?.startAnimating()
        }
    }
    
    func hide() {
        DispatchQueue.main.async {
            self.indicator?.stopAnimating()
            self.indicator?.removeFromSuperview()
        }
    }
}
