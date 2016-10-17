//
//  CreateStreamKeyboardHandler.swift
//  Streamini
//
//  Created by Vasily Evreinov on 30/07/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

class CreateStreamKeyboardHandler: NSObject {
    var view: UIView
    var constraint: NSLayoutConstraint
    var pickerConstraint: NSLayoutConstraint
    
    init(view: UIView, constraint: NSLayoutConstraint, pickerConstraint: NSLayoutConstraint) {
        self.view           = view
        self.constraint     = constraint
        self.pickerConstraint = pickerConstraint
        super.init()
    }
    
    func register() {
        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: #selector(CreateStreamKeyboardHandler.keyboardWillBeShown(_:)), name: "UIKeyboardWillShowNotification", object: nil)
        
        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: #selector(CreateStreamKeyboardHandler.keyboardWillHide(_:)), name: "UIKeyboardWillHideNotification", object: nil)
    }
    
    func unregister() {
        NSNotificationCenter.defaultCenter()
            .removeObserver(self, name: "UIKeyboardWillShowNotification", object: nil)
        
        NSNotificationCenter.defaultCenter()
            .removeObserver(self, name: "UIKeyboardWillHideNotification", object: nil)
    }
    
    func keyboardWillBeShown(notification: NSNotification) {
        let tmp : [NSObject : AnyObject] = notification.userInfo!
        let duration : NSTimeInterval = tmp[UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
        let keyboardFrame : CGRect = (tmp[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.constraint.constant = keyboardFrame.size.height + 10
            self.pickerConstraint.constant = -216.0
            self.view.layoutIfNeeded()
        })
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let tmp : [NSObject : AnyObject] = notification.userInfo!
        let duration : NSTimeInterval = tmp[UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
        let keyboardFrame : CGRect = (tmp[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.constraint.constant = 240
            self.view.layoutIfNeeded()
        })
    }
}
