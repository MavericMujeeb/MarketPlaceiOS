//
//  DashboardViewController.swift
//  InView
//
//  Created by Balaji Babu Modugumudi on 25/10/22.
//

import Foundation
import UIKit
import Flutter
import FluentUI
import PIPKit


class PortraitOnlyNavController: UINavigationController {

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override var shouldAutorotate: Bool { false }
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation { .portrait }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }
}

class DashboardViewController : UIViewController {
    
    lazy var tabController = UITabBarController()
    
    var handleExternalLinks: Bool!
    var meetingLink : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        self.view.backgroundColor = .white
        self.buildView()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        if(handleExternalLinks == true){
            let teamsCallingViewController = TeamsCallingViewController()
            teamsCallingViewController.teamsLink = self.meetingLink
            teamsCallingViewController.startCall()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if(handleExternalLinks == true) {
            handleExternalLinks = false
            meetingLink=""
        }
    }

    @objc func appMovedToForeground() {        
        if(tabController.selectedIndex == 2){
            tabController.setTabBar(hidden: true, animated: false)
        }
    }
    
    func buildView(){
        createTabs()
        let navController = UINavigationController.init(rootViewController: tabController)
        navController.navigationBar.isHidden = true
        self.view.addSubview(navController.view)
    }
    
    func customizeNavBar(navCon:UINavigationController){
        let logoImageView = UIImageView.init()
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.contentMode =  UIView.ContentMode.scaleAspectFit
            
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
        tabController.tabBar.unselectedItemTintColor = .black
        
        let homeViewController = HomeViewController(nibName: nil, bundle: nil)
        homeViewController.title = "Accounts"
        
        // Create a reference to the the appropriate storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        // Instantiate the desired view controller from the storyboard using the view controllers identifier
        // Cast is as the custom view controller type you created in order to access it's properties and methods
        let dashViewController = storyboard.instantiateViewController(withIdentifier: "DashView") as! DashViewController
        dashViewController.title = "Accounts"
        
        
        let browseViewController = SearchViewController(nibName: nil, bundle: nil)
        browseViewController.title = "Payments"
        
        let serviceViewController = SearchViewController(nibName: nil, bundle: nil)
        serviceViewController.title = "Services"
        
        //Loading Market place tab from Flutter Module
        let flutterEngine = (UIApplication.shared.delegate as! AppDelegate).flutterEngine
        let flutterViewController = (UIApplication.shared.delegate as! AppDelegate).controller as FlutterViewController
//        let flutterViewController = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)

        flutterViewController.title = "Contact"
        flutterViewController.tabBarController?.hidesBottomBarWhenPushed = true
        
        let profileViewController = ProfileViewController(nibName: nil, bundle: nil)
        profileViewController.title = "Profile"
        
        tabController.viewControllers = [dashViewController, browseViewController, serviceViewController, flutterViewController];
        
        tabController.tabBar.items?[0].image =  UIImage.init(named: "accounts");
        tabController.tabBar.items?[1].image =  UIImage.init(named: "payments");
        
        tabController.tabBar.items?[2].image =  UIImage.init(named: "services");
        tabController.tabBar.items?[3].image =  UIImage.init(named: "chat");
        tabController.tabBar.backgroundColor = .white;
        tabController.tabBar.tintColor = UIColor.init(named: "theme-blue");
        
    }
}

extension DashboardViewController : UITabBarControllerDelegate{
    
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = tabBarController.viewControllers?.firstIndex(of: viewController)
        if(index == 1 || index == 2){
            return false
        }
        return true
    }
    
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
