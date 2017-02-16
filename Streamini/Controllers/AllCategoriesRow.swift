

//
//  AllCategoriesRow.swift
//  Streamini
//
//  Created by Ankit Garg on 9/10/16.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//

class AllCategoriesRow: UITableViewCell
{
    @IBOutlet var collectionView:UICollectionView?
    var sectionItemsArray:NSArray!
    var navigationControllerReference:UINavigationController?
    
    
    
    
    
    func reloadCollectionView()
    {
        collectionView!.reloadData()
    }
    
    func collectionView(collectionView:UICollectionView, numberOfItemsInSection section:Int)->Int
    {
        return sectionItemsArray.count
    }
    
    func collectionView(collectionView:UICollectionView, cellForItemAtIndexPath indexPath:NSIndexPath)->UICollectionViewCell
    {
        let (host, port, application, _, _) = Config.shared.wowza()
       
        let cell=collectionView.dequeueReusableCellWithReuseIdentifier("videoCell", forIndexPath:indexPath) as! VideoCell
        
        let video=sectionItemsArray[indexPath.row] as! Stream
        cell.followersCountLbl?.text=video.user.name 
        cell.videoTitleLbl?.text=video.title
        cell.videoThumbnailImageView?.sd_setImageWithURL(NSURL(string:"http://\(host)/thumbs/\(video.id).jpg"))
        
        let cellRecognizer=UITapGestureRecognizer(target:self, action:#selector(cellTapped))
        cell.tag=indexPath.row
        cell.addGestureRecognizer(cellRecognizer)
        
        return cell
    }
    
    func cellTapped(gestureRecognizer:UITapGestureRecognizer)
    {
        let root=UIApplication.sharedApplication().delegate!.window!?.rootViewController as! UINavigationController
        
        let video=sectionItemsArray[gestureRecognizer.view!.tag] as! Stream
        
        
        
        
        let storyboardn=UIStoryboard(name:"Main", bundle:nil)
        let modalVC=storyboardn.instantiateViewControllerWithIdentifier("ModalViewController") as! ModalViewController
        
       // let video=oneCategoryItemsArray[gestureRecognizer.view!.tag] as! Stream
        
        modalVC.stream=video
        
        
        root.presentViewController(modalVC, animated:true, completion:nil)
        
        
     
    }

    
    
    
    func bkcellTapped(gestureRecognizer:UITapGestureRecognizer)
    {
        let root=UIApplication.sharedApplication().delegate!.window!?.rootViewController as! UINavigationController
        
        let video=sectionItemsArray[gestureRecognizer.view!.tag] as! Stream
        
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        let joinNavController=storyboard.instantiateViewControllerWithIdentifier("JoinStreamNavigationControllerId") as! UINavigationController
        let joinController=joinNavController.viewControllers[0] as! JoinStreamViewController
        joinController.stream=video
        joinController.isRecent=(video.ended != nil)
        root.presentViewController(joinNavController, animated:true, completion:nil)
    }
    
    func collectionView(collectionView:UICollectionView, layout collectionViewLayout:UICollectionViewLayout, sizeForItemAtIndexPath indexPath:NSIndexPath)->CGSize
    {
        let width=(collectionView.frame.size.width-30)/2
        
        return CGSizeMake(width, 190)
    }
}
