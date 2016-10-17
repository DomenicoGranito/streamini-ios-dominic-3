//
//  UIActionSheetExtensions.swift
//  Streamini
//
//  Created by Vasily Evreinov on 24/07/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

extension UIActionSheet {
    class func shareActionSheet(delegate: UIActionSheetDelegate) -> UIActionSheet {
        let shareActionSheetTitle   = NSLocalizedString("share_actionsheet_title", comment: "")
        let cancel                  = NSLocalizedString("cancel", comment: "")
        let allFollowers            = NSLocalizedString("share_all_followers", comment: "")
        let selectFollowers         = NSLocalizedString("select_followers", comment: "")
        
        let actionSheet = UIActionSheet(title: shareActionSheetTitle, delegate: delegate, cancelButtonTitle: cancel, destructiveButtonTitle: nil)
        actionSheet.addButtonWithTitle(allFollowers)
        actionSheet.addButtonWithTitle(selectFollowers)
        
        return actionSheet
    }
    
    class func changeUserpicActionSheet(delegate: UIActionSheetDelegate) -> UIActionSheet {
        let actionSheetTitle = NSLocalizedString("profile_userpic_actionsheet_title", comment: "")
        let camera = NSLocalizedString("profile_userpic_camera", comment: "")
        let gallery = NSLocalizedString("profile_userpic_gallery", comment: "")
        let cancel = NSLocalizedString("cancel", comment: "")
        
        let actionSheet = UIActionSheet(title: actionSheetTitle, delegate: delegate, cancelButtonTitle: cancel, destructiveButtonTitle: nil)
        actionSheet.addButtonWithTitle(gallery)
        actionSheet.addButtonWithTitle(camera)
        
        return actionSheet
    }
    
    class func confirmLogoutActionSheet(delegate: UIActionSheetDelegate) -> UIActionSheet {
        let actionSheetTitle = NSLocalizedString("profile_logout_actionsheet_title", comment: "")
        let yes     = NSLocalizedString("yes", comment: "")
        let cancel  = NSLocalizedString("cancel", comment: "")
        
        let actionSheet = UIActionSheet(title: actionSheetTitle, delegate: delegate, cancelButtonTitle: cancel, destructiveButtonTitle: yes)
        
        return actionSheet
    }
}