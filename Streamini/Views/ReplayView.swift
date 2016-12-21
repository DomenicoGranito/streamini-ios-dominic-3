//
//  ReplayView.swift
// Streamini
//
//  Created by Vasily Evreinov on 24/07/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

protocol ReplayViewDelegate: class {
    func replayViewWillBeShown(replayView: ReplayView)
    func replayViewWillBeHidden(replayView: ReplayView)
    func replayViewStreamDidEnd(replayView: ReplayView)
    func replayViewPlayButtonPressed(replayView: ReplayView)
    func replayViewCloseButtonPressed(replayView: ReplayView)
    func replayViewViewersButtonPressed(replayView: ReplayView)
    func replayViewReplaysButtonPressed(replayView: ReplayView)
}

class ReplayView: UIView {
    @IBOutlet weak var streamNameLabel: UILabel!
    @IBOutlet weak var streamNameHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var likesValueLabel: UILabel!
    @IBOutlet weak var viewersLabel: UILabel!
    @IBOutlet weak var viewersValueLabel: UILabel!
    @IBOutlet weak var replaysLabel: UILabel!
    @IBOutlet weak var replaysValueLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var viewersButton: UIButton!
    @IBOutlet weak var replaysButton: UIButton!
    
    var viewersIsShown = false
    var replaysIsShown = false
    weak var delegate: ReplayViewDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.userInteractionEnabled = true
        
        self.backgroundColor = UIColor(white: 0.0, alpha: 0.6)
        
        //playButton.addTarget(self, action: #selector(ReplayView.playButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        //closeButton.addTarget(self, action: #selector(ReplayView.closeButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        //viewersButton.addTarget(self, action: #selector(ReplayView.viewersButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        //replaysButton.addTarget(self, action: #selector(ReplayView.replaysButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        //viewersLabel.text   = NSLocalizedString("stat_viewers", comment: "")
        //likesLabel.text     = NSLocalizedString("stat_likes", comment: "")
        //replaysLabel.text   = NSLocalizedString("stat_replays", comment: "")
    }
    
    func playButtonPressed(sender: UIView) {
        if let del = delegate {
            playButton.hidden = true
            del.replayViewPlayButtonPressed(self)
        }
    }
    
    func closeButtonPressed(sender: UIView) {
        if let del = delegate {
            del.replayViewCloseButtonPressed(self)
        }
    }
    
    func viewersButtonPressed(sender: UIView) {
        if let del = delegate {
            del.replayViewViewersButtonPressed(self)
        }
        viewersIsShown = !viewersIsShown
        replaysIsShown = false
        
        viewersButton.superview?.alpha = viewersIsShown ? 1.0 : 0.5
        replaysButton.superview?.alpha = 0.5
    }
    
    func replaysButtonPressed(sender: UIView) {
        if let del = delegate {
            del.replayViewReplaysButtonPressed(self)
        }
        replaysIsShown = !replaysIsShown
        viewersIsShown = false
        replaysButton.superview?.alpha = replaysIsShown ? 1.0 : 0.5
        viewersButton.superview?.alpha = 0.5
    }
    
    func show() {
        self.userInteractionEnabled = true
        self.playButton.hidden = false
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.alpha = 1.0
        })
        
        if let del = delegate {
            del.replayViewWillBeShown(self)
        }
    }
    
    func streamEnd() {
        self.userInteractionEnabled = true
        self.playButton.hidden = false
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.alpha = 1.0
        })
        
        if let del = delegate {
            del.replayViewStreamDidEnd(self)
        }
    }
    
    func hide(animated: Bool) {
        self.userInteractionEnabled = false
        
        if animated {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.alpha = 0.0
            })
        } else {
            self.alpha = 0.0
        }
        
        if let del = delegate {
            del.replayViewWillBeHidden(self)
        }
    }
    
    func update(stream: Stream) {
        streamNameLabel.text = stream.title
        let expectedSize = streamNameLabel.sizeThatFits(CGSizeMake(streamNameLabel.bounds.size.width, 10000))
        streamNameHeightConstraint.constant = expectedSize.height
        
        if !stream.city.isEmpty {
            locationLabel.text = stream.city
            
            let size = locationLabel.sizeThatFits(locationLabel.bounds.size)
            locationWidthConstraint.constant = size.width + 10
            locationLabel.hidden = false
        }
        
        usernameLabel.text = stream.user.name
        
        userImageView.sd_setImageWithURL(stream.user.avatarURL())
        
        likesValueLabel.text = "\(stream.likes)"
        viewersValueLabel.text = "\(stream.tviewers)"
        replaysValueLabel.text = "\(stream.rviewers)"
        
        self.layoutIfNeeded()
    }
}
