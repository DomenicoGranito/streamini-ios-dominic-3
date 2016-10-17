//
//  StreamDataSource.swift
//  Streamini
//
//  Created by Vasily Evreinov on 23/06/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

class StreamDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    var lives: [Stream]     = []
    var recent: [Stream]    = []
    var userSelectedDelegate: UserSelecting?
    private let l = UILabel()
    
    override init() {
        super.init()
        l.font = UIFont(name: "HelveticNeue-Light", size: 17.0)
        l.numberOfLines = 0
        l.lineBreakMode = NSLineBreakMode.ByWordWrapping
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? lives.count : recent.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = (indexPath.section == 0) ? "LiveStreamCell" : "RecentStreamCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! StreamCell
        let stream = (indexPath.section == 0) ? lives[indexPath.row] : recent[indexPath.row]

        if let delegate = self.userSelectedDelegate {
            cell.userSelectedDelegate = delegate
        }
        cell.update(stream)
        
        if indexPath.section == 0 {
            //cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0)
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 || recent.isEmpty {
            return nil
        }
        let header = UIView(frame: CGRectMake(0, 0, tableView.bounds.size.width, 35))
        header.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        
        let label = UILabel()
        label.text = NSLocalizedString("recent_streams", comment: "")
        label.font = UIFont(name: "HelveticaNeue", size: 17.0)
        label.frame = CGRectMake(14, 0, tableView.bounds.size.width - 14.0, 35)
        label.textColor = UIColor.darkGrayColor()
        label.backgroundColor = UIColor.clearColor()
        
        header.addSubview(label)
        return header
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (section == 0 || recent.isEmpty) ? 0.0 : 35.0
    }
        
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 180.0;
        } else {
            l.text = recent[indexPath.row].title
            let expectedSize = l.sizeThatFits(CGSizeMake(tableView.bounds.size.width - 68.0, 1000))
            return expectedSize.height + 34.0
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
