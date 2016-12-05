//
//  PlayerView.swift
//  BEINIT
//
//  Created by Dominic Granito on 5/12/2016.
//  Copyright © 2016 UniProgy s.r.o. All rights reserved.
//


import UIKit

protocol PlayerViewDelegate: class {
    func playerViewWillBeShown(playerView: PlayerView)
    func playerViewWillBeHidden(playerView: PlayerView)
    func reportButtonPressed()
    func shareButtonPressed()
}

class PlayerView: UIView {
    @IBOutlet weak var streamNameLabel: UILabel!
    @IBOutlet weak var streamNameHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var reportButton: UIButton!
    var stream: Stream?
    weak var delegate: PlayerViewDelegate?
    weak var userSelectingDelegate: UserSelecting?
    var userSelectingHandler: UserSelectingHandler?
    
    // MAKR: - View life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.userInteractionEnabled = false
        
        shareButton.addTarget(self, action: #selector(PlayerView.shareButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        reportButton.addTarget(self, action: #selector(PlayerView.reportButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    // MARK: - Actions
    
    @IBAction func tapGesturePerformed(sender: AnyObject) {
        self.hide()
    }
    
    func shareButtonPressed(sender: UIButton) {
        if let del = self.delegate {
            del.shareButtonPressed()
        }
    }
    
    func reportButtonPressed(sender: UIButton) {
        if let del = self.delegate {
            del.reportButtonPressed()
        }
    }
    
    // MARK: - Show/hide methods
    
    func show(isOwner: Bool) {
        shareButton.hidden  = isOwner
        reportButton.hidden = isOwner
        self.userInteractionEnabled = true
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.alpha = 1.0
        })
        
        if let del = delegate {
            del.playerViewWillBeShown(self)
        }
    }
    
    func hide() {
        self.userInteractionEnabled = false
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.alpha = 0.0
        })
        
        if let del = delegate {
            del.playerViewWillBeHidden(self)
        }
    }
    
    // MARK: - Update data
    
    func update(stream: Stream) {
        func setupButton(button: UIButton, image: UIImage, title: String, top: CGFloat) {
            button.setImage(image, forState: UIControlState.Normal)
            button.titleEdgeInsets = UIEdgeInsetsMake(0, 15.0, 0.0, 0.0)
            button.imageEdgeInsets = UIEdgeInsetsMake(top, 0.0, 0.0, 0.0)
            button.setTitle(title, forState: UIControlState.Normal)
            button.setImageTintColor(UIColor(white: 1.0, alpha: 1.0), forState: UIControlState.Normal)
            button.setImageTintColor(UIColor(white: 1.0, alpha: 0.5), forState: UIControlState.Highlighted)
            button.setTitleColor(UIColor(white: 1.0, alpha: 1.0), forState: UIControlState.Normal)
            button.setTitleColor(UIColor(white: 1.0, alpha: 0.5), forState: UIControlState.Highlighted)
        }
        
        self.stream = stream
        
        if let del = userSelectingDelegate {
            self.userSelectingHandler = UserSelectingHandler(imageView: userImageView, delegate: del, user: stream.user)
        }
        
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
        
        let shareText = NSLocalizedString("stream_info_share_button", comment: "")
        setupButton(shareButton, image: UIImage(named: "share")!, title: shareText, top: -5.0)
        
        let reportText = NSLocalizedString("stream_info_report_button", comment: "")
        setupButton(reportButton, image: UIImage(named: "report")!, title: reportText, top: 0.0)
        
        self.layoutIfNeeded()
    }
}
