//
//  GetStartedViewController.swift
//  Streamini
//
//  Created by Ankit Garg on 8/27/16.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//

class GetStartedViewController: UIViewController
{
    @IBOutlet var pageControl:UIPageControl?
    @IBOutlet var titleLbl:UILabel?
    @IBOutlet var descriptionLbl:UILabel?
    
    var backgroundPlayer:BackgroundVideo?
    let titlesArray=["Beinit.Live","Discover","Stream Live Events","Search","Connect"]
    let descriptionsArray=["Connecting & Live Streaming the World of Premium Events in Asia", "Premium Events Playlists, Fashion Show Collections, Live Streaming Concerts", "Experience VR Live Stream with front row seating", "Find Agencies, Brands, Venues, Celebrities and Entertainment Talents", "Connect with industry professionals, talents and Premium Agencies."]
    var count=0
    var timer:NSTimer?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        backgroundPlayer=BackgroundVideo(onViewController:self,withVideoURL:"test.mp4")
        backgroundPlayer?.setUpBackground()
        
        titleLbl?.text=titlesArray[count]
        descriptionLbl?.text=descriptionsArray[count]
        
        timer=NSTimer.scheduledTimerWithTimeInterval(5, target:self, selector:#selector(GetStartedViewController.swipeLeft), userInfo:nil, repeats:true)
        
        let swipeLeft=UISwipeGestureRecognizer(target:self, action:#selector(GetStartedViewController.swipe(_:)))
        swipeLeft.direction = .Left
        view.addGestureRecognizer(swipeLeft)
        
        let swipeRight=UISwipeGestureRecognizer(target:self, action:#selector(GetStartedViewController.swipe(_:)))
        swipeRight.direction = .Right
        view.addGestureRecognizer(swipeRight)
    }
    
    func swipe(recognizer:UISwipeGestureRecognizer)
    {
        if(recognizer.direction == .Left)
        {
            timer?.invalidate()
            swipeLeft()
        }
        if(recognizer.direction == .Right)
        {
            timer?.invalidate()
            swipeRight()
        }
        if(recognizer.state == .Ended)
        {
            timer=NSTimer.scheduledTimerWithTimeInterval(5, target:self, selector:#selector(GetStartedViewController.swipeLeft), userInfo:nil, repeats:true)
        }
    }
    
    func swipeLeft()
    {
        count += 1
        
        if(count>4)
        {
            count=0
        }
        
        pageControl?.currentPage=count
        
        titleLbl?.text=titlesArray[count]
        descriptionLbl?.text=descriptionsArray[count]
    }
    
    func swipeRight()
    {
        count -= 1
        
        if(count<0)
        {
            count=4
        }
        
        pageControl?.currentPage=count
        
        titleLbl?.text=titlesArray[count]
        descriptionLbl?.text=descriptionsArray[count]
    }
}
