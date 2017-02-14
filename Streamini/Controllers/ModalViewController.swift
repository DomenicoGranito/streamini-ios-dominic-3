//
//  ModalViewController.swift
//  MusicPlayerTransition
//
//  Created by xxxAIRINxxx on 2015/02/25.
//  Copyright (c) 2015 xxxAIRINxxx. All rights reserved.
//

import UIKit
import AVKit

class ModalViewController: UIViewController
{
    @IBOutlet var headerTitleLbl:UILabel?
    @IBOutlet var videoTitleLbl:UILabel?
    @IBOutlet var videoArtistNameLbl:UILabel?
    @IBOutlet var videoProgressDurationLbl:UILabel?
    @IBOutlet var videoDurationLbl:UILabel?
    @IBOutlet var likeButton:UIButton?
    @IBOutlet var playButton:UIButton?
    @IBOutlet var playerView:UIView?
    @IBOutlet var controlsView:UIView?
    @IBOutlet var seekBar:UISlider?
    
    
   // @IBOutlet weak var playerView: PlayerView!
    
    
    var liked=false
    var isPlaying=false
    var player:AVPlayer?
    var timer:NSTimer?
    
    var stream: Stream?
    
    override func viewDidLoad()
    {
        
        headerTitleLbl?.text=stream?.title
        videoTitleLbl?.text=stream?.title
        videoArtistNameLbl?.text=stream?.user.name
        let (host, port, application, _, _) = Config.shared.wowza()
       // let videoURL=NSURL(string:"https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")
        let videoURL=NSURL(string:"http://\(host)/media/\(stream!.id).mp4")
        player=AVPlayer(URL:videoURL!)
        
        let durationSeconds=Int(CMTimeGetSeconds(player!.currentItem!.asset.duration))
        videoDurationLbl?.text="-\(secondsToReadableTime(durationSeconds))"
        seekBar!.maximumValue=Float(durationSeconds)

        player!.addPeriodicTimeObserverForInterval(CMTimeMake(1, 1), queue:dispatch_get_main_queue())
        {_ in
            if self.player!.currentItem!.status == .ReadyToPlay
            {
                let time=Int(CMTimeGetSeconds(self.player!.currentTime()))
                self.videoProgressDurationLbl!.text=self.secondsToReadableTime(time)
                self.videoDurationLbl!.text="-\(self.secondsToReadableTime(durationSeconds-time))"
                self.seekBar!.value=Float(time)
            }
        }
        
        let playerController=AVPlayerViewController()
        playerController.showsPlaybackControls=false
        playerController.player=player
        addChildViewController(playerController)
        playerView!.addSubview(playerController.view)
        playerController.view.frame=playerView!.frame
    }
    
    override func viewDidAppear(animated:Bool)
    {
        timer?.invalidate()
        
        playButton?.setImage(UIImage(named:"big_play_button"), forState:.Normal)
        controlsView?.hidden=false
        
        isPlaying=false
        
        timer=NSTimer.scheduledTimerWithTimeInterval(5, target:self, selector:#selector(hideControls), userInfo:nil, repeats:true)
        
        let tapGesture=UITapGestureRecognizer(target:self, action:#selector(showControls))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidDisappear(animated:Bool)
    {
        player?.pause()
    }
    
    func showControls()
    {
        controlsView?.hidden=false
        
        timer?.invalidate()
        
        timer=NSTimer.scheduledTimerWithTimeInterval(5, target:self, selector:#selector(hideControls), userInfo:nil, repeats:true)
    }
    
    func hideControls()
    {
       // controlsView?.hidden=true
    }
    
    func secondsToReadableTime(durationSeconds:Int)->String
    {
        var readableDuration=""
        
        let hours=durationSeconds/3600
        var minutes=String(format:"%02d", durationSeconds%3600/60)
        let seconds=String(format:"%02d", durationSeconds%3600%60)
        
        if(hours>0)
        {
            readableDuration="\(hours):"
        }
        else
        {
            minutes="\(Int(minutes)!)"
        }
        
        readableDuration+="\(minutes):\(seconds)"
        
        return readableDuration
    }
    
    @IBAction func seekBarValueChanged()
    {
        let seconds=Int64(seekBar!.value)
        let targetTime=CMTimeMake(seconds, 1)
        
        player!.seekToTime(targetTime)
    }
    
    @IBAction func close()
    {
        dismissViewControllerAnimated(true, completion:nil)
    }
    
    @IBAction func menu()
    {
        
    }

    @IBAction func like()
    {
        if liked
        {
            likeButton?.setImage(UIImage(named:"empty_heart"), forState:.Normal)
            liked=false
        }
        else
        {
            likeButton?.setImage(UIImage(named:"red_heart"), forState:.Normal)
            liked=true
        }
    }
    
    @IBAction func shuffle()
    {
        
    }
    
    @IBAction func previous()
    {
        
    }

    @IBAction func play()
    {
        if isPlaying
        {
            player?.pause()
            
            playButton?.setImage(UIImage(named:"big_play_button"), forState:.Normal)
            isPlaying=false
        }
        else
        {
            player?.play()
            
            playButton?.setImage(UIImage(named:"big_pause_button"), forState:.Normal)
            isPlaying=true
        }
    }
    
    @IBAction func next()
    {
        
    }
    
    func userDidSelected(user:User)
    {
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        let vc=storyboard.instantiateViewControllerWithIdentifier("UserViewControllerId") as! UserViewController
        vc.user=user
        navigationController?.pushViewController(vc, animated:true)
        
        
    }

    
    @IBAction func more()
    {
        
    }
}
