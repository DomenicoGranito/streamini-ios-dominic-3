//
//  CategoriesViewController.swift
//  Streamini
//
//  Created by Ankit Garg on 9/9/16.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//

class CategoriesViewController: BaseViewController
{
    @IBOutlet var itemsTbl:UITableView?
    @IBOutlet var topImageView:UIImageView?
    
    var allItemsArray=NSMutableArray()
    var sectionItemsArray=NSMutableArray()
    var categoryName:String?
    var count=0
    var categoryID:Int?
    
    override func viewDidLoad()
    {
        navigationController?.navigationBarHidden=true
        
        StreamConnector().categoryStreams(categoryID!, success:successStreams, failure:failureStream)
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
    
    func successStreams(data:NSDictionary)
    {
        let data=data["data"]!
        
        for i in 0 ..< data.count
        {
            let videoID=data[i]["id"] as! String
            let videoTitle=data[i]["title"] as! String
            let videoHash=data[i]["hash"] as! String
            let lon=data[i]["lon"]!.doubleValue
            let lat=data[i]["lat"]!.doubleValue
            let city=data[i]["city"] as! String
            let ended=data[i]["ended"] as? String
            let viewers=data[i]["viewers"] as! String
            let tviewers=data[i]["tviewers"] as! String
            let rviewers=data[i]["rviewers"] as! String
            let likes=data[i]["likes"] as! String
            let rlikes=data[i]["rlikes"] as! String
            let userID=data[i]["user"]!["id"] as! String
            let userName=data[i]["user"]!["name"] as! String
            let userAvatar=data[i]["user"]!["avatar"] as? String
            
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
            
            sectionItemsArray.addObject(video)
            
            count+=1
            
            if(count==2||(count==1&&i==data.count-1))
            {
                count=0
                allItemsArray.addObject(sectionItemsArray)
                sectionItemsArray=NSMutableArray()
            }
        }
        
        itemsTbl?.reloadData()
    }
    
    func failureStream(error:NSError)
    {
        handleError(error)
    }
}
