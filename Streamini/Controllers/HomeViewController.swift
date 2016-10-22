//
//  HomeViewController.swift
//  Streamini
//
//  Created by Ankit Garg on 9/8/16.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//

class HomeViewController: UIViewController
{
    let categories=["Action", "Drama", "Science Fiction", "Kids", "Horror"]
    
    override func viewWillAppear(animated:Bool)
    {
        navigationController?.navigationBarHidden=false
    }
    
    func tableView(tableView:UITableView, viewForHeaderInSection section:Int)->UIView?
    {
        let headerView=UIView(frame:CGRectMake(0, 0, 60, tableView.frame.size.width))
        headerView.backgroundColor=UIColor(colorLiteralRed:18/255, green:19/255, blue:21/255, alpha:1)
        
        let titleLbl=UILabel(frame:CGRectMake(5, 20, 310, 20))
        titleLbl.text=categories[section]
        titleLbl.font=UIFont.systemFontOfSize(14)
        titleLbl.textColor=UIColor.lightGrayColor()
        
        let lineView=UIView(frame:CGRectMake(5, 45, tableView.frame.size.width-10, 1))
        lineView.backgroundColor=UIColor.darkGrayColor()
        
        let tapGesture=UITapGestureRecognizer(target:self, action:#selector(headerTapped))
        headerView.addGestureRecognizer(tapGesture)
        
        headerView.addSubview(lineView)
        headerView.addSubview(titleLbl)
        
        return headerView
    }
    
    func headerTapped()
    {
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        let vc=storyboard.instantiateViewControllerWithIdentifier("CategoriesViewController") as! CategoriesViewController
        navigationController?.pushViewController(vc, animated:true)
    }
    
    func numberOfSectionsInTableView(tableView:UITableView)->Int
    {
        return categories.count
    }
    
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        return 1
    }
    
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath)->UITableViewCell
    {
        let cell=tableView.dequeueReusableCellWithIdentifier("cell") as! CategoryRow
        return cell
    }
}
