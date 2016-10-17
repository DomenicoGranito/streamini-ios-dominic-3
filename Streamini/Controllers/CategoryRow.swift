//
//  CategoryRow.swift
//  Streamini
//
//  Created by Ankit Garg on 9/8/16.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//

class CategoryRow: UITableViewCell
{
    func collectionView(collectionView:UICollectionView, numberOfItemsInSection section:Int)->Int
    {
        return 12
    }
    
    func collectionView(collectionView:UICollectionView, cellForItemAtIndexPath indexPath:NSIndexPath)->UICollectionViewCell
    {
        let cell=collectionView.dequeueReusableCellWithReuseIdentifier("videoCell", forIndexPath:indexPath) as! VideoCell
        return cell
    }
}