//
//  AllCategoriesRow.swift
//  Streamini
//
//  Created by Ankit Garg on 9/10/16.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//

class AllCategoriesRow: UITableViewCell
{
    func collectionView(collectionView:UICollectionView, numberOfItemsInSection section:Int)->Int
    {
        return 2
    }
    
    func collectionView(collectionView:UICollectionView, cellForItemAtIndexPath indexPath:NSIndexPath)->UICollectionViewCell
    {
        let cell=collectionView.dequeueReusableCellWithReuseIdentifier("videoCell", forIndexPath:indexPath) as! VideoCell
        return cell
    }
    
    func collectionView(collectionView:UICollectionView, layout collectionViewLayout:UICollectionViewLayout, sizeForItemAtIndexPath indexPath:NSIndexPath)->CGSize
    {
        let width=(collectionView.frame.size.width-30)/2
        
        return CGSizeMake(width, 190)
    }
}