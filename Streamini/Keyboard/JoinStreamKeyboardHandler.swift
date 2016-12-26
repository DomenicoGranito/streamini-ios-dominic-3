//
//  JoinStreamKeyboardHandler.swift
//  Streamini
//
//  Created by Vasily Evreinov on 30/07/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

class JoinStreamKeyboardHandler: NSObject {
    var view: UIView
    var messageTextView: UITextView
    var commentsTableView: UITableView
    var commentsTableViewHeight: NSLayoutConstraint
    var viewersCollectionViewHeight: NSLayoutConstraint
    var messageViewBottomConstraint: NSLayoutConstraint
    var viewersLabelBottomConstraint: NSLayoutConstraint
    var messageTextViewRightConstraint: NSLayoutConstraint
    var viewersLabel: UILabel
    var eyeButton: UIButton
    var isRecent = false
    
    init(
            view: UIView,
            messageTextView: UITextView,
            commentsTableView: UITableView,
            commentsTableViewHeight: NSLayoutConstraint,
            viewersCollectionViewHeight: NSLayoutConstraint,
            messageViewBottomConstraint: NSLayoutConstraint,
            messageTextViewRightConstraint: NSLayoutConstraint,
            viewersLabelBottomConstraint: NSLayoutConstraint,
            viewersLabel: UILabel,
            eyeButton: UIButton,
            isRecent: Bool
        )
    {
        self.view                           = view
        self.messageTextView                = messageTextView
        self.commentsTableView              = commentsTableView
        self.commentsTableViewHeight        = commentsTableViewHeight
        self.viewersCollectionViewHeight    = viewersCollectionViewHeight
        self.messageViewBottomConstraint    = messageViewBottomConstraint
        self.viewersLabelBottomConstraint   = viewersLabelBottomConstraint
        self.messageTextViewRightConstraint = messageTextViewRightConstraint
        self.viewersLabel                   = viewersLabel
        self.eyeButton                      = eyeButton
        self.isRecent                       = isRecent
        super.init()
    }
    
    func register() {
        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: #selector(JoinStreamKeyboardHandler.keyboardWillBeShown(_:)), name: "UIKeyboardWillShowNotification", object: nil)
        
        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: #selector(JoinStreamKeyboardHandler.keyboardWillHide(_:)), name: "UIKeyboardWillHideNotification", object: nil)
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
        
        let h = commentsTableViewHeight.constant - keyboardFrame.size.height + commentsTableView.frame.origin.y/2
        
        while commentsTableView.visibleCells.count > 0 && !isLastRowFit(h) {
            let indexPath = NSIndexPath(forRow: commentsTableView.visibleCells.count-1, inSection: 0)
            removeCommentAt(indexPath)
        }
        
        UIView.animateWithDuration(duration, animations: { () -> Void in
            self.messageTextView.backgroundColor = UIColor(white: 1.0, alpha: 0.7)
            let viewersHeight = self.viewersCollectionViewHeight.constant
            self.commentsTableViewHeight.constant        = h
            self.messageViewBottomConstraint.constant    = keyboardFrame.size.height + 8 - viewersHeight
            self.viewersLabelBottomConstraint.constant   = keyboardFrame.size.height + 8 - viewersHeight
            if !self.isRecent {
                self.messageTextViewRightConstraint.constant = 8.0
            }
            self.viewersLabel.alpha                      = 0.0
            self.eyeButton.alpha                         = 0.0
            self.view.layoutIfNeeded()
        })
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let tmp : [NSObject : AnyObject] = notification.userInfo!
        let duration : NSTimeInterval = tmp[UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
        
        UIView.animateWithDuration(duration, animations: { () -> Void in
            self.messageTextView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
            self.commentsTableViewHeight.constant        = 360
            self.messageViewBottomConstraint.constant    = 8.0
            self.viewersLabelBottomConstraint.constant   = 8.0
            if !self.isRecent {
                self.messageTextViewRightConstraint.constant = 43.0
            }
            self.viewersLabel.alpha                      = 1.0
            self.eyeButton.alpha                         = 1.0
            self.view.layoutIfNeeded()
        })
    }
    
    private func isLastRowFit(tableViewHeight: CGFloat) -> Bool {
        let cellsCount = commentsTableView.visibleCells.count
        if cellsCount == 0 {
            return false
        }
        
        let dataSource = commentsTableView.dataSource as! CommentsDataSource
        var height: CGFloat = 0.0
        
        
        for var i = 0; i < cellsCount; i += 1 {
        
        //for i in 0 ..< cellsCount += 1 {
            let indexPath = NSIndexPath(forRow: i, inSection: 0)
            let cellHeight = dataSource.calculateHeight(commentsTableView, indexPath: indexPath)
            height += cellHeight
        }
        
        return height < tableViewHeight
    }
    
    private func removeCommentAt(indexPath: NSIndexPath) {
        let dataSource = commentsTableView.dataSource as! CommentsDataSource
        dataSource.removeCommentAt(indexPath.row)
        commentsTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
    }
}
