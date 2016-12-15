//
//  RootViewController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 11/08/15.
//  Copyright (c) 2015 Evghenii Todorov. All rights reserved.
//

import Photos

class RootViewController: BaseViewController
{
    @IBOutlet var homeButton:UIButton!
    @IBOutlet var recButton:UIButton!
    @IBOutlet var peopleButton:UIButton!
    @IBOutlet var containerView:UIView!
    var containerViewController:ContainerViewController?
    
    @IBAction func recButtonPressed(sender:AnyObject)
    {
        self.performSegueWithIdentifier("RootToCreate", sender:self)
    }
    
    @IBAction func peopleButtonPressed(sender:AnyObject)
    {
        containerViewController!.peopleViewController()
        homeButton.selected=false
        peopleButton.selected=true
        setupPeopleNavigationItems()
    }
    
    @IBAction func mainButtonPressed(sender:AnyObject)
    {
        containerViewController!.mainViewController()
        homeButton.selected=true
        peopleButton.selected=false
        setupMainNavigationItems()
    }
    
    func profileButtonItemPressed()
    {
        self.performSegueWithIdentifier("RootToProfile", sender:nil)
    }
    
    func searchButtonItemPressed()
    {
        let peopleController=containerViewController!.childViewControllers[0] as! PeopleViewController
        if peopleController.isSearchMode
        {
            peopleController.hideSearch(true)
            peopleController.dataSource!.reload()
        }
        else
        {
            peopleController.showSearch(true)
        }
    }
    
    func setupPeopleNavigationItems()
    {
        self.title=NSLocalizedString("people_title", comment:"")
        
        let leftButton=UIButton(frame:CGRectMake(0, 0, 25, 25))
        leftButton.setImage(UIImage(named:"search"), forState:.Normal)
        leftButton.addTarget(self, action:#selector(searchButtonItemPressed), forControlEvents:.TouchUpInside)
        leftButton.setImageTintColor(UIColor(white:1, alpha:0.5), forState:.Normal)
        leftButton.setImageTintColor(UIColor(white:1, alpha:1), forState:.Highlighted)
        let leftBarButtonItem=UIBarButtonItem(customView:leftButton)
        
        let rightButton=UIButton(frame:CGRectMake(0, 0, 25, 25))
        rightButton.setImage(UIImage(named:"profile"), forState:.Normal)
        rightButton.addTarget(self, action:#selector(profileButtonItemPressed), forControlEvents:.TouchUpInside)
        rightButton.setImageTintColor(UIColor(white:1, alpha:0.5), forState:.Normal)
        rightButton.setImageTintColor(UIColor(white:1, alpha:1), forState:.Highlighted)
        let rightBarButtonItem=UIBarButtonItem(customView:rightButton)
        
        self.navigationItem.leftBarButtonItem=leftBarButtonItem
        self.navigationItem.rightBarButtonItem=rightBarButtonItem
    }
    
    func setupMainNavigationItems()
    {
        self.title=""
        
        let button=UIButton(frame:CGRectMake(0, 0, 125, 25))
        button.setImage(UIImage(named:"global"), forState:.Normal)
        button.setImageTintColor(UIColor(white:1, alpha:0.5), forState:.Normal)
        button.setImageTintColor(UIColor(white:1, alpha:1), forState:.Highlighted)
        let item=UIBarButtonItem(customView:button)
        
        let leftButton=UIButton(frame:CGRectMake(0, 0, 25, 25))
        leftButton.setImage(UIImage(named:"search"), forState:.Normal)
        leftButton.addTarget(self, action:#selector(searchTapped), forControlEvents:.TouchUpInside)
        leftButton.setImageTintColor(UIColor(white:1, alpha:0.5), forState:.Normal)
        leftButton.setImageTintColor(UIColor(white:1, alpha:1), forState:.Highlighted)
        let leftBarButtonItem=UIBarButtonItem(customView:leftButton)
        
        self.navigationItem.rightBarButtonItem=item
        self.navigationItem.leftBarButtonItem=leftBarButtonItem
    }
    
    func searchTapped()
    {
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        let controller=storyboard.instantiateViewControllerWithIdentifier("SearchScreen")
        self.presentViewController(controller, animated:true, completion:nil)
    }
    
    func configureView()
    {
        self.navigationController!.navigationBarHidden=false
        self.navigationItem.hidesBackButton=true
        self.navigationController!.navigationBar.titleTextAttributes=[NSForegroundColorAttributeName:UIColor.whiteColor()]
        
        let normalStateColor=UIColor.buttonNormalColor()
        let highlightedStateColor=UIColor.buttonHighlightedColor()
        
        homeButton.setImageTintColor(normalStateColor, forState:.Normal)
        homeButton.setImageTintColor(highlightedStateColor, forState:.Highlighted)
        homeButton.setImageTintColor(highlightedStateColor, forState:.Selected)
        homeButton.selected=true
        
        peopleButton.setImageTintColor(normalStateColor, forState:.Normal)
        peopleButton.setImageTintColor(highlightedStateColor, forState:.Highlighted)
        peopleButton.setImageTintColor(highlightedStateColor, forState:.Selected)
        
        recButton.setImage(UIImage(named:"rec-off"), forState:.Normal)
        recButton.setImage(UIImage(named:"rec-on"), forState:.Highlighted)
    }

    override func viewDidLoad()
    {
        configureView()
        setupMainNavigationItems()
        
        // Ask for use Camera
        if AVCaptureDevice.respondsToSelector(#selector(AVCaptureDevice.requestAccessForMediaType(_:completionHandler:)))
        {
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler:{(granted)->Void in })
        }
        
        // Ask for use Microphone
        if(AVAudioSession.sharedInstance().respondsToSelector(#selector(AVAudioSession.requestRecordPermission(_:))))
        {
            AVAudioSession.sharedInstance().requestRecordPermission({(granted:Bool)->Void in })
        }
        
        // Ask for use Photo Gallery
        if NSClassFromString("PHPhotoLibrary") != nil
        {
                if #available(iOS 8.0, *)
                {
                    PHPhotoLibrary.requestAuthorization{(status)->Void in }
                }
        }
    }
    
    override func prepareForSegue(segue:UIStoryboardSegue, sender:AnyObject?)
    {
        if let sid=segue.identifier
        {
            if sid=="RootToContainer"
            {
                containerViewController=segue.destinationViewController as? ContainerViewController
                containerViewController!.parentController=self
            }
            
            if sid=="RootToProfile"
            {
                let peopleController=containerViewController!.childViewControllers[0] as! PeopleViewController
                let profileController=segue.destinationViewController as! ProfileViewController
                profileController.profileDelegate=peopleController
            }
        }
    }
}
