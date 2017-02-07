//
//  ProfileViewController.swift
// Streamini
//
//  Created by Vasily Evreinov on 11/08/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import MessageUI

enum ProfilesActionSheetType: Int {
    case ChangeAvatar
    case Logout
}

protocol ProfilesDelegate: class {
    func reload()
    func close()
}

class SettingsViewController: BaseTableViewController, UIActionSheetDelegate,
    UINavigationControllerDelegate,
ProfileDelegate {
    //@IBOutlet weak var userHeaderView: UserHeaderView!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var accountValueLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followersValueLabel: UILabel!
    @IBOutlet weak var blockedLabel: UILabel!
    @IBOutlet weak var blockedValueLabel: UILabel!
    @IBOutlet weak var streamsLabel: UILabel!
    @IBOutlet weak var streamsValueLabel: UILabel!
    @IBOutlet weak var shareLabel: UILabel!
    @IBOutlet weak var logoutLabel: UILabel!
    
    var user: User?
    var profileDelegate: ProfilesDelegate?
    var selectedImage: UIImage?
    
    
    func logout() {
        let actionSheet = UIActionSheet.confirmLogoutActionSheet(self)
        actionSheet.tag = ProfilesActionSheetType.Logout.rawValue
        actionSheet.showInView(self.view)
    }
    
    func configureView()
    {
        self.title = NSLocalizedString("profile_title", comment: "")
        accountLabel.text = NSLocalizedString("profile_following", comment: "")
        followersLabel.text = NSLocalizedString("profile_followers", comment: "")
        blockedLabel.text   = NSLocalizedString("profile_blocked", comment: "")
        streamsLabel.text   = NSLocalizedString("profile_streams", comment: "")
        shareLabel.text     = NSLocalizedString("profile_share", comment: "")
        logoutLabel.text    = NSLocalizedString("profile_logout", comment: "")
         
      
    }
    
    func successGetUser(user: User) {
        self.user = user
      
        
        accountValueLabel.text    = "\(user.following)"
        followersValueLabel.text    = "\(user.followers)"
        blockedValueLabel.text      = "\(user.blocked)"
        streamsValueLabel.text      = "\(user.streams)"
        
        self.navigationItem.rightBarButtonItem = nil
    }
    
    func successFailure(error: NSError) {
        handleError(error)
    }
    
    
    
    func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
        
        
        navigationController.navigationBar.tintColor = UIColor.blueColor()
        navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.blueColor()]
        
        // navigationController.navigationBar.tintColor = UIColor.whiteColor()
        // navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
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
        
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
        UINavigationBar.setCustomAppereance()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let sid = segue.identifier {
            if sid == "ProfileToLegal" {
                let controller = segue.destinationViewController as! LegalViewController
                let index = (sender as! NSIndexPath).row
                controller.type = (index == 2) ? LegalViewControllerType.TermsOfService : LegalViewControllerType.PrivacyPolicy
            }
            
            if sid == "ProfileToProfileStatistics" {
                let controller = segue.destinationViewController as! ProfileStatisticsViewController
                let index = (sender as! NSIndexPath).row
                controller.type = ProfileStatisticsType(rawValue: index)!
                controller.profileDelegate = self
            }
        }
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
            self.performSegueWithIdentifier("ProfileToProfileStatistics", sender: indexPath)
        }
        
        if indexPath.section == 2 && indexPath.row == 0 { // share
            UINavigationBar.resetCustomAppereance()
            let shareMessage = NSLocalizedString("profile_share_message", comment: "")
            let activityController = UIActivityViewController(activityItems: [shareMessage], applicationActivities: nil)
            self.presentViewController(activityController, animated: true, completion: nil)
        }
        
        if indexPath.section == 2 && indexPath.row == 1 { // feedback
            UINavigationBar.resetCustomAppereance()
          
        }
        
        if indexPath.section == 2 && indexPath.row == 2 { // Terms Of Service
            self.performSegueWithIdentifier("ProfileToLegal", sender: indexPath)
        }
        
        if indexPath.section == 2 && indexPath.row == 3 { // Privacy Policy
            self.performSegueWithIdentifier("ProfileToLegal", sender: indexPath)
        }
        
        if indexPath.section == 3 && indexPath.row == 0 { // Change Password
            self.performSegueWithIdentifier("ProfileToPassword", sender: indexPath)
        }
        
        if indexPath.section == 3 && indexPath.row == 1 { // logout
            logout()
        }
    }
    
    
      func reload() {
        UserConnector().get(nil, success: successGetUser, failure: successFailure)
    }
    
    func close() {
    }
    
    
   
    
   }
