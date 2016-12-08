//
//  RootViewController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 11/08/15.
//  Copyright (c) 2015 Evghenii Todorov. All rights reserved.
//

import Photos

protocol RootViewControllerDelegate: class {
    func modeDidChange(isGlobal: Bool)
}

class RootViewController: BaseViewController, RootViewControllerDelegate {
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var recButton: UIButton!
    @IBOutlet weak var peopleButton: UIButton!    
    @IBOutlet weak var containerView: UIView!
    var containerViewController: ContainerViewController?
    
   // weak var delegate: MainViewControllerDelegate?
   // weak var delegate: HomeViewControllerDelegate?
    var isGlobal = false
    
    // MARK: - Actions
    
    @IBAction func recButtonPressed(sender: AnyObject) {
        self.performSegueWithIdentifier("RootToCreate", sender: self)
    }
    
    @IBAction func peopleButtonPressed(sender: AnyObject) {
        containerViewController!.peopleViewController()
        homeButton.selected   = false
        peopleButton.selected = true
        setupPeopleNavigationItems()
    }
    
    @IBAction func mainButtonPressed(sender: AnyObject) {
        containerViewController!.mainViewController()
        homeButton.selected   = true
        peopleButton.selected = false
        setupMainNavigationItems()
    }
    
    func profileButtonItemPressed(sender: AnyObject) {
        self.performSegueWithIdentifier("RootToProfile", sender: nil)
    }
    
    func searchButtonItemPressed(sender: AnyObject) {
        let peopleController = containerViewController!.childViewControllers[0] as! PeopleViewController
        if peopleController.isSearchMode {
            peopleController.hideSearch(true)
            peopleController.dataSource!.reload()
        } else {
            peopleController.showSearch(true)
        }
    }
    
    // MARK: - Setup Navigation Items
    
    func setupPeopleNavigationItems() {
        self.title = NSLocalizedString("people_title", comment: "")
        
        let leftButton = UIButton(frame: CGRectMake(0.0, 0.0, 25.0, 25.0))
        leftButton.setImage(UIImage(named: "search"), forState: UIControlState.Normal)
        leftButton.addTarget(self, action: #selector(RootViewController.searchButtonItemPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        leftButton.setImageTintColor(UIColor(white: 1.0, alpha: 0.5), forState: UIControlState.Normal)
        leftButton.setImageTintColor(UIColor(white: 1.0, alpha: 1.0), forState: UIControlState.Highlighted)
        let leftBarButtonItem = UIBarButtonItem(customView: leftButton)
        
        let rightButton = UIButton(frame: CGRectMake(0.0, 0.0, 25.0, 25.0))
        rightButton.setImage(UIImage(named: "profile"), forState: UIControlState.Normal)
        rightButton.addTarget(self, action: #selector(RootViewController.profileButtonItemPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        rightButton.setImageTintColor(UIColor(white: 1.0, alpha: 0.5), forState: UIControlState.Normal)
        rightButton.setImageTintColor(UIColor(white: 1.0, alpha: 1.0), forState: UIControlState.Highlighted)
        let rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        
        self.navigationItem.leftBarButtonItem  = leftBarButtonItem
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    func setupMainNavigationItems() {
        self.navigationItem.rightBarButtonItem?.enabled = true
        let itemImage: UIImage
        if isGlobal {
            self.title = NSLocalizedString("global_title",  comment: "")
            itemImage = UIImage(named: "following")!
        } else {
            self.title = ""//NSLocalizedString("followed_title",  comment: "")
            itemImage = UIImage(named: "global")!
        }
        
        let button = UIButton(frame: CGRectMake(0.0, 0.0, 125.0, 25.0))
        button.setImage(itemImage, forState: UIControlState.Normal)
      ///  button.addTarget(self, action: #selector(RootViewController.modeChanged), forControlEvents: UIControlEvents.TouchUpInside)
        button.setImageTintColor(UIColor(white: 1.0, alpha: 0.5), forState: UIControlState.Normal)
        button.setImageTintColor(UIColor(white: 1.0, alpha: 1.0), forState: UIControlState.Highlighted)
        let item = UIBarButtonItem(customView: button)
        
        let leftButton = UIButton(frame: CGRectMake(0.0, 0.0, 25.0, 25.0))
        leftButton.setImage(UIImage(named: "search"), forState: UIControlState.Normal)
        leftButton.addTarget(self, action: #selector(RootViewController.searchTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        leftButton.setImageTintColor(UIColor(white: 1.0, alpha: 0.5), forState: UIControlState.Normal)
        leftButton.setImageTintColor(UIColor(white: 1.0, alpha: 1.0), forState: UIControlState.Highlighted)
        let leftBarButtonItem = UIBarButtonItem(customView: leftButton)
        
        self.navigationItem.rightBarButtonItem = item
        self.navigationItem.leftBarButtonItem  = leftBarButtonItem
    }
    
    // MARK: - RootViewControllerDelegate
    
    func modeDidChange(isGlobal: Bool) {
        self.isGlobal = isGlobal
        NSUserDefaults.standardUserDefaults().setBool(isGlobal, forKey: "isGlobalStreamsInMain")
        
        if homeButton.selected {
            setupMainNavigationItems()
        }
    }
    
   // func modeChanged() {
     //   if let del = delegate {
       //     del.changeMode(!isGlobal)
       // }
    //}
    
    func searchTapped(sender: AnyObject)
    {
        // Load controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("SearchScreen")
        // Show Controller
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    // MARK: - View life cycle
    
    func configureView() {
        self.navigationController!.navigationBarHidden = false
        self.navigationItem.hidesBackButton = true
        self.navigationController!.navigationBar.titleTextAttributes = [ NSForegroundColorAttributeName: UIColor.whiteColor() ]
        
        let normalStateColor = UIColor.buttonNormalColor()
        let highlightedStateColor = UIColor.buttonHighlightedColor()
        
        homeButton.setImageTintColor(normalStateColor, forState: UIControlState.Normal)
        homeButton.setImageTintColor(highlightedStateColor, forState: UIControlState.Highlighted)
        homeButton.setImageTintColor(highlightedStateColor, forState: UIControlState.Selected)
        homeButton.selected = true
        
        peopleButton.setImageTintColor(normalStateColor, forState: UIControlState.Normal)
        peopleButton.setImageTintColor(highlightedStateColor, forState: UIControlState.Highlighted)
        peopleButton.setImageTintColor(highlightedStateColor, forState: UIControlState.Selected)
        
        recButton.setImage(UIImage(named: "rec-off"), forState: UIControlState.Normal)
        recButton.setImage(UIImage(named: "rec-on"), forState: UIControlState.Highlighted)
        
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()        
        modeDidChange(false)
        
        // Ask for use CLLocationManager
        LocationManager.shared
        
        // Ask for use Camera
        if AVCaptureDevice.respondsToSelector(#selector(AVCaptureDevice.requestAccessForMediaType(_:completionHandler:))) {
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { (granted) -> Void in
            })
        }
        
        // Ask for use Microphone
        if (AVAudioSession.sharedInstance().respondsToSelector(#selector(AVAudioSession.requestRecordPermission(_:)))) {
            AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                //
            })
            
        }
        
        // Ask for use Photo Gallery
        if NSClassFromString("PHPhotoLibrary") != nil {
                if #available(iOS 8.0, *) {
                    PHPhotoLibrary.requestAuthorization { (status) -> Void in
                }
                } else {
                    // Fallback on earlier versions
                }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let sid = segue.identifier {
            if sid == "RootToContainer" {
                containerViewController = segue.destinationViewController as? ContainerViewController
                containerViewController!.parentController = self
            }
            
            if sid == "RootToProfile" {
                let peopleController = containerViewController!.childViewControllers[0] as! PeopleViewController
                let profileController = segue.destinationViewController as! ProfileViewController
                profileController.profileDelegate = peopleController
            }
        }
    }
}
