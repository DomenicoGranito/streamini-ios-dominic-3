//
//  MyStreamsDataSource.swift
// Streamini
//
//  Created by Vasily Evreinov on 24/08/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

class MyStreamsDataSource: RecentStreamsDataSource {
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RecentStreamCell", forIndexPath: indexPath) as! RecentStreamCell
        let stream = streams[indexPath.row]
        cell.updateMyStream(stream)
        
        return cell
    }
    
    func myRecentSuccess(streams: [Stream]) {
        super.recentSuccess( streams.map({ $0.user = UserContainer.shared.logged(); return $0 }) )
    }
        
    override func reload() {
        StreamConnector().my(myRecentSuccess, failure: recentaFailure)
    }
    
    override func fetchMore() {
    }
    
    /*func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }*/
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            StreamConnector().del(streams[indexPath.row].id, success: delSuccess, failure: delFailure)
            self.streams.removeAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    func delSuccess()
    {
        
    }
    
    func delFailure(error: NSError) {
        //handleError(error)
    }
}
