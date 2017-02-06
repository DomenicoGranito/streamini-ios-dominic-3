//
//  RecentStreamCell.swift
//  Streamini
//
//  Created by Vasily Evreinov on 23/07/15.
//  Copyright (c) 2015 Evghenii Todorov. All rights reserved.
//

import UIKit

class RecentStreamCell: StreamCell {
    @IBOutlet weak var streamNameLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var streamEndedLabel: UILabel!
    @IBOutlet weak var playImageView: UIImageView!
    @IBOutlet weak var playWidthConstraint: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func update(stream: Stream) {
      
        let (host, port, application, _, _) = Config.shared.wowza()
        
        super.update(stream)
        playImageView.sd_setImageWithURL(NSURL(string:"http://\(host)/thumbs/\(stream.id).jpg"))
        userLabel.text = stream.user.name
        streamNameLabel.text  = stream.title
        streamEndedLabel.text = stream.ended!.timeAgoSimple
    }
    
    func updateMyStream(stream: Stream) {
        super.update(stream)
        
        userLabel.text = UserContainer.shared.logged().name
        
        var isLessThan24Hours = false
        if let date = stream.ended {
            isLessThan24Hours = NSDate().lessThan24Hours(date)
        }
        
        playImageView.hidden  = !isLessThan24Hours
        self.userInteractionEnabled = isLessThan24Hours
        streamNameLabel.text  = stream.title
        
        if let time = stream.ended {
            streamEndedLabel.text = time.timeAgoSimple
        } else {
            streamEndedLabel.text = ""
        }

        
        playWidthConstraint.constant = (isLessThan24Hours) ? 24.0 : 0.0
        self.layoutIfNeeded()
    }
    
    func calculateHeight() -> CGFloat {
        streamNameLabel.sizeToFit()
        return streamNameLabel.frame.size.height
    }
}
