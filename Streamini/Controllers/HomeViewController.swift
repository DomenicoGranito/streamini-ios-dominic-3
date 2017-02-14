//
//  HomeViewController.swift
//  Streamini
//
//  Created by Ankit Garg on 9/8/16.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//

extension UIFont {
    
    func withTraits(traits:UIFontDescriptorSymbolicTraits...) -> UIFont {
        let descriptor = self.fontDescriptor().fontDescriptorWithSymbolicTraits(UIFontDescriptorSymbolicTraits(traits))
        return UIFont(descriptor: descriptor!, size: 0)
    }
    
    func bold() -> UIFont {
        return withTraits(.TraitBold)
    }
    
    func italic() -> UIFont {
        return withTraits(.TraitItalic)
    }
    
    func boldItalic() -> UIFont {
        return withTraits(.TraitBold, .TraitItalic)
    }
    
}


class HomeViewController: BaseViewController
{
    @IBOutlet var itemsTbl:UITableView?
    
    var categoryNamesArray=NSMutableArray()
    var categoryIDsArray=NSMutableArray()
    var allCategoryItemsArray=NSMutableArray()
    var timer:NSTimer?
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //(tabBarController as! mTBViewController).showButton()
    }
    
   // override func preferredStatusBarStyle() -> UIStatusBarStyle {
    //    return UIStatusBarStyle.LightContent
   // }
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
         (tabBarController as! mTBViewController).addCenterButton()
        
        
        reload()
        
        itemsTbl!.addPullToRefreshWithActionHandler{()->Void in
            self.reload()
        }
        
        timer=NSTimer(timeInterval:NSTimeInterval(10.0), target:self, selector:#selector(reload), userInfo:nil, repeats:true)
        NSRunLoop.mainRunLoop().addTimer(timer!, forMode:NSRunLoopCommonModes)
    }
    
    override func viewWillAppear(animated:Bool)
    {
        self.tabBarController!.navigationItem.hidesBackButton = true
        navigationController?.navigationBarHidden=false
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation:.Fade)
        
        timer=NSTimer(timeInterval:NSTimeInterval(10.0), target:self, selector:#selector(reload), userInfo:nil, repeats:true)
        NSRunLoop.mainRunLoop().addTimer(timer!, forMode:NSRunLoopCommonModes)
    }
    
    func reload()
    {
        StreamConnector().homeStreams(successStreams, failure:failureStream)
    }
    
    override func viewWillDisappear(animated:Bool)
    {
        timer!.invalidate()
        timer=nil
    }

    func tableView(tableView:UITableView, viewForHeaderInSection section:Int)->UIView?
    {
        let headerView=UIView(frame:CGRectMake(0, 0, 60, tableView.frame.size.width))
        headerView.backgroundColor=UIColor(colorLiteralRed:18/255, green:19/255, blue:21/255, alpha:1)
        
        let titleLbl=UILabel(frame:CGRectMake(5, 20, 285, 20))
        
        if(allCategoryItemsArray.count>0)
        {
            titleLbl.text=categoryNamesArray[section].uppercaseString
        }
        
        titleLbl.font=UIFont.systemFontOfSize(24)
       // titleLbl.font=UIFont.boldSystemFontOfSize(<#T##fontSize: CGFloat##CGFloat#>)
        titleLbl.textColor=UIColor(colorLiteralRed:190/255, green:142/255, blue:64/255, alpha:1) //UIColor.lightGrayColor()
        
        let accessoryLbl=UILabel(frame:CGRectMake(tableView.frame.size.width-25, 20, 20, 20))
       // accessoryLbl.text=">"
        accessoryLbl.font=UIFont.systemFontOfSize(22)
        accessoryLbl.textColor=UIColor(colorLiteralRed:190/255, green:142/255, blue:64/255, alpha:1)   ////lightGrayColor()
        
        
        
        
        let lineView=UIView(frame:CGRectMake(5, 45, tableView.frame.size.width-10, 1))
        lineView.backgroundColor=UIColor.darkGrayColor()
        
        
        let tapGesture=UITapGestureRecognizer(target:self, action:#selector(headerTapped))
        headerView.addGestureRecognizer(tapGesture)
        headerView.tag=section
        
        headerView.addSubview(lineView)
        headerView.addSubview(accessoryLbl)
        headerView.addSubview(titleLbl)
        
        return headerView
    }
    
    func headerTapped(gestureRecognizer:UITapGestureRecognizer)
    {
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        let vc=storyboard.instantiateViewControllerWithIdentifier("CategoriesViewController") as! CategoriesViewController
        vc.categoryName=categoryNamesArray[gestureRecognizer.view!.tag] as? String
        vc.categoryID=categoryIDsArray[gestureRecognizer.view!.tag] as? Int
        navigationController?.pushViewController(vc, animated:true)
       
        
        
        
       // navigationController?.pu(vc, animated:true, completion:nil)
        
       // DetailViewController *detailViewController = [[CategoriesViewController alloc] init]
        //detailViewController.hidesBottomBarWhenPushed = true
       // [[self navigationController] pushViewController:detailViewController animated:YES]
       // [detailViewController release]
       // detailViewController.hidesBottomBarWhenPushed = true
    }
    
    func numberOfSectionsInTableView(tableView:UITableView)->Int
    {
        return categoryNamesArray.count
    }
    
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        return 1
    }
    
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath)->UITableViewCell
    {
        let cell=tableView.dequeueReusableCellWithIdentifier("cell") as! CategoryRow
        
        if(allCategoryItemsArray.count>0)
        {
            cell.oneCategoryItemsArray=allCategoryItemsArray[indexPath.section] as! NSArray
            cell.navigationControllerReference=navigationController
        }
        
        return cell
    }
    
    func tableView(tableView:UITableView, willDisplayCell cell:UITableViewCell, forRowAtIndexPath indexPath:NSIndexPath)
    {
        let cell=cell as! CategoryRow
        
        cell.reloadCollectionView()
    }
    
    func successStreams(data:NSDictionary)
    {
        categoryNamesArray=NSMutableArray()
        categoryIDsArray=NSMutableArray()
        allCategoryItemsArray=NSMutableArray()

        itemsTbl?.pullToRefreshView.stopAnimating()
        
        let data=data["data"]!
        
        for i in 0 ..< data.count
        {
            let categoryName=data[i]["category_name"] as! String
            let categoryID=data[i]["category_id"]!.integerValue
            
            categoryNamesArray.addObject(categoryName)
            categoryIDsArray.addObject(categoryID)
            
            let videos=data[i]["videos"] as! NSArray
            
            let oneCategoryItemsArray=NSMutableArray()
            
            for j in 0 ..< videos.count
            {
                let videoID=videos[j]["id"] as! String
                let videoTitle=videos[j]["title"] as! String
                let videoHash=videos[j]["hash"] as! String
                let lon=videos[j]["lon"]!.doubleValue
                let lat=videos[j]["lat"]!.doubleValue
                let city=videos[j]["city"] as! String
                let ended=videos[j]["ended"] as? String
                let viewers=videos[j]["viewers"] as! String
                let tviewers=videos[j]["tviewers"] as! String
                let rviewers=videos[j]["rviewers"] as! String
                let likes=videos[j]["likes"] as! String
                let rlikes=videos[j]["rlikes"] as! String
                let userID=videos[j]["user"]!["id"] as! String
                let userName=videos[j]["user"]!["name"] as! String
                let userAvatar=videos[j]["user"]!["avatar"] as? String
                
                let user=User()
                user.id=UInt(userID)!
                user.name=userName
                user.avatar=userAvatar
                
                let video=Stream()
                video.id=UInt(videoID)!
                video.title=videoTitle
                video.streamHash=videoHash
                video.lon=lon
                video.lat=lat
                video.city=city
                
                if let e=ended
                {
                    video.ended=NSDate(timeIntervalSince1970:Double(e)!)
                }
                
                video.viewers=UInt(viewers)!
                video.tviewers=UInt(tviewers)!
                video.rviewers=UInt(rviewers)!
                video.likes=UInt(likes)!
                video.rlikes=UInt(rlikes)!
                video.user=user
                
                oneCategoryItemsArray.addObject(video)
            }
            
            allCategoryItemsArray.addObject(oneCategoryItemsArray)
        }
        
        itemsTbl!.reloadData()
    }
    
    func failureStream(error:NSError)
    {
        itemsTbl?.pullToRefreshView.stopAnimating()
        handleError(error)
    }
}
