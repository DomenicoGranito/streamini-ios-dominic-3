//
//  CommentMessageController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 17/07/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

class CommentMessageController: NSObject, MessageControllerProtocol {
    var commentsDataSource: CommentsDataSource
    var commentsTableView: UITableView
    let kCommentLiveTime = 7.0
    
    init(commentsTableView: UITableView, commentsDataSource: CommentsDataSource) {
        self.commentsTableView = commentsTableView
        self.commentsDataSource = commentsDataSource
        super.init()
    }

    func handle(message: Message) {
        // Remove comment after kCommentLiveTime seconds
        let timer = NSTimer.scheduledTimerWithTimeInterval(kCommentLiveTime, target: self, selector: #selector(CommentMessageController.removeLastComment(_:)), userInfo: nil, repeats: false)
        
        // add comment and timer to datasource
        commentsDataSource.addComment(message, timer: timer)
        
        // change opacity of old messages
        let opacities = calculateOpacities()
        for i in 0 ..< commentsTableView.visibleCells.count {
        
        //for i in 0 ..< commentsTableView.visibleCells.count += 1 {
            let indexPath = NSIndexPath(forRow: i, inSection: 0)
            let cell = commentsTableView.cellForRowAtIndexPath(indexPath) as! CommentCell
            cell.setAlphaValue(CGFloat(opacities[i]))
        }
        
        // show message on top of the table
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        commentsTableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Right)
        
        // hide last message if it is out of the table frame
        if !isLastRowFit(commentsTableView.frame.size.height) {
            let indexPath = NSIndexPath(forRow: commentsTableView.visibleCells.count-1, inSection: 0)
            removeCommentAt(indexPath)
        }
    }
    
    func removeLastComment(timer: NSTimer) {
        let lastCell = commentsTableView.visibleCells.count-1
        if lastCell < 0 {
            return
        }
        let lastIndexPath = NSIndexPath(forRow: lastCell, inSection: 0)
        removeCommentAt(lastIndexPath)
    }
    
    private func calculateOpacities() -> [Double] {
        let count = commentsTableView.visibleCells.count + 1
        let minOpacity: Double = 0.0
        let maxOpacity: Double = 1.0
        let delta: Double = (maxOpacity - minOpacity) / Double(count)
        
        var opacities: [Double] = []
        
        for var i = 0; i < count-1; i += 1 {
        //for i in 0 < count-1 += 1 {
            opacities.append( maxOpacity - delta * Double(i+1) )
        }
        return opacities
    }
    
    private func isLastRowFit(tableViewHeight: CGFloat) -> Bool {
        let cellsCount = commentsTableView.visibleCells.count
        if cellsCount == 0 {
            return false
        }
        
        var height: CGFloat = 0.0
        
        for i in 0 ..< cellsCount
        {
            let indexPath = NSIndexPath(forRow: i, inSection: 0)
            let cellHeight = commentsDataSource.calculateHeight(commentsTableView, indexPath: indexPath)
            height += cellHeight
        }
        
        return height < tableViewHeight
    }
    
    private func removeCommentAt(indexPath:NSIndexPath)
    {
        commentsDataSource.removeCommentAt(indexPath.row)
        commentsTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation:.Fade)
    }
}
