//
//  PeopleViewController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 10/08/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

class PeopleViewController: BaseViewController, UserSelecting, ProfileDelegate, UISearchBarDelegate, UserStatusDelegate {
    var dataSource: PeopleDataSource?
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchBarTop: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    var isSearchMode = true
    
    // MARK: - Actions
    
    func showSearch(animated: Bool) {
        if !isSearchMode {
            if animated {
                UIView.animateWithDuration(0.15, animations: { () -> Void in
                    self.searchBarTop.constant = 0
                    self.view.layoutIfNeeded()
                })
            } else {
                self.searchBarTop.constant = 0
                self.view.layoutIfNeeded()
            }
            isSearchMode = true
            searchBar.becomeFirstResponder()
        }
    }
    
    func hideSearch(animated: Bool) {
        if isSearchMode {
            if animated {
                UIView.animateWithDuration(0.15, animations: { () -> Void in
                    self.searchBarTop.constant = -self.searchBar.bounds.size.height
                    self.view.layoutIfNeeded()
                })
            } else {
                self.searchBarTop.constant = -44
                self.view.layoutIfNeeded()
            }
            isSearchMode = false
            dataSource!.isSearchMode = false
            searchBar.text = ""
            searchBar.resignFirstResponder()
        }
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarCancelButtonClicked(searchBar:UISearchBar)
    {
        hideSearch(true)
        dataSource!.reload()
    }
    
    // called when text changes (including clear)
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count > 1 {
            let data = NSDictionary(dictionary: ["p" : 0, "q" : searchText])
            dataSource!.isSearchMode = true
            dataSource!.search(data)
        }
    }
        
    // MARK: - View life cycle

    func configureView() {
        emptyLabel.text = NSLocalizedString("table_no_data", comment: "")
        
        tableView.tableFooterView = UIView()
        tableView.addPullToRefreshWithActionHandler { () -> Void in
            self.dataSource!.reload()
        }
        tableView.addInfiniteScrollingWithActionHandler { () -> Void in
            self.dataSource!.fetchMore()
        }
        
        self.dataSource = PeopleDataSource(tableView: tableView)
        dataSource!.userSelectedDelegate = self
        hideSearch(false)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        configureView()
        
        dataSource!.reload()
    }
    
    override func viewWillAppear(animated:Bool)
    {
        navigationController?.navigationBarHidden=false
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation:.Fade)
    }
    
    // MARK: - ProfileDelegate
    
    func reload()
    {
        dataSource!.reload()
    }
    
    func close()
    {
        
    }    
    
    // MARK: - UserStatusDelegate
    
    func followStatusDidChange(status: Bool, user: User)
    {
        dataSource!.updateUser(user, isFollowed: status, isBlocked: user.isBlocked)
    }
    
    func blockStatusDidChange(status: Bool, user: User)
    {
        dataSource!.updateUser(user, isFollowed: user.isFollowed, isBlocked: status)
    }
    
    // MARK: - UserSelecting protocol
    
    func userDidSelected(user:User)
    {
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        let vc=storyboard.instantiateViewControllerWithIdentifier("UserViewControllerId") as! UserViewController
        vc.user=user
        navigationController?.pushViewController(vc, animated:true)
        
        searchBar.resignFirstResponder()
    }
}
