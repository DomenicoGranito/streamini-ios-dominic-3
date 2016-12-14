//
//  MainViewController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 22/06/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

class MainViewController: BaseViewController, UserSelecting {
    @IBOutlet weak var tableView: UITableView!
    let dataSource  = StreamDataSource()
    weak var rootControllerDelegate: RootViewControllerDelegate?
    var isGlobal    = false
    var timer: NSTimer?
    
    func successStreams(live: [Stream], recent: [Stream]) {
        
        tableView.reloadData()
        
        if let delegate = rootControllerDelegate {
            delegate.modeDidChange(isGlobal)
        }
    }
    
    func failureStream(error: NSError) {
        handleError(error)
        self.navigationItem.rightBarButtonItem?.enabled = true
    }
    
    func successUser(user: User) {
        UserContainer.shared.setLogged(user)
    }
    
    func failureUser(error: NSError) {
        handleError(error)
    }
    
    func configureView() {
        dataSource.userSelectedDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        
        self.isGlobal = NSUserDefaults.standardUserDefaults().boolForKey("isGlobalStreamsInMain")

        tableView.delegate   = dataSource
        tableView.dataSource = dataSource
        tableView.addPullToRefreshWithActionHandler { () -> Void in
            StreamConnector().streams(self.isGlobal, success: self.successStreams, failure: self.failureStream)
        }
        
        UserConnector().get(nil, success: successUser, failure: failureUser)
}
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let sid = segue.identifier {
            if sid == "MainToJoinStream" || sid == "MainRecentToJoinStream" {
                let navigationController = segue.destinationViewController as! UINavigationController
                let controller = navigationController.viewControllers[0] as! JoinStreamViewController
                controller.stream = (sender as! StreamCell).stream
                controller.isRecent = (sid == "MainRecentToJoinStream")
                //controller.delegate = self
            }
        }
    }
    
    func userDidSelected(user: User) {
        //self.showUserInfo(user, userStatusDelegate: nil)
    }
}
