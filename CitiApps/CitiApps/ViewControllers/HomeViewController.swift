//
//  HomeViewController.swift
//  in_view
//
//  Created by Balaji Babu Modugumudi on 17/10/22.
//

import UIKit

class HomeViewController : UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        let imageHolder = UIImageView.init(frame: CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height - 200))

        let bgimage = UIImage.init(named: "dashboard")
        imageHolder.image = bgimage;
        self.view.addSubview(imageHolder);
    }
}
