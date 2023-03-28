//
//  DashboardViewController.swift
//  InView
//
//  Created by Balaji Babu Modugumudi on 25/10/22.
//

import Foundation
import UIKit
import Flutter

class DashboardViewController : UIViewController {
    
    lazy var tabController = UITabBarController()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        self.view.backgroundColor = .white
        self.buildView()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    @objc func appMovedToForeground() {        
        if(tabController.selectedIndex == 2){
            tabController.setTabBar(hidden: true, animated: false)
        }
    }
    
    func buildView(){
        createTabs()
        let navController = UINavigationController.init(rootViewController: tabController)
        navController.navigationBar.backgroundColor = .black
        
        customizeNavBar(navCon: navController)
        
        self.view.addSubview(navController.view)
    }
    
    func customizeNavBar(navCon:UINavigationController){
        let logoImageView = UIImageView.init()
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.contentMode =  UIView.ContentMode.scaleAspectFit
    
        logoImageView.image = UIImage.init(named: "citiLogo");
        
        let logoBarButtonItem = UIBarButtonItem.init(customView: logoImageView);
        
        let width = self.view.frame.size.width * 0.3;
        let height = width * 178/794;
        
        logoImageView.widthAnchor.constraint(equalToConstant: width).isActive = true;
        logoImageView.heightAnchor.constraint(equalToConstant: height).isActive = true;
        
  
        navCon.navigationBar.topItem?.leftBarButtonItem = logoBarButtonItem;
        
        let trailingButton = UIBarButtonItem.init(customView: UIImageView(image: UIImage(systemName: "line.horizontal.3")))
        navCon.navigationBar.topItem?.rightBarButtonItem = trailingButton;
    }
    
    
    func createTabs (){
        tabController.delegate = self;
        
        let homeViewController = HomeViewController(nibName: nil, bundle: nil)
        homeViewController.title = "Accounts"
        
        let browseViewController = SearchViewController(nibName: nil, bundle: nil)
        browseViewController.title = "Payments"
        
        let serviceViewController = SearchViewController(nibName: nil, bundle: nil)
        serviceViewController.title = "Services"
        
        //Loading Market place tab from Flutter Module
        let flutterEngine = (UIApplication.shared.delegate as! AppDelegate).flutterEngine
        let flutterViewController = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)
        flutterViewController.title = "Marketplace"
        flutterViewController.tabBarController?.hidesBottomBarWhenPushed = true
        
        let profileViewController = ProfileViewController(nibName: nil, bundle: nil)
        profileViewController.title = "Profile"
        
//        let appointmentViewController = ProfileViewController(nibName: nil, bundle: nil)
//        appointmentViewController.title = "Appointments"
        
        //Loading Market place tab from Flutter Module
        let contactCenterFlutterEngine = FlutterEngine(name: "contact_center_flutter_engine")
        contactCenterFlutterEngine.run(withEntrypoint: nil, initialRoute: "/screen_acs_chat_calling")
        
        let contactCenterViewController = FlutterViewController(engine: contactCenterFlutterEngine, nibName: nil, bundle: nil)
        contactCenterViewController.title = "Appointments"
        contactCenterViewController.tabBarController?.hidesBottomBarWhenPushed = true
        
        tabController.viewControllers = [homeViewController, browseViewController, serviceViewController, flutterViewController, contactCenterViewController];
        
        tabController.tabBar.items?[0].image =  UIImage.init(named: "accounts");
        tabController.tabBar.items?[1].image =  UIImage.init(named: "payments");
        
        tabController.tabBar.items?[2].image =  UIImage.init(named: "services");
        tabController.tabBar.items?[3].image =  UIImage.init(named: "apps-icon");
        tabController.tabBar.items?[4].image =  UIImage.init(systemName: "calendar");

        //Disable tabs, which dont have any content.
        tabController.tabBar.items?[1].isEnabled = false;
        tabController.tabBar.items?[2].isEnabled = false;
//        tabController.tabBar.items?[4].isEnabled = false;
        
        tabController.tabBar.backgroundColor = .white;
        tabController.tabBar.tintColor = UIColor.init(named: "theme-blue");
        
    }
}

extension DashboardViewController : UITabBarControllerDelegate{
    
    
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if(tabBarController.selectedIndex == 2){
            tabBarController.setTabBar(hidden: true, animated: false)
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, willBeginCustomizing viewControllers: [UIViewController]) {
        print("willBeginCustomizing")
    }
}


extension UITabBarController {

    /**
     Show or hide the tab bar.
     - Parameter hidden: `true` if the bar should be hidden.
     - Parameter animated: `true` if the action should be animated.
     - Parameter transitionCoordinator: An optional `UIViewControllerTransitionCoordinator` to perform the animation
        along side with. For example during a push on a `UINavigationController`.
     */
    func setTabBar(
        hidden: Bool,
        animated: Bool = true,
        along transitionCoordinator: UIViewControllerTransitionCoordinator? = nil
    ) {
        guard isTabBarHidden != hidden else { return }

        let offsetY = hidden ? tabBar.frame.height : -tabBar.frame.height
        let endFrame = tabBar.frame.offsetBy(dx: 0, dy: offsetY)
        let vc: UIViewController? = viewControllers?[selectedIndex]
        var newInsets: UIEdgeInsets? = vc?.additionalSafeAreaInsets
        let originalInsets = newInsets
        newInsets?.bottom -= offsetY

        /// Helper method for updating child view controller's safe area insets.
        func set(childViewController cvc: UIViewController?, additionalSafeArea: UIEdgeInsets) {
            cvc?.additionalSafeAreaInsets = additionalSafeArea
            cvc?.view.setNeedsLayout()
        }

        // Update safe area insets for the current view controller before the animation takes place when hiding the bar.
        if hidden, let insets = newInsets { set(childViewController: vc, additionalSafeArea: insets) }

        guard animated else {
            tabBar.frame = endFrame
            return
        }

        // Perform animation with coordinato if one is given. Update safe area insets _after_ the animation is complete,
        // if we're showing the tab bar.
        weak var tabBarRef = self.tabBar
        if let tc = transitionCoordinator {
            tc.animateAlongsideTransition(in: self.view, animation: { _ in tabBarRef?.frame = endFrame }) { context in
                if !hidden, let insets = context.isCancelled ? originalInsets : newInsets {
                    set(childViewController: vc, additionalSafeArea: insets)
                }
            }
        } else {
            UIView.animate(withDuration: 0.3, animations: { tabBarRef?.frame = endFrame }) { didFinish in
                if !hidden, didFinish, let insets = newInsets {
                    set(childViewController: vc, additionalSafeArea: insets)
                }
            }
        }
    }

    /// `true` if the tab bar is currently hidden.
    var isTabBarHidden: Bool {
        return !tabBar.frame.intersects(view.frame)
    }

}
