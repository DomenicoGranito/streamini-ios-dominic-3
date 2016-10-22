//
//  UserViewController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 30/07/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

protocol UserSelecting: class {
    func userDidSelected(user: User)
}

protocol StreamSelecting: class {
    func streamDidSelected(stream: Stream)
}

protocol UserStatisticsDelegate: class {
    func recentStreamsDidSelected(userId: UInt)
    func followersDidSelected(userId: UInt)
    func followingDidSelected(userId: UInt)
}

protocol UserStatusDelegate: class {
    func followStatusDidChange(status: Bool, user: User)
    func blockStatusDidChange(status: Bool, user: User)
}

class UserViewController: BaseViewController, UserHeaderViewDelegate, ProfileDelegate {
    static let animationDuration = 0.2
    
    @IBOutlet weak var userHeaderView: UserHeaderView!
    @IBOutlet weak var recentCountLabel: UILabel!
    @IBOutlet weak var recentLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var blockButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!
    
    var user: User?
    var userStatisticsDelegate: UserStatisticsDelegate?
    var userStatusDelegate: UserStatusDelegate?
    
    var originalViewFrame     = CGRectZero
    var originalFormSheetSize = CGSizeZero
    
    // MARK: - Actions
    
    @IBAction func recentButtonPressed(sender: AnyObject) {
        expandFormSheet()
        userHeaderView.showCompactMode()
        
        if let del = userStatisticsDelegate {
            del.recentStreamsDidSelected(user!.id)
        }
    }
    
    @IBAction func followersButtonPressed(sender: AnyObject) {
        expandFormSheet()
        userHeaderView.showCompactMode()
        
        if let del = userStatisticsDelegate {
            del.followersDidSelected(user!.id)
        }
    }
    
    @IBAction func followingButtonPressed(sender: AnyObject) {
        expandFormSheet()        
        userHeaderView.showCompactMode()
        
        if let del = userStatisticsDelegate {
            del.followingDidSelected(user!.id)
        }
    }
    
    @IBAction func followButtonPressed(sender: AnyObject) {
        followButton.enabled = false
        if user!.isFollowed {
            SocialConnector().unfollow(user!.id, success: unfollowSuccess, failure: unfollowFailure)
        } else {
            SocialConnector().follow(user!.id, success: followSuccess, failure: followFailure)
        }
    }
    
    @IBAction func blockButtonPressed(sender: AnyObject) {
        blockButton.enabled = false
        if user!.isBlocked {
            SocialConnector().unblock(user!.id, success: unblockSuccess, failure: unblockFailure)
        } else {
            SocialConnector().block(user!.id, success: blockSuccess, failure: blockFailure)
        }
    }
    
    // MARK: - ProfileDelegate
    
    func reload() {
        update(user!.id)
    }
    
    func close() {
        self.closeButtonPressed(self)
    }
    
    // MARK: - UserHeaderViewDelegate
    
    func closeButtonPressed(sender: AnyObject) {
        self.mz_dismissFormSheetControllerAnimated(true, completionHandler: { (formSheetController) -> Void in
            self.changeVisibility(hide: true, animated: false)
        })
    }
    
    func usernameLabelPressed() {
        fallFormSheet()
        userHeaderView.showFullMode()
    }
    
    func descriptionWillStartEdit() {
    }
    
    // MARK: - View life cycle
    
    func configureView() {
        changeVisibility(hide: true, animated: false)
        userHeaderView.delegate = self
        
        let recentLabelText = NSLocalizedString("user_card_recent", comment: "")
        recentLabel.text = recentLabelText
        
        let followersLabelText = NSLocalizedString("user_card_followers", comment: "")
        followersLabel.text = followersLabelText
        
        let followingLabelText = NSLocalizedString("user_card_following", comment: "")
        followingLabel.text = followingLabelText
        
        followButton.hidden = UserContainer.shared.logged().id == user!.id
        blockButton.hidden  = UserContainer.shared.logged().id == user!.id
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        configureView()
        update(user!.id)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let sid = segue.identifier {
            if sid == "UserToLinkedUsers" {
                let controller = segue.destinationViewController as! LinkedUsersViewController
                controller.profileDelegate = self
                self.userStatisticsDelegate = controller
            }
        }
    }
    
    // MARK: - Network communication
    
    func followSuccess() {
        followButton.enabled = true
        user!.isFollowed = true
        let buttonTitle = NSLocalizedString("user_card_unfollow", comment: "")
        followButton.setTitle(buttonTitle, forState: UIControlState.Normal)
        
        if let delegate = userStatusDelegate {
            delegate.followStatusDidChange(true, user: user!)
        }
        
        update(user!.id)
    }
    
    func followFailure(error: NSError) {
        handleError(error)
        followButton.enabled = true
    }
    
    func unfollowSuccess() {
        followButton.enabled = true
        user!.isFollowed = false
        let buttonTitle = NSLocalizedString("user_card_follow", comment: "")
        followButton.setTitle(buttonTitle, forState: UIControlState.Normal)
        
        if let delegate = userStatusDelegate {
            delegate.followStatusDidChange(false, user: user!)
        }
        
        update(user!.id)
    }
    
    func unfollowFailure(error: NSError) {
        handleError(error)
        followButton.enabled = true
    }
    
    func blockSuccess() {
        blockButton.enabled = true
        user!.isBlocked = true
        let buttonTitle = NSLocalizedString("user_card_unblock", comment: "")
        blockButton.setTitle(buttonTitle, forState: UIControlState.Normal)
        
        if let delegate = userStatusDelegate {
            delegate.blockStatusDidChange(true, user: user!)
        }
    }
    
    func blockFailure(error: NSError) {
        handleError(error)
        blockButton.enabled = true
    }
    
    func unblockSuccess() {
        blockButton.enabled = true
        user!.isBlocked = false
        let buttonTitle = NSLocalizedString("user_card_block", comment: "")
        blockButton.setTitle(buttonTitle, forState: UIControlState.Normal)
        
        if let delegate = userStatusDelegate
        {
            delegate.blockStatusDidChange(false, user: user!)
        }
    }
    
    func unblockFailure(error: NSError)
    {
        handleError(error)
        blockButton.enabled = true
    }
    
    // MARK: - Update user
    
    func getUserSuccess(user: User)
    {
        self.user = user
        
        userHeaderView.update(user)
        recentCountLabel.text       = "\(user.recent)"
        followersCountLabel.text    = "\(user.followers)"
        followingCountLabel.text    = "\(user.following)"
        
        if user.isFollowed {
            let buttonTitle = NSLocalizedString("user_card_unfollow", comment: "")
            followButton.setTitle(buttonTitle, forState: UIControlState.Normal)
        } else {
            let buttonTitle = NSLocalizedString("user_card_follow", comment: "")
            followButton.setTitle(buttonTitle, forState: UIControlState.Normal)
        }
        
        if user.isBlocked {
            let buttonTitle = NSLocalizedString("user_card_unblock", comment: "")
            blockButton.setTitle(buttonTitle, forState: UIControlState.Normal)
        } else {
            let buttonTitle = NSLocalizedString("user_card_block", comment: "")
            blockButton.setTitle(buttonTitle, forState: UIControlState.Normal)
        }
        
        activityIndicator.stopAnimating()
        changeVisibility(hide: false, animated: true)        
    }
    
    func getUserFailure(error: NSError)
    {
        handleError(error)
        activityIndicator.stopAnimating()
    }
    
    func update(userId: UInt)
    {
        activityIndicator.startAnimating()
        UserConnector().get(userId, success: getUserSuccess, failure: getUserFailure)
    }
    
    // MARK: - Private methods
    
    private func expandFormSheet() {
        let formSheetController = self.formSheetController!
        
        // calculate new size
        let size = formSheetController.presentedFormSheetSize
        let height = UIScreen.mainScreen().bounds.height - 10.0 // new height
        formSheetController.presentedFormSheetSize = CGSizeMake(size.width, height)
        
        // animatable update formsheet size
        UIView.animateWithDuration(UserViewController.animationDuration, animations: { () -> Void in
            let x       = self.view.frame.origin.x
            let y       = CGFloat(25.0)
            let width   = self.view.frame.size.width
            self.view.frame = CGRectMake(x, y, width, height)
            self.containerViewHeight.constant = height - UserHeaderViewHeight.Compact.rawValue - 102.0
            self.view.layoutIfNeeded()
        })
    }
    
    private func fallFormSheet() {
        // animatable update formsheet size
        UIView.animateWithDuration(UserViewController.animationDuration, animations: { () -> Void in
            self.formSheetController!.presentedFormSheetSize = self.originalFormSheetSize
            self.view.frame = self.originalViewFrame
            self.containerViewHeight.constant = 0.0
            self.view.layoutIfNeeded()
        })
    }
    
    private func changeVisibility(hide hide: Bool, animated: Bool) {
        let alpha: CGFloat = hide ? 0.0 : 1.0
        let duration = (animated) ? 0.3 : 0.0
        
        UIView.animateWithDuration(duration, animations: { () -> Void in
            self.userHeaderView.alpha       = alpha
            self.recentCountLabel.alpha     = alpha
            self.recentLabel.alpha          = alpha
            self.followersCountLabel.alpha  = alpha
            self.followersLabel.alpha       = alpha
            self.followingCountLabel.alpha  = alpha
            self.followingLabel.alpha       = alpha
            self.followButton.alpha         = alpha
            self.blockButton.alpha          = alpha
        })
    }
}
