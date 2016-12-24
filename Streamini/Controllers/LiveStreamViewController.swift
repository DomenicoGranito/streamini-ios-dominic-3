//
//  LiveStreamViewController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 10/07/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

class LiveStreamViewController: BaseViewController, UserSelecting, UserStatusDelegate, UIAlertViewDelegate {
    @IBOutlet weak var infoView: InfoView!
    @IBOutlet weak var closeButton: SensibleButton!
    @IBOutlet weak var rotateButton: SensibleButton!
    @IBOutlet weak var infoButton: SensibleButton!
    @IBOutlet weak var eyeButton: SensibleButton!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var viewersLabel: UILabel!
    @IBOutlet weak var likeView: UIView!
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var commentsTableViewHeight: NSLayoutConstraint!     // 400 by default
    @IBOutlet weak var viewersCollectionViewHeight: NSLayoutConstraint! // 50 pt default
    @IBOutlet weak var viewersCollectionView: UICollectionView!
    
    var commentsDataSource  = CommentsDataSource()
    var viewersDataSource   = ViewersDataSource()
    var viewers: UInt       = 0
    let animator            = HeartBounceAnimator()
    let messenger           = MessengerFactory.getMessenger("pubnub")!
    let kTimerInterval      = NSTimeInterval(15.0)    
    var infoViewDelegate: DefaultInfoViewDelegate?
    var camera: Camera?    
    var stream: Stream?
    
    var timer: NSTimer?
    
    // MARK: - Actions
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        let connector = StreamConnector()
        connector.close(stream!.id, success: closeStreamSuccess, failure: closeStreamFailure)
    }
    
    @IBAction func rotateButtonPressed(sender: AnyObject) {
        camera!.switchCameraDirection()
        if camera!.session!.cameraState == .Front {
            previewView.transform = CGAffineTransformMakeScale(-1.0, 1.0)
        } else {
            previewView.transform = CGAffineTransformMakeScale(1.0, 1.0)
        }
    }
    
    @IBAction func infoButtonPressed(sender: AnyObject) {
        infoView.show(true)
    }
    
    @IBAction func viewersButtonPressed(sender: AnyObject) {
        if self.viewersCollectionViewHeight.constant == 58.0 {
            // If viewers collection view is opened - close it
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.viewersCollectionViewHeight.constant = 0.0
                self.view.layoutIfNeeded()
            })
        } else {
            // If viewers collection view is closed - get viewers list from server 
            // and open collection view
            StreamConnector().viewers(NSDictionary(object: stream!.id, forKey: "streamId"), success: viewersSuccess, failure: viewersFailure)
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.viewersCollectionViewHeight.constant = 58.0
                self.view.layoutIfNeeded()
                }) { (completed) -> Void in
                    //self.viewersCollectionView.reloadData()
            }
        }
    }
    
    // MARK: - Viewers counter
    
    func updateCounter() {
        StreamConnector().get(stream!.id, success: getStreamSuccess, failure: getStreamFailure)
    }
    
    // MARK: - Network responses
    
    func chatMessageReceived(message: Message) {        
        if let messageController = MessageController.getMessageControllerForOwner(message.type, viewController: self) {
            messageController.handle(message)
        }
    }
    
    func getStreamSuccess(stream: Stream) {
        self.stream = stream
        infoViewDelegate!.stream = stream
        viewersLabel.text = "\(stream.viewers)"
    }
    
    func getStreamFailure(error: NSError) {
        handleError(error)
    }
    
    func closeStreamSuccess() {
        closeStreamSilentSuccess()
        self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func closeStreamSilentSuccess() {
        timer!.invalidate()
        messenger.send(Message.disconnected(), streamId: stream!.id)
        messenger.send(Message.closed(), streamId: stream!.id)
        messenger.disconnect(stream!.id)
        camera!.stop()
    }
    
    func closeStreamFailure(error: NSError) {
        handleError(error)
    }
    
    func viewersSuccess(likes: UInt, viewers: UInt, users: [User]) {
        viewersDataSource.viewers = users
        self.viewersCollectionView.reloadData()
        
        /*UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.viewersCollectionViewHeight.constant = 58.0
            self.view.layoutIfNeeded()
            }) { (completed) -> Void in
                
        }*/
    }
    
    func viewersFailure(error: NSError) {
        handleError(error)
    }
    
    // MARK: - Handle notifications
    
    func forceClose(notification: NSNotification) {
        StreamConnector().close(stream!.id, success: closeStreamSilentSuccess, failure: closeStreamFailure)
    }
    
    // MARK: - UserSelecting protocol
    
    func userDidSelected(user: User) {
        //self.showUserInfo(user, userStatusDelegate: self)
    }
    
    // MARK: - UserStatusDelegae
    
    func blockStatusDidChange(status: Bool, user: User) {
        if status {
            messenger.send(Message.blocked(user.id), streamId: stream!.id)
        }
    }
    
    func followStatusDidChange(status: Bool, user: User) {
    }
    
    // MARK: - Ping
    
    func pingSuccess() {
    }
    
    func pingFailure(error: NSError) {
        closeStreamSilentSuccess()
        handleError(error)
        
        if let userInfo = error.userInfo as? [NSObject: NSObject] {
            // modify and assign values as necessary
            if userInfo["code"] == Error.kUnsuccessfullPing {
                let message = userInfo[NSLocalizedDescriptionKey] as! String
                let alertView = UIAlertView.unsuccessfullPingAlert(message, delegate: self)
                alertView.show()
            }
        }
    }
    
    func ping(timer: NSTimer) {
        StreamConnector().ping(stream!.id, success: pingSuccess, failure: pingFailure)
    }
    
    // MARK: - UIAlertViewDelegate
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        StreamConnector().close(stream!.id, success: closeStreamSuccess, failure: closeStreamFailure)
    }
    
    // MARK: - View life cycle
    
    func configureView() {        
        closeButton.setImageTintColor(UIColor(white: 1.0, alpha: 1.0), forState:.Normal)
        closeButton.setImageTintColor(UIColor(white: 1.0, alpha: 0.5), forState:.Highlighted)
        rotateButton.setImageTintColor(UIColor(white: 1.0, alpha: 1.0), forState:.Normal)
        rotateButton.setImageTintColor(UIColor(white: 1.0, alpha: 0.5), forState:.Highlighted)
        infoButton.setImageTintColor(UIColor(white: 1.0, alpha: 0.7), forState:.Normal)
        infoButton.setImageTintColor(UIColor(white: 1.0, alpha: 1.0), forState:.Highlighted)
        eyeButton.setImageTintColor(UIColor(white: 1.0, alpha: 0.7), forState:.Normal)
        eyeButton.setImageTintColor(UIColor(white: 1.0, alpha: 1.0), forState:.Highlighted)
        
        commentsDataSource.userSelectedDelegate = self
        commentsTableView.delegate = commentsDataSource
        commentsTableView.dataSource = commentsDataSource
        commentsTableView.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI))
        
        viewersDataSource.userSelectedDelegate = self        
        viewersCollectionView.dataSource = viewersDataSource
        
        infoViewDelegate = DefaultInfoViewDelegate(close: closeButton, info: infoButton, rotate: rotateButton)
        infoViewDelegate!.stream = stream!
        infoView.delegate = infoViewDelegate!
        infoView.userSelectingDelegate = self
    }    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        
        camera!.addPreviewView(previewView)
        
        messenger.connect(stream!.id)
        messenger.receive(chatMessageReceived)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LiveStreamViewController.forceClose(_:)), name: "Close/Leave", object: nil)
        
        self.timer = NSTimer(timeInterval: kTimerInterval, target: self, selector: #selector(LiveStreamViewController.ping(_:)), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        app.closeStream = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        app.closeStream = false
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Private methods
    
    private func isLastRowFit(tableViewHeight: CGFloat) -> Bool {
        let cellsCount = commentsTableView.visibleCells.count-1
        let actualCellsHeight = CGFloat(cellsCount) * commentsTableView.rowHeight
        
        return (actualCellsHeight + commentsTableView.rowHeight) < tableViewHeight
    }
    
    private func removeCommentAt(indexPath: NSIndexPath) {
        commentsDataSource.removeCommentAt(indexPath.row)
        commentsTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation:.Fade)
    }
}
