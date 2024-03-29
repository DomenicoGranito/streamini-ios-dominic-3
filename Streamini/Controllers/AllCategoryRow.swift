//
//  AllCategoriesRow.swift
//  Streamini
//
//  Created by Ankit Garg on 9/10/16.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//

class AllCategoryRow: UITableViewCell
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
        let cell=collectionView.dequeueReusableCellWithReuseIdentifier("categoryCell", forIndexPath:indexPath) as! CategoryCell
        
        let catname=sectionItemsArray[indexPath.row] as! Category
        cell.videoTitleLbl?.text=catname.name
        cell.videoThumbnailImageView?.sd_setImageWithURL(NSURL(string:"http://cedricm.cn/thumbs/\(catname.id).jpg"))
        
        let cellRecognizer=UITapGestureRecognizer(target:self, action:#selector(cellTapped))
        cell.tag=indexPath.row
        cell.addGestureRecognizer(cellRecognizer)
        
        return cell
    }
    
    func cellTapped(gestureRecognizer:UITapGestureRecognizer)
    {
        let video=sectionItemsArray[gestureRecognizer.view!.tag] as! Category
        
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        let modalVC=storyboard.instantiateViewControllerWithIdentifier("CategoriesViewController") as! CategoriesViewController
        modalVC.categoryName=video.name
        modalVC.categoryID=Int(video.id)
        navigationControllerReference?.pushViewController(modalVC, animated:true)
    }
    
    func collectionView(collectionView:UICollectionView, layout collectionViewLayout:UICollectionViewLayout, sizeForItemAtIndexPath indexPath:NSIndexPath)->CGSize
    {
        let width=(collectionView.frame.size.width-30)/2
        
        return CGSizeMake(width, 190)
    }
}
