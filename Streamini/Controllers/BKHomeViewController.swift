//
//  HomeViewController.swift
//  Streamini
//
//  Created by Ankit Garg on 9/8/16.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//

class BKHomeViewController: UIViewController
{
    var categoryNamesArray=NSMutableArray()
    var categoryIDsArray=NSMutableArray()
    var allCategoryItemsArray=NSMutableArray()
    
    override func viewDidLoad()
    {
        let file=NSBundle.mainBundle().pathForResource("home", ofType:"json")
        let jsonData=NSData(contentsOfFile:file!)
        let jsonDictionary=try! NSJSONSerialization.JSONObjectWithData(jsonData!, options:[]) as! NSDictionary
        
        let data=jsonDictionary["data"]!
        
        for i in 0 ..< data.count
        {
            let categoryName=data[i]["category_name"] as! String
            let categoryID=data[i]["category_id"] as! Int
            
            categoryNamesArray.addObject(categoryName)
            categoryIDsArray.addObject(categoryID)
            
            let videos=data[i]["videos"] as! NSArray
            
            let oneCategoryItemsArray=NSMutableArray()
            
            for j in 0 ..< videos.count
            {
                let videoID=videos[j]["video_id"] as! Int
                let videoTitle=videos[j]["video_title"] as! String
                let videoURL=videos[j]["video_url"] as! String
                let videoThumbnail=videos[j]["video_thumbnail"] as! String
                let followersCount=videos[j]["followers_count"] as! String
                
                let video=Video(id:videoID, title:videoTitle, url:videoURL, thumbnail:videoThumbnail, followersCount:followersCount)
                
                oneCategoryItemsArray.addObject(video)
            }
            
            allCategoryItemsArray.addObject(oneCategoryItemsArray)
        }
    }
    
    override func viewWillAppear(animated:Bool)
    {
        navigationController?.navigationBarHidden=false
    }
    
    func tableView(tableView:UITableView, viewForHeaderInSection section:Int)->UIView?
    {
        let headerView=UIView(frame:CGRectMake(0, 0, 60, tableView.frame.size.width))
        headerView.backgroundColor=UIColor(colorLiteralRed:18/255, green:19/255, blue:21/255, alpha:1)
        
        let titleLbl=UILabel(frame:CGRectMake(5, 20, 285, 20))
        titleLbl.text=categoryNamesArray[section] as? String
        titleLbl.font=UIFont.systemFontOfSize(14)
        titleLbl.textColor=UIColor.lightGrayColor()
        
        let accessoryLbl=UILabel(frame:CGRectMake(295, 20, 20, 20))
        accessoryLbl.text=">"
        accessoryLbl.font=UIFont.systemFontOfSize(18)
        accessoryLbl.textColor=UIColor.lightGrayColor()
        
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
        navigationController?.pushViewController(vc, animated:true)
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
        
        cell.oneCategoryItemsArray=allCategoryItemsArray[indexPath.section] as! NSArray
        cell.navigationControllerReference=navigationController
        
        return cell
    }
}
