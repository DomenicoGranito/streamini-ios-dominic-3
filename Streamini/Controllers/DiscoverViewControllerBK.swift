



//
//  CategoriesViewController.swift
//  Streamini
//
//  Created by Ankit Garg on 9/9/16.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//
//BaseViewController
class bkDiscoverViewController:BaseViewController
{
    
    
    
    
    @IBOutlet var itemsTbl:UITableView?
    
    var allItemsArray=NSMutableArray()
    
    func configureView()
    {
        self.title=NSLocalizedString("Discover", comment:"")
    }
    
    override func viewDidLoad()
    {
        configureView()
        StreamConnector().categories(categoriesSuccess, failure:categoriesFailure)
    }
    
    
    override func viewWillAppear(animated:Bool)
    {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation:.Fade)
    }
    
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        return allItemsArray.count
    }
    //UITableViewCell
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath)->UITableViewCell
    {
        
        let cell=tableView.dequeueReusableCellWithIdentifier("cell") as! AllCategoryRow
        
        cell.sectionItemsArray=allItemsArray[indexPath.row] as! NSArray
        cell.navigationControllerReference=navigationController
        
        
        return cell
    }
    
    
    
    
    
    func tableView(tableView:UITableView, willDisplayCell cell:UITableViewCell, forRowAtIndexPath indexPath:NSIndexPath)
    {
        let cell=cell as! AllCategoryRow
        
        cell.reloadCollectionView()
    }
    
    func categoriesSuccess(cats:[Category])
    {
        allItemsArray.addObjectsFromArray(getData(cats) as [AnyObject])
        itemsTbl?.reloadData()
    }
    
    func categoriesFailure(error:NSError)
    {
        handleError(error)
    }
    
    func getData(cats:[Category])->NSMutableArray
    {
        var sectionItemsArray=NSMutableArray()
        let allItemsArray=NSMutableArray()
        var count=0
        
        for i in 0 ..< cats.count
        {
            sectionItemsArray.addObject(cats[i])
            
            count+=1
            
            if(count==2||(count==1&&i==cats.count-1))
            {
                count=0
                allItemsArray.addObject(sectionItemsArray)
                sectionItemsArray=NSMutableArray()
            }
        }
        
        return allItemsArray
    }
}
