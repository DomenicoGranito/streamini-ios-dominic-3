//
//  CategoriesViewController.swift
//  Streamini
//
//  Created by Ankit Garg on 9/9/16.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//

class DiscoverViewController: BaseTableViewController, UINavigationControllerDelegate {
    
    @IBOutlet var itemsTbl:UITableView?
    //@IBOutlet var headerLbl:UILabel?
    //@IBOutlet var topImageView:UIImageView?
    
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
    
    
    var allItemsArray=NSMutableArray()
    var categoryName:String?
    var page=0
    var categoryID:Int?
    var categories: [Category] = []
    var user: User?
    
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

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.configureView()
        
        let activator=UIActivityIndicatorView(activityIndicatorStyle:.White)
        activator.startAnimating()
        
        self.navigationItem.rightBarButtonItem=UIBarButtonItem(customView:activator)
       // UserConnector().get(nil, success:successGetUser, failure:successFailure)
        
        
        
        
        
       // headerLbl?.text=categoryName?.uppercaseString
        navigationController?.navigationBarHidden=true
       
        StreamConnector().categories(categoriesSuccess, failure:categoriesFailure)
       // StreamConnector().categoryStreams(categoryID!, pageID:page, success:successStreams, failure:failureStream)
    }
    
    override func viewWillAppear(animated:Bool)
    {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation:.Fade)
    }
    
   
    
    override func tableView(tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        //return categories.count
        
        return categories.count
    }
    
    override func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath)->UITableViewCell
    {
        let cell=tableView.dequeueReusableCellWithIdentifier("cell") as! AllCategoryRow
        
        cell.sectionItemsArray=categories[indexPath.row] as! NSArray
        cell.navigationControllerReference=navigationController
        
        return cell
    }
    
    override func tableView(tableView:UITableView, willDisplayCell cell:UITableViewCell, forRowAtIndexPath indexPath:NSIndexPath)
    {
        let cell=cell as! AllCategoryRow
        
        cell.reloadCollectionView()
    }
    
    @IBAction func back()
    {
        navigationController?.popViewControllerAnimated(true)
    }
    
    
   func categoriesSuccess(cats: [Category]) 
    {
       // let catname=cats
      //  categories.addObjectsFromArray(catname)
        itemsTbl?.reloadData()
    }
    
    
    
    func categoriesFailure(error:NSError)
    {
        handleError(error)
    }
}
