//
//  CategoriesViewController.swift
//  Streamini
//
//  Created by Ankit Garg on 9/9/16.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//

class CategoriesViewController: UIViewController
{
    @IBOutlet var topImageView:UIImageView?
    
    var allItemsArray=NSMutableArray()
    var sectionItemsArray=NSMutableArray()
    var categoryName:String?
    var count=0
    
    override func viewDidLoad()
    {
        navigationController?.navigationBarHidden=true
        
        let file=NSBundle.mainBundle().pathForResource("category", ofType:"json")
        let jsonData=NSData(contentsOfFile:file!)
        let jsonDictionary=try! NSJSONSerialization.JSONObjectWithData(jsonData!, options:[]) as! NSDictionary
        
        let videos=jsonDictionary["videos"]!
        
        for i in 0 ..< videos.count
        {
            let videoID=videos[i]["video_id"] as! Int
            let videoTitle=videos[i]["video_title"] as! String
            let videoURL=videos[i]["video_url"] as! String
            let videoThumbnail=videos[i]["video_thumbnail"] as! String
            let followersCount=videos[i]["followers_count"] as! String
            
            let video=Video(id:videoID, title:videoTitle, url:videoURL, thumbnail:videoThumbnail, followersCount:followersCount)
            
            sectionItemsArray.addObject(video)
            
            count+=1
            
            if(count==2||(count==1&&i==videos.count-1))
            {
                count=0
                allItemsArray.addObject(sectionItemsArray)
                sectionItemsArray=NSMutableArray()
            }
        }
    }
    
    func tableView(tableView:UITableView, viewForHeaderInSection section:Int)->UIView?
    {
        let headerView=UIView(frame:CGRectMake(0, 0, 60, tableView.frame.size.width))
        headerView.backgroundColor=UIColor(colorLiteralRed:18/255, green:19/255, blue:21/255, alpha:1)
        
        let titleLbl=UILabel(frame:CGRectMake(10, 20, 300, 20))
        titleLbl.text=categoryName
        titleLbl.font=UIFont.systemFontOfSize(14)
        titleLbl.textColor=UIColor.lightGrayColor()
        
        let lineView=UIView(frame:CGRectMake(10, 45, tableView.frame.size.width-20, 1))
        lineView.backgroundColor=UIColor.darkGrayColor()
        
        headerView.addSubview(lineView)
        headerView.addSubview(titleLbl)
        
        return headerView
    }
    
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        return allItemsArray.count
    }
    
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath)->UITableViewCell
    {
        let cell=tableView.dequeueReusableCellWithIdentifier("cell") as! AllCategoriesRow
        
        cell.sectionItemsArray=allItemsArray[indexPath.row] as! NSArray
        cell.navigationControllerReference=navigationController
        
        return cell
    }
    
    @IBAction func back()
    {
        navigationController?.popViewControllerAnimated(true)
    }
}
