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
    
    override func viewDidLoad()
    {
        navigationController?.navigationBarHidden=true
        
        super.viewDidLoad()
    }
    
    func tableView(tableView:UITableView, viewForHeaderInSection section:Int)->UIView?
    {
        let headerView=UIView(frame:CGRectMake(0,0,60,tableView.frame.size.width))
        headerView.backgroundColor=UIColor(colorLiteralRed:18/255, green:19/255, blue:21/255, alpha:1)
        
        let titleLbl=UILabel(frame:CGRectMake(10,20,300,20))
        titleLbl.text="POPULAR LIST"
        titleLbl.font=UIFont.systemFontOfSize(14)
        titleLbl.textColor=UIColor.lightGrayColor()
        
        let lineView=UIView(frame:CGRectMake(10,45,tableView.frame.size.width-20,1))
        lineView.backgroundColor=UIColor.darkGrayColor()
        
        headerView.addSubview(lineView)
        headerView.addSubview(titleLbl)
        
        return headerView
    }
    
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        return 4
    }
    
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath)->UITableViewCell
    {
        let cell=tableView.dequeueReusableCellWithIdentifier("cell") as! AllCategoriesRow
        return cell
    }
    
    @IBAction func back()
    {
        navigationController?.popViewControllerAnimated(true)
    }
}