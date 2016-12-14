//
//  JoinStreamViewController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 14/07/15.
//  Copyright (c) 2015 Evghenii Todorov. All rights reserved.
//

class JoinStreamViewController: BaseViewController, UITextFieldDelegate, UITableViewDelegate, UIAlertViewDelegate,
UIActionSheetDelegate, SelectFollowersDelegate, ReplayViewDelegate, UserSelecting, CollectionViewPullDelegate {
    @IBOutlet weak var infoView: InfoView!
    
    @IBOutlet weak var playerView: PlayerView!
    
    @IBOutlet weak var replayView: ReplayView!
    
    @IBOutlet weak var closeButton: SensibleButton!
    @IBOutlet weak var infoButton: SensibleButton!
    @IBOutlet weak var eyeButton: SensibleButton!
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var likeView: UIView!
    
    @IBOutlet weak var viewersLabel: UILabel!
    @IBOutlet weak var viewersLabelBottomConstraint: NSLayoutConstraint!    // 8 by default
    
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var messageTextViewRightConstraint: NSLayoutConstraint! // 43 by default
    @IBOutlet weak var messageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageViewBottomConstraint: NSLayoutConstraint!     // 8 by default
    
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var commentsTableViewHeight: NSLayoutConstraint!     // 360 by default
    @IBOutlet weak var viewersCollectionViewHeight: NSLayoutConstraint! // 58 by default
    @IBOutlet weak var viewersCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var likesViewBottom: NSLayoutConstraint! // 16
    @IBOutlet weak var viewersBottom: NSLayoutConstraint! // 16
    @IBOutlet weak var replaysBottom: NSLayoutConstraint! // 16
    
    var commentsDataSource  = CommentsDataSource()
    var viewersDataSource   = ViewersDataSource()
    var viewersDelegate     = ViewersDelegate()
    let animator            = HeartBounceAnimator()
    var likes: UInt         = 0
    var isRecent            = true
    var messenger:Messenger?
    var keyboardHandler: JoinStreamKeyboardHandler?
    var infoViewDelegate: JoinInfoViewDelegate?
    var streamPlayer: StreamPlayer?
    var stream: Stream?
    var textViewHandler: GrowingTextViewHandler?
    
    var page: UInt = 0
    
    // MARK: - Actions
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        closeButton.enabled = false
                
        if streamPlayer != nil {
            StreamConnector().leave(stream!.id, likes: likes, success: leaveSuccess, failure: leaveFailure)
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func closeStream() {
        if streamPlayer != nil {
            StreamConnector().leave(stream!.id, likes: likes, success: leaveWithAlertSuccess, failure: leaveFailure)
        } else {
            UIAlertView.streamClosedAlert(nil).show()
        }
    }
    
    @IBAction func infoButtonPressed(sender: AnyObject) {
        infoView.show(false)
    }
    
    @IBAction func viewersButtonPressed(sender: AnyObject) {
        if self.viewersCollectionViewHeight.constant == 58.0 {
            self.viewersDataSource.viewers = []
            self.viewersCollectionView.reloadData()
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.viewersCollectionViewHeight.constant = 0.0
                self.likesViewBottom.constant   = 16.0
                self.viewersBottom.constant     = 16.0
                self.replaysBottom.constant     = 16.0
                
                self.view.layoutIfNeeded()
            }, completion: { (finished) -> Void in
                
            })
            
        } else {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.viewersCollectionViewHeight.constant = 58.0
                self.likesViewBottom.constant   = 58.0 + 16.0
                self.viewersBottom.constant     = 58.0 + 16.0
                self.replaysBottom.constant     = 58.0 + 16.0
                
                self.view.layoutIfNeeded()
            })
            StreamConnector().viewers(NSDictionary(object: stream!.id, forKey: "streamId"), success: viewersSuccess, failure: failureWithoutAction)
        }
    }
    
    @IBAction func authorImageViewPressed(sender: AnyObject) {
        //self.showUserInfo(stream!.user, userStatusDelegate: nil)
    }
    
    @IBAction func tapGesturePerformed(sender: AnyObject) {
        if messageTextView.isFirstResponder() {
            messageTextView.resignFirstResponder()
        } else {
            likes += 1
            messenger!.send(Message.like(), streamId: stream!.id)
        }
    }
    
    @IBAction func closeKeyboardButtonPerformed(sender: AnyObject) {
        messageTextView.resignFirstResponder()
    }
    
    // MARK: - ReplayViewDelegate
    
    func replayViewWillBeShown(replayView: ReplayView) {
        replayView.update(stream!)
        closeButton.hidden      = true
        infoButton.hidden       = true
        messageTextView.hidden  = true
        messageTextView.resignFirstResponder()
    }
    
    func replayViewStreamDidEnd(replayView: ReplayView) {
        StreamConnector().leave(stream!.id, likes: 0, success: leaveAnother, failure: leaveFailure)
    }
    
    func replayViewWillBeHidden(replayView: ReplayView) {
        closeButton.hidden      = false
        infoButton.hidden       = false
        messageTextView.hidden  = false
    }
    
    func replayViewPlayButtonPressed(replayView: ReplayView) {
        if self.viewersCollectionViewHeight.constant == 58.0 {
            viewersButtonPressed(eyeButton)
        }
        
        StreamConnector().join(stream!.id, success: joinSuccess, failure: joinFailure)
    }
    
    func replayViewCloseButtonPressed(replayView: ReplayView) {
        if let player = streamPlayer {
            player.reset()
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
        
    func replayViewViewersButtonPressed(replayView: ReplayView) {
        
        if self.viewersCollectionViewHeight.constant == 58.0 && replayView.viewersIsShown {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.viewersCollectionViewHeight.constant = 0.0
                self.likesViewBottom.constant   = 16.0
                self.viewersBottom.constant     = 16.0
                self.replaysBottom.constant     = 16.0
                
                self.view.layoutIfNeeded()
                }) { (completed) -> Void in
            }
        } else {
            page = 0
            StreamConnector().viewers(NSDictionary(object: stream!.id, forKey: "streamId"), success: viewersSuccess, failure: failureWithoutAction)
        }
    }
    
    func replayViewReplaysButtonPressed(replayView: ReplayView) {
        if self.viewersCollectionViewHeight.constant == 58.0 && replayView.replaysIsShown {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.viewersCollectionViewHeight.constant = 0.0
                self.likesViewBottom.constant   = 16.0
                self.viewersBottom.constant     = 16.0
                self.replaysBottom.constant     = 16.0
                
                self.view.layoutIfNeeded()
                }) { (completed) -> Void in
            }
        } else {
            page = 0
            StreamConnector().replayViewers(NSDictionary(object: stream!.id, forKey: "streamId"), success: viewersSuccess, failure: failureWithoutAction)
        }
    }
    
    // MARK: - SelectFollowersDelegate
    
    func followersDidSelected(users: [User]) {
        let usersId = users.map({ $0.id })
        StreamConnector().share(stream!.id, usersId: usersId, success: successWithoutAction, failure: failureWithoutAction)
    }
    
    // MARK: - UIActionSheetDelegate
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            StreamConnector().share(stream!.id, usersId: nil, success: successWithoutAction, failure: failureWithoutAction)
        }
        if buttonIndex == 2 {
            self.performSegueWithIdentifier("JoinToFollowers", sender: self)
        }
    }
    
    // MARK: - UIAlertViewDelegate
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex != alertView.cancelButtonIndex {
            StreamConnector().report(stream!.id, success: successWithoutAction, failure: failureWithoutAction)
        }
    }
    
    // MARK: - Update counter
    
    func updateCounter() {
        StreamConnector().get(stream!.id, success: getStreamSuccess, failure: failureWithoutAction)
    }
    
    // MARK: - Block Stream
    
    func blockStream(userId: UInt) {
        if userId == UserContainer.shared.logged().id {
            UIAlertView.userBlockedAlert().show()
            if streamPlayer != nil {
                StreamConnector().leave(stream!.id, likes: likes, success: leaveSuccess, failure: leaveFailure)
            }
        }
    }
    
    // MARK: - Network Responses
    
    func successWithoutAction() {
    }
    
    func failureWithoutAction(error: NSError) {
        handleError(error)
    }
    
    func viewersSuccess(likes: UInt, viewers: UInt, users: [User]) {
        viewersDataSource.viewers = users
        
        self.viewersCollectionView.reloadData()
        
        
    }
    
    func moreViewersSuccess(likes: UInt, viewers: UInt, users: [User]) {
        viewersDataSource.viewers = viewersDataSource.viewers + users
        self.viewersCollectionView.reloadData()
    }
    
    func chatMessageReceived(message: Message) {
        if let messageController = MessageController.getMessageControllerForJoin(message.type, viewController: self) {
            messageController.handle(message)
        }
    }
    
    func joinSuccess() {
        // Play stream
        if !isRecent {
            streamPlayer = StreamPlayer(stream: stream!, isRecent: isRecent, view: previewView, indicator: activityIndicator)
            self.streamPlayer!.delegate = DefaultStreamPlayerDelegate(isRecent: isRecent, replayView: replayView)
            
            messenger = MessengerFactory.getMessenger("pubnub")!
            messenger!.connect(stream!.id)
            messenger!.receive(chatMessageReceived)
            messenger!.send(Message.connected(), streamId: stream!.id)
        } else {
            streamPlayer!.play()
            replayView.hide(true)
            
            infoButton.hidden       = false
            messageTextView.hidden  = true
        }
        
      //  messenger = MessengerFactory.getMessenger("pubnub")!
      //  messenger!.connect(stream!.id)
      //  messenger!.receive(chatMessageReceived)
      //  messenger!.send(Message.connected(), streamId: stream!.id)
    }
    
    func joinFailure(error: NSError) {
        self.activityIndicator.stopAnimating()
        handleError(error)
        
        if let userInfo = error.userInfo as? [NSObject: NSObject] {
            // modify and assign values as necessary
            if userInfo["code"] == Error.kUserBlocked {
                UIAlertView.userBlockedAlert().show()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        } else {
            UIAlertView.failedJoinStreamAlert().show()
        }
    }
    
    func leaveSuccess() {
        leaveSilentSuccess()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func leaveWithAlertSuccess() {
        leaveSilentSuccess()
        UIAlertView.streamClosedAlert(nil).show()
    }
    
    func leaveSilentSuccess() {
        if let mes = messenger {
            mes.send(Message.disconnected(), streamId: stream!.id)
            mes.disconnect(stream!.id)
        }
        likes = 0
        streamPlayer!.stop()
        streamPlayer = nil
    }
    
    func leaveAnother() {
        replayView.update(stream!)
        closeButton.hidden      = true
        infoButton.hidden       = true
        messageTextView.hidden  = true
        messageTextView.resignFirstResponder()

        if let mes = messenger {
            mes.send(Message.disconnected(), streamId: stream!.id)
            mes.disconnect(stream!.id)
        }
        
        likes = 0
        streamPlayer!.stop()
    }
    
    func leaveFailure(error: NSError) {
        handleError(error)
        closeButton.enabled = true
    }
    
    func getStreamSuccess(stream: Stream) {
        self.stream = stream
        infoViewDelegate!.stream = stream
        viewersLabel.text = "\(stream.tviewers)"
    }
    
    // MARK: - Handle notifications
    
    func forceLeave(notification: NSNotification) {
        if streamPlayer != nil {
            StreamConnector().leave(stream!.id, likes: likes, success: leaveSilentSuccess, failure: leaveFailure)
            if let mes = messenger {
                mes.send(Message.disconnected(), streamId: stream!.id)
                mes.disconnect(stream!.id)
            }            
        }
    }
    
    // MARK: - UserSelecting protocol
    
    func userDidSelected(user: User) {
        //self.showUserInfo(user, userStatusDelegate: nil)
    }
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(JoinStreamViewController.forceLeave(_:)), name: "Close/Leave", object: nil)
        if !isRecent {
            StreamConnector().join(stream!.id, success: joinSuccess, failure: joinFailure)
        } else {
            streamPlayer = StreamPlayer(stream: stream!, isRecent: isRecent, view: previewView, indicator: activityIndicator)
            self.streamPlayer!.delegate = DefaultStreamPlayerDelegate(isRecent: isRecent, replayView: replayView)
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController!.setNavigationBarHidden(true, animated: true)
        keyboardHandler!.register()
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
        
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        app.closeStream = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if isRecent {
            messageTextViewRightConstraint.constant = 8.0
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if let navController = navigationController {
            navController.setNavigationBarHidden(false, animated: true)
        }
        keyboardHandler!.unregister()
        
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        app.closeStream = false
    }
    
    func configureView() {        
        closeButton.setImageTintColor(UIColor(white: 1.0, alpha: 1.0), forState: UIControlState.Normal)
        closeButton.setImageTintColor(UIColor(white: 1.0, alpha: 0.5), forState: UIControlState.Highlighted)
        infoButton.setImageTintColor(UIColor(white: 1.0, alpha: 0.7), forState: UIControlState.Normal)
        infoButton.setImageTintColor(UIColor(white: 1.0, alpha: 1.0), forState: UIControlState.Highlighted)
        eyeButton.setImageTintColor(UIColor(white: 1.0, alpha: 0.7), forState: UIControlState.Normal)
        eyeButton.setImageTintColor(UIColor(white: 1.0, alpha: 1.0), forState: UIControlState.Highlighted)
        
        commentsDataSource.userSelectedDelegate = self
        commentsTableView.delegate = commentsDataSource
        commentsTableView.dataSource = commentsDataSource
        commentsTableView.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI))

        messageTextView.tintColor = UIColor(white: 1.0, alpha: 1.0)
        var messageTextViewFrame = messageTextView.frame
        messageTextViewFrame.size.height = 39.0
        messageTextView.frame = messageTextViewFrame
        
        self.textViewHandler = GrowingTextViewHandler(textView: messageTextView, withHeightConstraint: messageViewHeightConstraint)
        textViewHandler!.updateMinimumNumberOfLines(1, andMaximumNumberOfLine: 3)
        textViewHandler!.setText("", withAnimation: false)
        
        viewersDataSource.userSelectedDelegate = self
        viewersDelegate.pullDelegate     = self
        viewersCollectionView.dataSource = viewersDataSource
        viewersCollectionView.delegate   = viewersDelegate
        
        self.replayView.delegate    = self
        self.replayView.hide(false)
        
        infoViewDelegate = JoinInfoViewDelegate(close: closeButton, info: infoButton, alertViewDelegate: self, actionSheetDelegate: self, actionSheetView: self.view)
        infoViewDelegate!.stream = stream
        self.infoView.delegate = infoViewDelegate!
        self.infoView.userSelectingDelegate = self
        
        keyboardHandler = JoinStreamKeyboardHandler(
            view: view,
            messageTextView: messageTextView,
            commentsTableView: commentsTableView,
            commentsTableViewHeight: commentsTableViewHeight,
            viewersCollectionViewHeight: viewersCollectionViewHeight,
            messageViewBottomConstraint: messageViewBottomConstraint,
            messageTextViewRightConstraint: messageTextViewRightConstraint,
            viewersLabelBottomConstraint: viewersLabelBottomConstraint,
            viewersLabel: viewersLabel,
            eyeButton: eyeButton,
            isRecent: isRecent
        )
        
        if isRecent {
            infoButton.hidden                       = true
            messageTextView.hidden                  = true
            viewersLabel.hidden                     = true
            viewersLabel.backgroundColor            = UIColor.redColor()
            eyeButton.hidden                        = true
            self.view.layoutIfNeeded()
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let sid = segue.identifier {
            if sid == "JoinToFollowers" {
                let controller = segue.destinationViewController as! FollowersViewController
                controller.delegate = self
            }
        }
    }
    
    // MARK: - UITextViewDelegate
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            if textView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).isEmpty {
                return false
            }
            messenger!.send(Message.create(textView.text), streamId: stream!.id)
            textViewHandler!.setText("", withAnimation: false)
            return false
        }
        
        let term = (textView.text as NSString).stringByReplacingCharactersInRange(range, withString: text)
        return term.characters.count <= 140
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        messenger!.send(Message.create(textField.text!), streamId: stream!.id)
        textField.text = ""
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
//        textView.text = textView.text.handleEmoji()
        self.textViewHandler!.resizeTextViewWithAnimation(true)
    }
    
    // MARK: - CollectionViewPullDelegate
    
    func collectionViewDidBeginPullingLeft(collectionView: UIScrollView, offset: CGFloat) {
        let data = NSDictionary(objects: [stream!.id, ++page], forKeys: ["streamId", "p"])
        if replayView.viewersIsShown {
            StreamConnector().viewers(data, success: moreViewersSuccess, failure: failureWithoutAction)
        }
        if replayView.replaysIsShown {
            StreamConnector().replayViewers(data, success: moreViewersSuccess, failure: failureWithoutAction)
        }
    }
}
