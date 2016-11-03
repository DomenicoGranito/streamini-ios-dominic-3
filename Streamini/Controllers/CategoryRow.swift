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
        
        let video=oneCategoryItemsArray[indexPath.row] as! Video
        
        cell.videoTitleLbl?.text=video.title
        cell.followersCountLbl?.text="\(video.followersCount) FOLLOWERS"
        cell.videoThumbnailImageView?.image=UIImage(named:video.thumbnail)
        
        let cellRecognizer=UITapGestureRecognizer(target:self, action:#selector(cellTapped))
        cell.addGestureRecognizer(cellRecognizer)
        
        return cell
    }
    
    func cellTapped()
    {
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        let vc=storyboard.instantiateViewControllerWithIdentifier("JoinStreamViewControllerId") as! JoinStreamViewController
        navigationControllerReference?.pushViewController(vc, animated:true)
    }
}
