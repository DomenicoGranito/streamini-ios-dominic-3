//
//  HomeViewController.swift
//  Streamini
//
//  Created by Ankit Garg on 9/8/16.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//



protocol HomeViewControllerDelegate: class {
    func streamListReload()
    func changeMode(isGlobal: Bool)
}

class HomeViewController: BaseViewController, MainViewControllerDelegate, UserSelecting{
//, BaseViewController, HomeViewControllerDelegate, UserSelecting {
    @IBOutlet weak var tableView: UITableView!
    
    let dataSource  = StreamDataSource()
    weak var rootControllerDelegate: RootViewControllerDelegate?
    var isGlobal    = false
    var timer: NSTimer?
    
    // MARK: - Network responses
    let categories=["Action", "Drama", "Science Fiction", "Kids", "Horror"]
    
   
    
    override func viewWillAppear(animated:Bool)
    {
        navigationController?.navigationBarHidden=false
    }
    
    func tableView(tableView:UITableView, viewForHeaderInSection section:Int)->UIView?
    {
        let headerView=UIView(frame:CGRectMake(0,0,60,tableView.frame.size.width))
        headerView.backgroundColor=UIColor(colorLiteralRed:18/255, green:19/255, blue:21/255, alpha:1)
        
        let titleLbl=UILabel(frame:CGRectMake(5,20,310,20))
        titleLbl.text=categories[section]
        titleLbl.font=UIFont.systemFontOfSize(14)
        titleLbl.textColor=UIColor.lightGrayColor()
        
        let lineView=UIView(frame:CGRectMake(5,45,tableView.frame.size.width-10,1))
        lineView.backgroundColor=UIColor.darkGrayColor()
        
        let tapGesture=UITapGestureRecognizer(target:self, action:#selector(HomeViewController.headerTapped))
        headerView.addGestureRecognizer(tapGesture)
        
        headerView.addSubview(lineView)
        headerView.addSubview(titleLbl)
        
        return headerView
    }
    
    func headerTapped()
    {
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        let vc=storyboard.instantiateViewControllerWithIdentifier("CategoriesViewController") as! CategoriesViewController
        navigationController?.pushViewController(vc, animated:true)
    }
    
    func numberOfSectionsInTableView(tableView:UITableView)->Int
    {
        return categories.count
    }
    
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int)->Int
    {
        return 1
    }
    
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath)->UITableViewCell
    {
        let cell=tableView.dequeueReusableCellWithIdentifier("cell") as! CategoryRow
        return cell
    }

    //
    func successStreams(live: [Stream], recent: [Stream]) {
        self.tableView.pullToRefreshView.stopAnimating()
        
        dataSource.lives  = live//live.sorted({ (stream1, stream2) -> Bool in stream1.id > stream2.id })
        dataSource.recent = recent//recent.sorted({ (stream1, stream2) -> Bool in stream1.id > stream2.id })
        
        tableView.reloadData()
        
        if let delegate = rootControllerDelegate {
            delegate.modeDidChange(isGlobal)
        }
    }
    
    func failureStream(error: NSError) {
        handleError(error)
        self.tableView.pullToRefreshView.stopAnimating()
        self.navigationItem.rightBarButtonItem?.enabled = true
    }
    
    func successUser(user: User) {
        UserContainer.shared.setLogged(user)
    }
    
    func failureUser(error: NSError) {
        handleError(error)
    }
    
    // MARK: - MainViewControllerDelegate
    
    func streamListReload() {
        StreamConnector().streams(isGlobal, success: successStreams, failure: failureStream)
    }
    
    func changeMode(isGlobal: Bool) {
        self.isGlobal = isGlobal
        self.navigationItem.rightBarButtonItem?.enabled = false
        StreamConnector().streams(isGlobal, success: successStreams, failure: failureStream)
        
        if let delegate = rootControllerDelegate {
            delegate.modeDidChange(isGlobal)
        }
    }
    
    // MARK: - Update
    
    func reload(timer: NSTimer) {
        StreamConnector().streams(isGlobal, success: successStreams, failure: failureStream)
    }
    
    // MARK: - View life cycle
    
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
        changeMode(isGlobal)
        
        self.timer = NSTimer(timeInterval: NSTimeInterval(10.0), target: self, selector: #selector(HomeViewController.reload(_:)), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
        
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .None)
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        timer!.invalidate()
        timer = nil
    }
    
    
    // MARK: - UserSelecting protocol
    
    func userDidSelected(user: User) {
        self.showUserInfo(user, userStatusDelegate: nil)
    }
}


