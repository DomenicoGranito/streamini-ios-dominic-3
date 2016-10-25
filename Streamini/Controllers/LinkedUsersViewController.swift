//
//  LinkedUsersViewController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 06/08/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

class LinkedUsersViewController: UIViewController, UserStatisticsDelegate, StreamSelecting {
    @IBOutlet weak var selectorView: SelectorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    var dataSource: UserStatisticsDataSource?
    var profileDelegate: ProfileDelegate?
    
    // MARK: - View life cycle
    
    func configureView() {
        self.tableView.tableFooterView = UIView()
        emptyLabel.text = NSLocalizedString("table_no_data", comment: "")
        
        tableView.addPullToRefreshWithActionHandler { () -> Void in
            self.dataSource!.reload()
        }

        tableView.addInfiniteScrollingWithActionHandler { () -> Void in
            self.dataSource!.fetchMore()
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        configureView()
    }
        
    // MARK: - StreamSelecting
    
    func streamDidSelected(stream: Stream) {
        // Post notifications to current controllers
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "Close/Leave", object: nil))
        
        // Dismiss all view controllers behind MainViewController
        let root = UIApplication.sharedApplication().delegate!.window!?.rootViewController as! UINavigationController
        
        if root.topViewController!.presentedViewController != nil {
            root.topViewController!.presentedViewController!.dismissViewControllerAnimated(true, completion: nil)
        }
        
        // Load join controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let joinNavController = storyboard.instantiateViewControllerWithIdentifier("JoinStreamNavigationControllerId") as! UINavigationController
        let joinController = joinNavController.viewControllers[0] as! JoinStreamViewController
        
        // Setup joinController
        joinController.stream   = stream
        joinController.isRecent = (stream.ended != nil)
        
        // Show JoinController
        root.presentViewController(joinNavController, animated: true, completion: nil)
        
        if let delegate = profileDelegate {
            delegate.close()
        }
    }

    // MARK: - ProfileDelegate
    
    func reload() {
        // reload header view
    }
    
    // MARK: - UserStatisticsDelegate
    
    func recentStreamsDidSelected(userId: UInt) {
        tableView.showsPullToRefresh     = false
        tableView.showsInfiniteScrolling = false
        selectorView.selectSection(0)
        self.dataSource = RecentStreamsDataSource(userId: userId, tableView: tableView)
        dataSource!.streamSelectedDelegate = self
        dataSource!.profileDelegate = profileDelegate
        dataSource!.clean()
        dataSource!.reload()
    }
    
    func followersDidSelected(userId: UInt) {
        tableView.showsPullToRefresh     = true
        tableView.showsInfiniteScrolling = true
        selectorView.selectSection(1)
        self.dataSource = FollowersDataSource(userId: userId, tableView: tableView)
        dataSource!.profileDelegate = profileDelegate
        dataSource!.clean()
        dataSource!.reload()
    }
    
    func followingDidSelected(userId: UInt) {
        tableView.showsPullToRefresh     = true
        tableView.showsInfiniteScrolling = true
        selectorView.selectSection(2)
        self.dataSource = FollowingDataSource(userId: userId, tableView: tableView)
        dataSource!.profileDelegate = profileDelegate
        dataSource!.clean()        
        dataSource!.reload()
    }
}
