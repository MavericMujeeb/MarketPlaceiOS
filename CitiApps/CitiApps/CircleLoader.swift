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

    let indicator: UIActivityIndicatorView? = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)

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
        indicator?.frame = CGRect(x: 0.0, y: 0.0, width: 60.0, height: 60.0)
        indicator?.frame.origin.x = (screen.width/2 - 20)
        indicator?.frame.origin.y = (screen.height/2 - 20)
        rootController?.view.addSubview(indicator!)
        indicator?.startAnimating()
    }
    
    func hide() {
        DispatchQueue.main.async {
            self.indicator?.stopAnimating()
            self.indicator?.removeFromSuperview()
        }
    }
}
