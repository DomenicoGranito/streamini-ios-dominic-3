//
//  BaseViewController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 22/06/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    func handleError(error: NSError) {
        if let userInfo = error.userInfo as? [NSObject: NSObject] {
            // modify and assign values as necessary
            if userInfo["code"] == Error.kLoginExpiredCode {
                
                // Open login screen
                let root = UIApplication.sharedApplication().delegate!.window!?.rootViewController as! UINavigationController
                
                if root.topViewController!.presentedViewController != nil {
                    root.topViewController!.presentedViewController!.dismissViewControllerAnimated(true, completion: nil)
                }
                
                let controllers = root.viewControllers.filter({ ($0 is LoginViewController) })
                root.setViewControllers(controllers, animated: true)
                
                // Show alert
                let message = userInfo[NSLocalizedDescriptionKey] as! String
                let alertView = UIAlertView.notAuthorizedAlert(message)
                alertView.show()
            } else {
                let message = userInfo[NSLocalizedDescriptionKey] as! String
                let alertView = UIAlertView.notAuthorizedAlert(message)
                alertView.show()
            }
        }
    }
}
