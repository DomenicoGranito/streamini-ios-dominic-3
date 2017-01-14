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
    override func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath)->UITableViewCell
    {
        let cell=tableView.dequeueReusableCellWithIdentifier("cell") as! AllCategoryRow
        
        cell.sectionItemsArray=allItemsArray[indexPath.row] as! NSArray
        cell.navigationControllerReference=navigationController
        
        return cell
    }

    override func viewWillAppear(animated:Bool)
    {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation:.Fade)
    }
    
   
    
    override func tableView(tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        
        if section == 2
        {
       // return categories.count
        
        return allItemsArray.count
            
        }
        return 0
    }
    
        
    override func tableView(tableView:UITableView, willDisplayCell cell:UITableViewCell, forRowAtIndexPath indexPath:NSIndexPath)
    {
        let cell=cell as! AllCategoryRow
        
        cell.reloadCollectionView()
    }
    
    
    func categoriesSuccess(cats: [Category])
    {
        allItemsArray.addObjectsFromArray(getData(cats) as [AnyObject])
        itemsTbl?.reloadData()
    }

    
    func categoriesFailure(error:NSError)
    {
        handleError(error)
    }
    
    func getData(cats: [Category])->NSMutableArray
    {
        
        
        let data=cats
        
        var sectionItemsArray=NSMutableArray()
        let allItemsArray=NSMutableArray()
        var count=0
        
        for i in 0 ..< data.count
       {
            let videoID=data[i].id
            let videoTitle=data[i].name
          
            
            let video=Category()
            video.id=videoID
            video.name=videoTitle
            
            sectionItemsArray.addObject(video)
            
            count+=1
            
            if(count==2||(count==1&&i==data.count-1))
            {
                count=0
                allItemsArray.addObject(sectionItemsArray)
                sectionItemsArray=NSMutableArray()
            }
        }
        
        return allItemsArray
    }

}
