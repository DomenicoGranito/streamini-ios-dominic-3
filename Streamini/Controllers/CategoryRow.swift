//
//  CategoryRow.swift
//  Streamini
//
//  Created by Ankit Garg on 9/8/16.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//

class CategoryRow: UITableViewCell
{
    var oneCategoryItemsArray:NSArray!
    var navigationControllerReference:UINavigationController?
    
    func collectionView(collectionView:UICollectionView, numberOfItemsInSection section:Int)->Int
    {
        return oneCategoryItemsArray.count
    }
    
    func collectionView(collectionView:UICollectionView, cellForItemAtIndexPath indexPath:NSIndexPath)->UICollectionViewCell
    {
        let cell=collectionView.dequeueReusableCellWithReuseIdentifier("videoCell", forIndexPath:indexPath) as! VideoCell
        
        let video=oneCategoryItemsArray[indexPath.row] as! Stream
        
        cell.videoTitleLbl?.text=video.title
        
        let cellRecognizer=UITapGestureRecognizer(target:self, action:#selector(cellTapped))
        cell.tag=indexPath.row
        cell.addGestureRecognizer(cellRecognizer)
        
        return cell
    }
    
    func cellTapped(gestureRecognizer:UITapGestureRecognizer)
    {
        let video=oneCategoryItemsArray[gestureRecognizer.view!.tag] as! Stream
        
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        let vc=storyboard.instantiateViewControllerWithIdentifier("JoinStreamViewControllerId") as! JoinStreamViewController
        vc.stream=video
        vc.isRecent=(video.ended != nil)
        navigationControllerReference?.pushViewController(vc, animated:true)
    }
}
