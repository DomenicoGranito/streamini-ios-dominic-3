//
//  DiscoverViewController.swift
// Streamini
//
//  Created by Vasily Evreinov on 11/08/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import MessageUI

enum DiscoverActionSheetType: Int {
    case ChangeAvatar
    case Logout
}

protocol DiscoverDelegate: class {
    func reload()
    func close()
}

class DiscoverViewController: BaseTableViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate,
    UINavigationControllerDelegate, AmazonToolDelegate, UserHeaderViewDelegate, MFMailComposeViewControllerDelegate,
DiscoverDelegate {
    @IBOutlet weak var userHeaderView: UserHeaderView!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followingValueLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followersValueLabel: UILabel!
    @IBOutlet weak var blockedLabel: UILabel!
    @IBOutlet weak var blockedValueLabel: UILabel!
    @IBOutlet weak var streamsLabel: UILabel!
    @IBOutlet weak var streamsValueLabel: UILabel!
    @IBOutlet weak var shareLabel: UILabel!
    @IBOutlet weak var feedbackLabel: UILabel!
    @IBOutlet weak var termsLabel: UILabel!
    @IBOutlet weak var privacyLabel: UILabel!
    @IBOutlet weak var logoutLabel: UILabel!
    @IBOutlet weak var changePasswordLabel: UILabel!
    
    
    var categoryNamesArray=NSMutableArray()
    var categoryIDsArray=NSMutableArray()
    var allCategoryItemsArray=NSMutableArray()
    
    var user: User?
  //  var DiscoverDelegate: DiscoverDelegate?
    var selectedImage: UIImage?
    
    @IBAction func avatarButtonPressed(sender: AnyObject) {
        let actionSheet = UIActionSheet.changeUserpicActionSheet(self)
        actionSheet.tag = DiscoverActionSheetType.ChangeAvatar.rawValue
        actionSheet.showInView(self.view)
    }
    
    
    
    func menuTapped(gestureRecognizer:UITapGestureRecognizer)
    {
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        let vc=storyboard.instantiateViewControllerWithIdentifier("CategoriesViewController") as! CategoriesViewController
        vc.categoryName=categoryNamesArray[gestureRecognizer.view!.tag] as? String
        vc.categoryID=categoryIDsArray[gestureRecognizer.view!.tag] as? Int
        navigationController?.pushViewController(vc, animated:true)
    }

    
    
    func logout() {
        let actionSheet = UIActionSheet.confirmLogoutActionSheet(self)
        actionSheet.tag = DiscoverActionSheetType.Logout.rawValue
        actionSheet.showInView(self.view)
    }
    
    func configureView()
    {
        self.title = NSLocalizedString("Discover", comment: "")
       // followingLabel.text = NSLocalizedString("Discover_following", comment: "")
        followingLabel.text = NSLocalizedString("Charts", comment: "")
        followersLabel.text = NSLocalizedString("Playlists", comment: "")
        blockedLabel.text   = NSLocalizedString("Series", comment: "")
        streamsLabel.text   = NSLocalizedString("Channels", comment: "")
      //  shareLabel.text     = NSLocalizedString("Live Streams", comment: "")
       // feedbackLabel.text  = NSLocalizedString("Discover_feedback", comment: "")
       // termsLabel.text     = NSLocalizedString("Discover_terms", comment: "")
       // privacyLabel.text   = NSLocalizedString("Discover_privacy", comment: "")
       // logoutLabel.text    = NSLocalizedString("Discover_logout", comment: "")
       // changePasswordLabel.text = NSLocalizedString("Discover_change_password", comment: "")
        
      //  userHeaderView.delegate = self
    }
    
    func successGetUser(user: User) {
        self.user = user
       // userHeaderView.update(user)
        
        followingValueLabel.text    = "\(user.following)"
        followersValueLabel.text    = "\(user.followers)"
        blockedValueLabel.text      = "\(user.blocked)"
        streamsValueLabel.text      = "\(user.streams)"
        
        self.navigationItem.rightBarButtonItem = nil
    }
    
    func successFailure(error: NSError) {
        handleError(error)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if actionSheet.tag == DiscoverActionSheetType.ChangeAvatar.rawValue {
            if (buttonIndex == 1) { // Gallery
                let controller = UIImagePickerController()
                controller.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                controller.allowsEditing = true
                controller.delegate = self
                self.presentViewController(controller, animated: true, completion: nil)
            }
            
            if (buttonIndex == 2) { // Camera
                let controller = UIImagePickerController()
                controller.sourceType = UIImagePickerControllerSourceType.Camera
                controller.allowsEditing = true
                controller.delegate = self
                self.presentViewController(controller, animated: true, completion: nil)
            }
        }
        
        if actionSheet.tag == DiscoverActionSheetType.Logout.rawValue {
            if buttonIndex != actionSheet.cancelButtonIndex {
                UserConnector().logout(logoutSuccess, failure: logoutFailure)
            }
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        picker.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.selectedImage = image.fixOrientation().imageScaledToFitToSize(CGSizeMake(100, 100))
            self.uploadImage(self.selectedImage!)
        })
    }
    
    func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
        navigationController.navigationBar.tintColor = UIColor.whiteColor()
        navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
    }
    
    func uploadImage(image: UIImage) {
        let filename = "\(UserContainer.shared.logged().id)-avatar.jpg"
        
        if AmazonTool.isAmazonSupported() {
            AmazonTool.shared.uploadImage(image, name: filename) { (bytesSent, totalBytesSent, totalBytesExpectedToSend) -> Void in
                dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                    let progress: Float = Float(totalBytesSent)/Float(totalBytesExpectedToSend)
                    self.userHeaderView.progressView.setProgress(progress, animated: true)
                })
            }
        } else {
            let data = UIImageJPEGRepresentation(image, 1.0)!
            UserConnector().uploadAvatar(filename, data: data, success: uploadAvatarSuccess, failure: uploadAvatarFailure, progress: { (bytesSent, totalBytesSent, totalBytesExpectedToSend) -> Void in
                let progress: Float = Float(totalBytesSent)/Float(totalBytesExpectedToSend)
                self.userHeaderView.progressView.setProgress(progress, animated: true)
            })
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.configureView()
        
        let activator=UIActivityIndicatorView(activityIndicatorStyle:.White)
        activator.startAnimating()
        
        self.navigationItem.rightBarButtonItem=UIBarButtonItem(customView:activator)
        UserConnector().get(nil, success:successGetUser, failure:successFailure)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController!.setNavigationBarHidden(false, animated: false)
        super.viewWillAppear(animated)
        AmazonTool.shared.delegate = self
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
        UINavigationBar.setCustomAppereance()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidAppear(animated)
        AmazonTool.shared.delegate = nil
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let sid = segue.identifier {
            if sid == "DiscoverToLegal" {
                let controller = segue.destinationViewController as! LegalViewController
                let index = (sender as! NSIndexPath).row
                controller.type = (index == 2) ? LegalViewControllerType.TermsOfService : LegalViewControllerType.PrivacyPolicy
            }
            
                 }
    }
    
    // MARK: - AmazonToolDelegate
    
    func uploadAvatarSuccess() {
        userHeaderView.progressView.setProgress(0.0, animated: false)
        userHeaderView.updateAvatar(user!, placeholder: selectedImage!)
       
    }
    
    func uploadAvatarFailure(error: NSError) {
        handleError(error)
    }
    
    func imageDidUpload() {
        UserConnector().avatar(uploadAvatarSuccess, failure: uploadAvatarFailure)
    }
    
    func imageUploadFailed(error: NSError) {
        handleError(error)
    }
    
    func logoutSuccess()
    {
        if A0SimpleKeychain().stringForKey("PHPSESSID") != nil
        {
            A0SimpleKeychain().deleteEntryForKey("PHPSESSID")
        }
        if A0SimpleKeychain().stringForKey("id") != nil
        {
            A0SimpleKeychain().deleteEntryForKey("id")
        }
        if A0SimpleKeychain().stringForKey("password") != nil
        {
            A0SimpleKeychain().deleteEntryForKey("password")
        }
        if A0SimpleKeychain().stringForKey("secret") != nil
        {
            A0SimpleKeychain().deleteEntryForKey("secret")
        }
        if A0SimpleKeychain().stringForKey("type") != nil
        {
            A0SimpleKeychain().deleteEntryForKey("type")
        }
        
        // deprecated Twitter.sharedInstance().logOut()
        
        /*let store = Twitter.sharedInstance().sessionStore
         
         if let userID = store.session()?.userID {
         store.logOutUserID(userID)
         }*/
        
        self.navigationController!.setNavigationBarHidden(true, animated: true)
        self.navigationController!.popToRootViewControllerAnimated(true)
    }
    
    func logoutFailure(error: NSError) {
        print("failure", terminator: "")
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        if indexPath.section == 1 { // following, followers, blocked, streams
            
            let storyboard=UIStoryboard(name:"Main", bundle:nil)
            let vc=storyboard.instantiateViewControllerWithIdentifier("PeopleViewController") as! PeopleViewController
           // vc.categoryName=categoryNamesArray[gestureRecognizer.view!.tag] as? String
           // vc.categoryID=categoryIDsArray[gestureRecognizer.view!.tag] as? Int
            navigationController?.pushViewController(vc, animated:true)

            
            
            
         //   self.performSegueWithIdentifier("DiscoverToDiscoverStatistics", sender: indexPath)
        }
        
        if indexPath.section == 2 && indexPath.row == 0 { // share
            UINavigationBar.resetCustomAppereance()
            let shareMessage = NSLocalizedString("Discover_share_message", comment: "")
            let activityController = UIActivityViewController(activityItems: [shareMessage], applicationActivities: nil)
            self.presentViewController(activityController, animated: true, completion: nil)
        }
        
        if indexPath.section == 2 && indexPath.row == 1 { // feedback
            UINavigationBar.resetCustomAppereance()
            let mailComposeViewController = configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.presentViewController(mailComposeViewController, animated: true, completion: nil)
            } else {
                let alert = UIAlertView.mailUnavailableErrorAlert()
                alert.show()
            }
        }
        
        if indexPath.section == 2 && indexPath.row == 2 { // Terms Of Service
            self.performSegueWithIdentifier("DiscoverToLegal", sender: indexPath)
        }
        
        if indexPath.section == 2 && indexPath.row == 3 { // Privacy Policy
            self.performSegueWithIdentifier("DiscoverToLegal", sender: indexPath)
        }
        
        if indexPath.section == 3 && indexPath.row == 0 { // Change Password
            self.performSegueWithIdentifier("DiscoverToPassword", sender: indexPath)
        }
        
        if indexPath.section == 3 && indexPath.row == 1 { // logout
            logout()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients([Config.shared.feedback()])
        mailComposerVC.setSubject(NSLocalizedString("feedback_title", comment: ""))
        
        let appVersion  = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
        let appBuild    = NSBundle.mainBundle().infoDictionary!["CFBundleVersion"] as! String
        let deviceName  = UIDevice.currentDevice().name
        let iosVersion  = "\(UIDevice.currentDevice().systemName) \(UIDevice.currentDevice().systemVersion)"
        let userId      = user!.id
        
        var message = "\n\n\n"
        message = message.stringByAppendingString("App Version: \(appVersion)\n")
        message = message.stringByAppendingString("App Build: \(appBuild)\n")
        message = message.stringByAppendingString("Device Name: \(deviceName)\n")
        message = message.stringByAppendingString("iOS Version: \(iosVersion)\n")
        message = message.stringByAppendingString("User Id: \(userId)")
        
        mailComposerVC.setMessageBody(message, isHTML: false)
        
        mailComposerVC.delegate = self
        
        return mailComposerVC
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        //controller.dismissViewControllerAnimated(true, completion: nil)
        controller.dismissViewControllerAnimated(true, completion: { () -> Void in
            // if result.rawValue == MFMailComposeResultFailed.rawValue {
            //   let alert = UIAlertView.sendMailErrorAlert()
            // alert.show()
            //}
        })
    }
    
    // MARK: - DiscoverDelegate
    
    func reload() {
        UserConnector().get(nil, success: successGetUser, failure: successFailure)
    }
    
    func close() {
    }
    
    // MARK: - UserHeaderViewDelegate
    
    func usernameLabelPressed()
    {
        
    }
    
    func descriptionWillStartEdit()
    {
        let doneBarButtonItem=UIBarButtonItem(barButtonSystemItem:.Done, target:self, action:#selector(doneButtonPressed))
        self.navigationItem.rightBarButtonItem=doneBarButtonItem
    }
    
    func doneButtonPressed(sender: AnyObject) {
        let text: String
        if userHeaderView.userDescriptionTextView.text == NSLocalizedString("Discover_description_placeholder", comment: "") {
            text = " "
        } else {
            text = userHeaderView.userDescriptionTextView.text
        }
        
        let activator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        activator.startAnimating()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activator)
        
        UserConnector().userDescription(text, success: userDescriptionTextSuccess, failure: userDescriptionTextFailure)
    }
    
    func userDescriptionTextSuccess() {
        self.navigationItem.rightBarButtonItem = nil
        userHeaderView.userDescriptionTextView.resignFirstResponder()
        
           }
    
    func userDescriptionTextFailure(error:NSError)
    {
        handleError(error)
        let doneBarButtonItem=UIBarButtonItem(barButtonSystemItem:.Done, target:self, action:#selector(doneButtonPressed))
        self.navigationItem.rightBarButtonItem=doneBarButtonItem
    }
}
