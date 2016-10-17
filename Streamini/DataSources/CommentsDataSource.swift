//
//  CommentsDataSource.swift
//  Streamini
//
//  Created by Vasily Evreinov on 16/07/15.
//  Copyright (c) 2015 Evghenii Todorov. All rights reserved.
//

import UIKit

class CommentsDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    var comments: [Message] = []
    var timers: [NSTimer]   = []
    var userSelectedDelegate: UserSelecting?
    
    var l = CommentLabel()
    var calculatedWidth: CGFloat = 0.0
    
    // MARK: - Object life Cycle
    
    override init() {
        super.init()
        l.numberOfLines = 0
        l.font = UIFont(name: "HelveticaNeue", size: 15.0)
        l.lineBreakMode = NSLineBreakMode.ByWordWrapping
    }
    
    // MARK: - Comments accessors
    
    func addComment(message: Message, timer: NSTimer) {
        comments.insert(message, atIndex: 0)
        timers.insert(timer, atIndex: 0)
    }
    
    func removeCommentAt(index: Int) {
        comments.removeAtIndex(index)
        timers.removeLast().invalidate()
    }
    
    // MARK: - UITableViewDatasource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as! CommentCell
        cell.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))

        if let delegate = self.userSelectedDelegate {
            cell.userSelectedDelegate = delegate
        }
        
        let live = comments[indexPath.row]
        cell.update(live, width: calculatedWidth)
        cell.contentView.alpha = 1.0
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return calculateHeight(tableView, indexPath: indexPath)
    }
    
    func calculateHeight(tableView: UITableView, indexPath: NSIndexPath) -> CGFloat {
        l.text = comments[indexPath.row].text
        
        let margins: CGFloat            = 8 + 35 + 8
        let verticalMargins: CGFloat    = 3 + 16 + 3
        
        let width = tableView.frame.size.width - margins
        let expectedSize = l.sizeThatFits(CGSizeMake(width, 10000))
        calculatedWidth = expectedSize.width
        
        let rowHeight: CGFloat = expectedSize.height + verticalMargins
        let minHeight: CGFloat = verticalMargins + 35.0
        
        return (rowHeight < minHeight) ? minHeight : rowHeight
    }
}