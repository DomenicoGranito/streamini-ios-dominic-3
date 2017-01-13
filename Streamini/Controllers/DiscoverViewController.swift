//
//  DiscoverViewController.swift
// Streamini
//
//  Created by Vasily Evreinov on 11/08/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import MessageUI




class DiscoverViewController: BaseTableViewController, UINavigationControllerDelegate {
    
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
    
    
    
    
    func menuTapped(gestureRecognizer:UITapGestureRecognizer)
    {
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        let vc=storyboard.instantiateViewControllerWithIdentifier("CategoriesViewController") as! CategoriesViewController
        vc.categoryName=categoryNamesArray[gestureRecognizer.view!.tag] as? String
        vc.categoryID=categoryIDsArray[gestureRecognizer.view!.tag] as? Int
        navigationController?.pushViewController(vc, animated:true)
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
    
    
    // MARK: - UIImagePickerControllerDelegate
    
    
    func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
        navigationController.navigationBar.tintColor = UIColor.whiteColor()
        navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
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
            if sid == "DiscoverToLegal" {
                let controller = segue.destinationViewController as! LegalViewController
                let index = (sender as! NSIndexPath).row
                controller.type = (index == 2) ? LegalViewControllerType.TermsOfService : LegalViewControllerType.PrivacyPolicy
            }
            
                 }
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
           
        }
    }
    
    
    
    // MARK: - DiscoverDelegate
    
    func reload() {
        UserConnector().get(nil, success: successGetUser, failure: successFailure)
    }
    
   
    // MARK: - UserHeaderViewDelegate
}
