//
//  FollowersViewController.swift
// Streamini
//
//  Created by Vasily Evreinov on 22/07/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

protocol SelectFollowersDelegate: class {
    func followersDidSelected(users: [User])
}

class FollowersViewController: BaseTableViewController, UISearchBarDelegate, UserSelecting {
    @IBOutlet weak var searchBar: UISearchBar!
    var users: [User]           = []
    var selectedUsers: [User]   = []
    var page                    = 0
    var searchTerm              = ""
    weak var delegate: SelectFollowersDelegate?
    
    // MARK: - Actions
    
    func selectedDone() {
        if let del = delegate {
            if !selectedUsers.isEmpty {
                del.followersDidSelected(selectedUsers)
            }
        }
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    // MARK: - Network responses
    
    func followersSuccess(users: [User]) {
        self.users = users.filter( { $0.id != UserContainer.shared.logged().id } )
        
        let range = NSMakeRange(0, tableView.numberOfSections)
        let indexSet = NSIndexSet(indexesInRange: range)
        tableView.reloadSections(indexSet, withRowAnimation:.Automatic)
    }
    
    func addFollowersSuccess(users: [User]) {
        tableView.infiniteScrollingView.stopAnimating()
        self.users += users.filter( { $0.id != UserContainer.shared.logged().id } )
        tableView.reloadData()
    }
    
    func followersFailure(error: NSError) {
        handleError(error)
        tableView.infiniteScrollingView.stopAnimating()
    }
    
    // MARK: - UserSelecting protocol
    
    func userDidSelected(user:User)
    {
        //self.showUserInfo(user, userStatusDelegate: nil)
    }
    
    // MARK: - View life cycle
    
    func configureView() {
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.title = NSLocalizedString("select_followers_title", comment: "")
        
        let buttonItem = UIBarButtonItem(barButtonSystemItem:.Done, target: self, action: #selector(FollowersViewController.selectedDone))
        self.navigationItem.rightBarButtonItem = buttonItem
        
        self.tableView.addInfiniteScrollingWithActionHandler { () -> Void in
            self.page += 1
            let data = NSDictionary(objects: [self.page, self.searchTerm], forKeys: ["p", "q"])
            UserConnector().followers(data, success: self.addFollowersSuccess, failure: self.followersFailure)
        }
        
        self.searchBar.placeholder = NSLocalizedString("search_followers_placeholder", comment: "")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        configureView()
        
        let data = [ "p" : page ]
        UserConnector().followers(data, success: followersSuccess, failure: followersFailure)
    }
    
    // MARK: - UITableView Delegate & DataSource
    
    override func numberOfSectionsInTableView(tableView:UITableView)->Int
    {
        return 1
    }
    
    override func tableView(tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        return users.count
    }
    
    override func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath)->UITableViewCell
    {
        let user = users[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("followerCell", forIndexPath: indexPath) as! FollowerCell
        cell.userSelectedDelegate = self
        cell.update(user)
        
        return cell        
    }
    
    override func tableView(tableView:UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let user = users[indexPath.row]
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! FollowerCell

        if selectedUsers.filter({ $0.id == user.id }).count > 0 {
            cell.checkmarkImageView.hidden = true
            selectedUsers = selectedUsers.filter({ $0.id != user.id })
        } else {
            cell.checkmarkImageView.hidden = false
            selectedUsers.append(user)
        }
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        page = 0
        searchTerm = searchText
        let data = NSDictionary(objects: [page, searchTerm], forKeys: ["p", "q"])
        UserConnector().followers(data, success: followersSuccess, failure: followersFailure)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        let data = [ "p" : 0 ]
        UserConnector().followers(data, success: followersSuccess, failure: followersFailure)
        
        page            = 0
        searchTerm      = ""
        searchBar.text  = ""
        searchBar.resignFirstResponder()
    }
}
