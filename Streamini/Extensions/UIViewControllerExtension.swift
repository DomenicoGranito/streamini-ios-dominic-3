//
//  UIViewControllerExtension.swift
//  Streamini
//
//  Created by Vasily Evreinov on 30/07/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showUserInfo(user: User, userStatusDelegate: UserStatusDelegate?) {
        let kHeight: CGFloat            = 410.0
        let kHorizontalMargins: CGFloat = 20.0
        let kCornerRadius: CGFloat      = 8.0
        let sheetSize = CGSizeMake(UIScreen.mainScreen().bounds.width - kHorizontalMargins * 2, kHeight)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("UserViewControllerId") as! UserViewController
        controller.user = user
        controller.userStatusDelegate = userStatusDelegate
        
        let formSheet = MZFormSheetController(viewController: controller)
        formSheet.shouldDismissOnBackgroundViewTap = true
        formSheet.presentedFormSheetSize    = sheetSize
        formSheet.transitionStyle           = MZFormSheetTransitionStyle.SlideFromBottom
        formSheet.cornerRadius              = kCornerRadius
        formSheet.portraitTopInset          = UIScreen.mainScreen().bounds.height - kHeight
        formSheet.shadowOpacity             = 0.0
        formSheet.shadowRadius              = 0.0
        
        formSheet.presentAnimated(true, completionHandler: { (controller) -> Void in
            (controller as! UserViewController).originalViewFrame     = controller.view.frame
            (controller as! UserViewController).originalFormSheetSize = controller.formSheetController!.presentedFormSheetSize
        })
    }
}