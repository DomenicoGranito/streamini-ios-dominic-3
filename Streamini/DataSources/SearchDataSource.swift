//
//  PeopleDataSource.swift
//  Streamini
//
//  Created by Vasily Evreinov on 10/08/15.
//  Copyright (c) 2015 Evghenii Todorov. All rights reserved.
//

import UIKit

class SearchDataSource: NSObject, UITableViewDataSource, UITableViewDelegate, LinkedUserCellDelegate {
    var users: [User] = []
    var streams: [Stream] = []
    var cities: [String] = []
    var categories: [Category] = []
    
    var tableView: UITableView
    var userSelectedDelegate: UserSelecting?
    var streamSelectedDelegate: StreamSelecting?
    var page: UInt = 0
    private let l = UILabel()
    
    //var mode = "categories"
    var mode = "streams"
    
    var selectedCells: [PeopleCell] = []
    
    var category: UInt = 0
    var city: String = ""
    var query: String = ""
    
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
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if mode == "categories" {
            return categories.count
        }
        else if mode == "places" {
            return cities.count
        }
        else if mode == "streams" {
            return streams.count
        }
        else if mode == "people" {
            return users.count
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if mode == "categories" {
            let cell = tableView.dequeueReusableCellWithIdentifier("categoryCell", forIndexPath: indexPath)
            cell.textLabel!.text = categories[indexPath.row].name
            return cell
        }
        else if mode == "places" {
            let cell = tableView.dequeueReusableCellWithIdentifier("cityCell", forIndexPath: indexPath)
            cell.textLabel!.text = cities[indexPath.row]
            return cell
        }
        else if mode == "streams" {
            let cell = tableView.dequeueReusableCellWithIdentifier("streamCell", forIndexPath: indexPath) as! SearchStreamCell
            let stream = streams[indexPath.row]
            
            if let delegate = self.userSelectedDelegate {
                cell.userSelectedDelegate = delegate
            }
            cell.update(stream)
            return cell
        }
        else if mode == "people" {
            let cell: PeopleCell = tableView.dequeueReusableCellWithIdentifier("peopleCell", forIndexPath: indexPath) as! PeopleCell
            let user = users[indexPath.row]
            cell.update(user)
            cell.delegate = self
            return cell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("categoryCell", forIndexPath: indexPath)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if mode == "streams" {
            return 120.0
        }
        else if mode == "people" {
            let user = users[indexPath.row]
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
        
        return 44.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if mode == "categories" {
            // search categories
            let c = categories[indexPath.row]
            self.category = c.id
            self.city = ""
            self.query = ""
            changeMode("streams")
        }
        else if mode == "places" {
           // search cities
            self.city = cities[indexPath.row]
            self.category = 0
            self.query = ""
            changeMode("streams")
        }
        else if mode == "streams" {
            let s = streams[indexPath.row]
            if let delegate = streamSelectedDelegate {
                delegate.streamDidSelected(s)
            }
        }
        else if mode == "people" {
            let u = users[indexPath.row]
            if let delegate = userSelectedDelegate {
                delegate.userDidSelected(u)
            }
        }
    }
    
    // MARK: - LinkedCellDelegate
    
    func willStatusChanged(cell: UITableViewCell) {
        let selectedCell = cell as! PeopleCell
        self.selectedCells.append(selectedCell)
        
        let indexPath = tableView.indexPathForCell(cell)!
        
        let userId = users[indexPath.row].id
        
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
        if mode != "people" {
            return
        }
        
        let selectedCell = self.selectedCells[0]
        selectedCell.isStatusOn = false
        selectedCell.userStatusButton.enabled = true
        selectedCells.removeAtIndex(0)
    }
    
    func followSuccess() {
        if mode != "people" {
            return
        }
        
        let selectedCell = self.selectedCells[0]
        selectedCell.isStatusOn = true
        selectedCell.userStatusButton.enabled = true
        selectedCells.removeAtIndex(0)
    }
    
    func followActionFailure(error: NSError) {
        if mode != "people" {
            return
        }
        
        let selectedCell = self.selectedCells[0]
        selectedCell.userStatusButton.enabled = true
        selectedCells.removeAtIndex(0)
    }
    
    func citiesSuccess(cities: [String]) {
        self.cities = cities
        tableView.reloadData()
        tableView.hidden = self.cities.isEmpty
    }
    
    func categoriesSuccess(cats: [Category]) {
        self.categories = cats
        tableView.hidden = self.categories.isEmpty
        tableView.reloadData()
    }
    
    func peopleSuccess(users: [User]) {
        tableView.infiniteScrollingView.stopAnimating()
        self.users = users
        tableView.hidden = self.users.isEmpty
        tableView.reloadData()
    }
    
    func streamsSuccess(streams: [Stream]) {
        tableView.infiniteScrollingView.stopAnimating()
        self.streams = streams
        tableView.hidden = self.streams.isEmpty
        tableView.reloadData()
    }
    
    func peopleMoreSuccess(users: [User]) {
        tableView.infiniteScrollingView.stopAnimating()
        self.users        = self.users + users
        tableView.hidden = self.users.isEmpty
        tableView.reloadData()
    }
    
    func streamsMoreSuccess(streams: [Stream]) {
        tableView.infiniteScrollingView.stopAnimating()
        self.streams        = self.streams + streams
        tableView.hidden = self.streams.isEmpty
        tableView.reloadData()
    }
    
    
    func actionFailure(error: NSError) {
        //tableView.pullToRefreshView.stopAnimating()
        print("get user failed: \(error.localizedDescription)")
    }
    
    // MARK: - Reload methods
    
    func updateUser(user: User, isFollowed: Bool, isBlocked: Bool) {
            var updateObject = users.filter({ $0.id == user.id })
            if updateObject.count > 0 {
                updateObject[0].isBlocked = isBlocked
                updateObject[0].isFollowed = isFollowed
                let index = (users as NSArray).indexOfObject(updateObject[0])
                let indexPath = NSIndexPath(forRow: index, inSection: 0)
                tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
            }
            return
    }
    
    func changeMode(mode:String)
    {
        self.mode = mode
        page = 0
        reload()
    }
    
    func reload() {
        //SocialConnector().users(NSDictionary(), success: peopleSuccess, failure: actionFailure)
        
        tableView.hidden = true
        
        if mode == "categories" {
            StreamConnector().categories(categoriesSuccess, failure: actionFailure)
        }
        else if mode == "places" {
            StreamConnector().cities(citiesSuccess, failure: actionFailure)
        }
        else if mode == "streams" {
            StreamConnector().search(0, category: category, query: query, city: city, success: streamsSuccess, failure: actionFailure)
        }
        else if mode == "people" {
            SocialConnector().search(NSDictionary(object: query, forKey: "q"), success: peopleSuccess, failure: actionFailure)
        }
    }
    
    func fetchMore() {
        
        if mode == "categories" {
            tableView.infiniteScrollingView.stopAnimating()
            // do nothing
        }
        else if mode == "places" {
            tableView.infiniteScrollingView.stopAnimating()
            // do nothing        
        }
        else if mode == "streams" {
            page = page+1
            StreamConnector().search(page, category:category, query: query, city: city, success: streamsSuccess, failure: actionFailure)
        }
        else if mode == "people" {
            page = page+1
            SocialConnector().search(NSDictionary(objects: [page, query], forKeys: ["p","q"]), success: peopleSuccess, failure: actionFailure)
        }
    }
    
    func search(q: String)
    {
        self.query = q
        self.category = 0
        self.city = ""
        self.page = 0
        reload()
    }
}
