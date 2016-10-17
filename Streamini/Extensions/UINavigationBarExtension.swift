//
//  UINavigationBarExtension.swift
//  Streamini
//
//  Created by Vasily Evreinov on 29/09/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import Foundation

extension UINavigationBar {
    
    class func setCustomAppereance() {
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().setBackgroundImage(UIImage(named: "nav-background"), forBarMetrics: UIBarMetrics.Default)
        UINavigationBar.appearance().shadowImage = UIImage(named: "nav-border")
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
    }
    
    class func resetCustomAppereance() {
        UINavigationBar.appearance().tintColor = nil
        UINavigationBar.appearance().setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        UINavigationBar.appearance().shadowImage = nil
        UINavigationBar.appearance().titleTextAttributes = nil
    }
}