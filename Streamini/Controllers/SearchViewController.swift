//
//  PeopleViewController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 10/08/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

class SearchViewController: BaseViewController, UserSelecting, StreamSelecting, ProfileDelegate, UISearchBarDelegate, UserStatusDelegate {
    var dataSource: SearchDataSource?
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTypeSegment: UISegmentedControl!
    
    var isSearchMode = true
    
    @IBAction func changeMode(sender: AnyObject) {
        switch searchTypeSegment.selectedSegmentIndex
        {
        case 0:
            searchBar.resignFirstResponder()
            dataSource?.changeMode("categories")
            break;
        case 1:
            searchBar.resignFirstResponder()
            dataSource?.changeMode("places")
            break;
        default:
            dataSource?.changeMode("people")
            break; 
        }
    }

    // MARK: - UISearchBarDelegate
    
    // called when cancel button pressed
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // called when text changes (including clear)
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count > 1 && (dataSource!.mode == "streams" || dataSource!.mode == "people") {
            dataSource!.search(searchText)
        }
    }
    
    // MARK: - View life cycle
    
    func configureView() {
        
        tableView.tableFooterView = UIView()
        tableView.addInfiniteScrollingWithActionHandler { () -> Void in
            self.dataSource!.fetchMore()
        }
        
        self.dataSource = SearchDataSource(tableView: tableView)
        dataSource!.userSelectedDelegate = self
        dataSource!.streamSelectedDelegate = self
        
        searchTypeSegment.setTitle(NSLocalizedString("broadcasts", comment: ""), forSegmentAtIndex: 0)
        searchTypeSegment.setTitle(NSLocalizedString("places", comment: ""), forSegmentAtIndex: 1)
        searchTypeSegment.setTitle(NSLocalizedString("people", comment: ""), forSegmentAtIndex: 2)
        
        //self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        configureView()
        
        dataSource!.reload()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
    }
    
    // MARK: - ProfileDelegate
    
    func reload() {
        dataSource!.reload()
    }
    
    func close() {
    }
    
    // MARK: - UserStatusDelegate
    
    func followStatusDidChange(status: Bool, user: User) {
        dataSource!.updateUser(user, isFollowed: status, isBlocked: user.isBlocked)
    }
    
    func blockStatusDidChange(status: Bool, user: User) {
        dataSource!.updateUser(user, isFollowed: user.isFollowed, isBlocked: status)
    }
    
    // MARK: - SearchSelecting protocol
    
    func userDidSelected(user: User) {
        self.showUserInfo(user, userStatusDelegate: self)
        searchBar.resignFirstResponder()
    }
    
    func streamDidSelected(stream: Stream) {
        // Load join controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let joinNavController = storyboard.instantiateViewControllerWithIdentifier("JoinStreamNavigationControllerId") as! UINavigationController
        let joinController = joinNavController.viewControllers[0] as! JoinStreamViewController
        
        // Setup joinController
        joinController.stream   = stream
        joinController.isRecent = (stream.ended != nil)
        
        // Show JoinController
        self.presentViewController(joinNavController, animated: true, completion: nil)
    }
}
