//
//  PeopleDataSource.swift
//  Streamini
//
//  Created by Vasily Evreinov on 10/08/15.
//  Copyright (c) 2015 Evghenii Todorov. All rights reserved.
//

import UIKit

class PeopleDataSource: NSObject, UITableViewDataSource, UITableViewDelegate, LinkedUserCellDelegate {
    var foundUsers: [User]  = []
    var top: [User]         = []
    var featured: [User]    = []
    var tableView: UITableView
    var selectedCells: [PeopleCell] = []
    var userSelectedDelegate: UserSelecting?
    var page: UInt          = 0
    var searchPage: UInt    = 0
    private let l = UILabel()
    
    var isSearchMode = false
    var searchData = NSMutableDictionary()
    
    init(tableView: UITableView) {
        self.tableView   = tableView
        super.init()
        tableView.dataSource = self
        tableView.delegate   = self
        
        l.font = UIFont(name: "HelveticNeue", size: 15.0)
        l.numberOfLines = 0
        l.lineBreakMode = NSLineBreakMode.ByWordWrapping
    }

    // MARK: - UITableViewDatasource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (isSearchMode) ? 1 : 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearchMode {
            return foundUsers.count
        } else {
            return (section == 0) ? top.count : featured.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PeopleCell", forIndexPath: indexPath) as! PeopleCell
        
        let user: User
        if isSearchMode {
            user = foundUsers[indexPath.row]
        } else {
            user = (indexPath.section == 0) ? top[indexPath.row] : featured[indexPath.row]
        }
        
        cell.update(user)
        cell.delegate = self
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0 && top.isEmpty) || (section == 1 && featured.isEmpty) || isSearchMode {
            return 0.0
        }
        return 35.0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (section == 0 && top.isEmpty) || (section == 1 && featured.isEmpty) || isSearchMode {
            return nil
        }
        
        let header = UIView(frame: CGRectMake(0, 0, tableView.bounds.size.width, 35))
        header.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        
        let label = UILabel()
        
        if section == 0 {
            label.text = NSLocalizedString("people_top", comment: "")
        } else {
            label.text = NSLocalizedString("people_featured", comment: "")
        }
        
        label.font = UIFont(name: "HelveticaNeue", size: 17.0)
        label.frame = CGRectMake(14, 0, tableView.bounds.size.width - 14.0, 35)
        label.textColor = UIColor.darkGrayColor()
        label.backgroundColor = UIColor.clearColor()
        
        header.addSubview(label)
        return header
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let user: User
        if isSearchMode {
            user = foundUsers[indexPath.row]
        } else {
            user = (indexPath.section == 0) ? top[indexPath.row] : featured[indexPath.row]
        }
        
        var text: String? = nil
        if user.desc != nil {
            if !user.desc!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).isEmpty {
                text = user.desc
            }
        }
        l.text = text
        let expectedSize = l.sizeThatFits(CGSizeMake(tableView.bounds.size.width - 98.0, 1000))
        return expectedSize.height + 82.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let user: User
        if isSearchMode {
            user = foundUsers[indexPath.row]
        } else {
            user = (indexPath.section == 0) ? top[indexPath.row] : featured[indexPath.row]
        }
        
        if let delegate=userSelectedDelegate
        {
            delegate.userDidSelected(user)
        }
    }
    
    // MARK: - LinkedCellDelegate
    
    func willStatusChanged(cell: UITableViewCell) {
        let selectedCell = cell as! PeopleCell
        self.selectedCells.append(selectedCell)
        
        let indexPath = tableView.indexPathForCell(cell)!
        
        let userId: UInt
        if isSearchMode {
            userId = foundUsers[indexPath.row].id
        } else {
            userId = (indexPath.section == 0) ? top[indexPath.row].id : featured[indexPath.row].id
        }
        
        selectedCell.userStatusButton.enabled = false
        
        let connector = SocialConnector()
        if selectedCell.isStatusOn {
            connector.unfollow(userId, success: unfollowSuccess, failure: followActionFailure)
        } else {
            connector.follow(userId, success: followSuccess, failure: followActionFailure)
        }
    }
    
    // MARK: - Network communication
    
    func unfollowSuccess() {
        let selectedCell = self.selectedCells[0]
        selectedCell.isStatusOn = false
        selectedCell.userStatusButton.enabled = true
        selectedCells.removeAtIndex(0)
    }
    
    func followSuccess() {
        let selectedCell = self.selectedCells[0]
        selectedCell.isStatusOn = true
        selectedCell.userStatusButton.enabled = true
        selectedCells.removeAtIndex(0)
    }
    
    func followActionFailure(error: NSError) {
        let selectedCell = self.selectedCells[0]
        selectedCell.userStatusButton.enabled = true
        selectedCells.removeAtIndex(0)
    }
    
    func peopleSuccess(top: [User], featured: [User]) {
        tableView.pullToRefreshView.stopAnimating()
        self.top        = top
        self.featured   = featured
    
        tableView.hidden = (self.top.isEmpty && self.featured.isEmpty)        
        self.tableView.reloadData()
    }
    
    func fetchMoreSuccess(top: [User], featured: [User]) {
        tableView.infiniteScrollingView.stopAnimating()
        self.top        = self.top + top
        self.featured   = self.featured + featured
        
        tableView.hidden = (self.top.isEmpty && self.featured.isEmpty)
        self.tableView.reloadData()
    }
    
    func searchSuccess(users: [User]) {
        self.foundUsers = users
        
        tableView.hidden = self.foundUsers.isEmpty
        
        let range = NSMakeRange(0, tableView.numberOfSections)
        
        if range.length == 2 {
            UIView.transitionWithView(tableView, duration:NSTimeInterval(0.4), options:.TransitionCrossDissolve, animations: { () -> Void in
                self.tableView.reloadData()
            }, completion: nil)
        } else {
            let range = NSMakeRange(0, tableView.numberOfSections)
            let indexSet = NSIndexSet(indexesInRange: range)
            tableView.reloadSections(indexSet, withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    func searchMoreSuccess(users: [User]) {
        tableView.infiniteScrollingView.stopAnimating()
        
        self.foundUsers = self.foundUsers + users
        
        tableView.hidden = self.foundUsers.isEmpty        
        self.tableView.reloadData()
    }
    
    func actionFailure(error: NSError) {
        tableView.pullToRefreshView.stopAnimating()
        print("get user failed: \(error.localizedDescription)")
    }
    
    // MARK: - Reload methods
    
    func updateUser(user: User, isFollowed: Bool, isBlocked: Bool) {
        if isSearchMode {
            var updateObject = foundUsers.filter({ $0.id == user.id })
            if updateObject.count > 0 {
                updateObject[0].isBlocked = isBlocked
                updateObject[0].isFollowed = isFollowed
                let index = (foundUsers as NSArray).indexOfObject(updateObject[0])
                let indexPath = NSIndexPath(forRow: index, inSection: 0)
                tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
            }
            return
        }
        
        var updateObject = top.filter({ $0.id == user.id })
        if updateObject.count > 0 {
            updateObject[0].isBlocked = isBlocked
            updateObject[0].isFollowed = isFollowed
            let index = (top as NSArray).indexOfObject(updateObject[0])
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
            return
        }
        updateObject = featured.filter({ $0.id == user.id })
        if updateObject.count > 0 {
            updateObject[0].isBlocked = isBlocked
            updateObject[0].isFollowed = isFollowed
            let index = (featured as NSArray).indexOfObject(updateObject[0])
            let indexPath = NSIndexPath(forRow: index, inSection: 1)
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
            return
        }
    }
    
    func reload() {
        SocialConnector().users(NSDictionary(), success: peopleSuccess, failure: actionFailure)
    }
    
    func fetchMore() {
        if isSearchMode {
            searchData["p"] = ++searchPage
            searchMore(searchData)
        } else {
            page += 1
            SocialConnector().users(NSDictionary(object: page, forKey: "p"), success: fetchMoreSuccess, failure: actionFailure)
        }
    }
    
    func search(data: NSDictionary) {
        searchPage = 0
        searchData = NSMutableDictionary(dictionary: data)
        SocialConnector().search(data, success: searchSuccess, failure: actionFailure)
    }
    
    func searchMore(data: NSDictionary) {
        SocialConnector().search(data, success: searchMoreSuccess, failure: actionFailure)
    }
}
