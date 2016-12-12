//
//  RecentUsersDataSource.swift
// Streamini
//
//  Created by Vasily Evreinov on 07/08/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

class RecentStreamsDataSource:UserStatisticsDataSource
{
    var streams:[Stream]=[]
    
    override func numberOfSectionsInTableView(tableView:UITableView)->Int
    {
        return 1
    }
    
    func tableView(tableView:UITableView, viewForHeaderInSection section:Int)->UIView?
    {
        let headerView=UIView(frame:CGRectMake(0, 0, 40, tableView.frame.size.width))
        headerView.backgroundColor=UIColor.darkGrayColor()
        
        let titleLbl=UILabel(frame:CGRectMake(5, 10, 150, 20))
        titleLbl.text="ALL VIDEOS"
        titleLbl.font=UIFont.systemFontOfSize(14)
        titleLbl.textColor=UIColor.lightGrayColor()
        
        let filterButton=UIButton(frame:CGRectMake(tableView.frame.size.width-25, 10, 20, 20))
        filterButton.setImage(UIImage(named:"menu"), forState:.Normal)
        
        let lineView=UIView(frame:CGRectMake(0, 39, tableView.frame.size.width, 1))
        lineView.backgroundColor=UIColor.darkGrayColor()
        
        headerView.addSubview(lineView)
        headerView.addSubview(titleLbl)
        headerView.addSubview(filterButton)
        
        return headerView
    }

    override func tableView(tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        return streams.count
    }
    
    override func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath)->UITableViewCell
    {
        let stream=streams[indexPath.row]
        let cell=tableView.dequeueReusableCellWithIdentifier("RecentStreamCell", forIndexPath:indexPath) as! RecentStreamCell
        cell.update(stream)
        return cell
    }
    
    func tableView(tableView:UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath)
    {
        if let delegate=streamSelectedDelegate
        {
            delegate.streamDidSelected(streams[indexPath.row])
        }
    }
    
    func recentSuccess(streams:[Stream])
    {
        if let pullToRefreshView=tableView.pullToRefreshView
        {
            pullToRefreshView.stopAnimating()
        }
        
        self.streams=streams
        
        tableView.hidden=self.streams.isEmpty
        let range=NSMakeRange(0, tableView.numberOfSections)
        let indexSet=NSIndexSet(indexesInRange:range)
        tableView.reloadSections(indexSet, withRowAnimation:UITableViewRowAnimation.Automatic)
    }

    func recentaFailure(error:NSError)
    {
        if let pullToRefreshView=tableView.pullToRefreshView
        {
            pullToRefreshView.stopAnimating()
        }
    }
    
    override func reload()
    {
        StreamConnector().recent(userId, success:recentSuccess, failure:recentaFailure)
    }
    
    override func fetchMore()
    {
        
    }
    
    override func clean()
    {
        streams=[]
        tableView.reloadData()
    }
}
