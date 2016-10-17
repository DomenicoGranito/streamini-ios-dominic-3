//
//  StreamCellTableViewCell.swift
//  Streamini
//
//  Created by Vasily Evreinov on 23/06/15.
//  Copyright (c) 2015 Evghenii Todorov. All rights reserved.
//

import UIKit

class StreamCell: UITableViewCell {
    var stream: Stream?
    weak var userSelectedDelegate: UserSelecting?    
    
    func update(stream: Stream) {
        self.stream = stream
    }
}

class LiveStreamCell: StreamCell {
    @IBOutlet weak var streamImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var streamNameLabel: UILabel!
    @IBOutlet weak var streamLiveView: StreamLiveView!
    @IBOutlet weak var streamNameLabelHeight: NSLayoutConstraint!
    
    var userSelectingHandler: UserSelectingHandler?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    override func update(stream: Stream) {
        super.update(stream)
        
        self.backgroundColor = UIColor.blackColor()
        userLabel.text = stream.user.name        
        streamNameLabel.text = stream.title
        
        let expectedSize = streamNameLabel.sizeThatFits(CGSizeMake(streamNameLabel.bounds.size.width, 10000))
        streamNameLabelHeight.constant = expectedSize.height > 75.0 ? 75.0 : expectedSize.height
        
        self.streamLiveView.setCount(stream.viewers)
        
        userImageView.sd_setImageWithURL(stream.user.avatarURL())        
        streamImageView.sd_setImageWithURL(stream.urlToStreamImage())

        if let delegate = userSelectedDelegate {
            self.userSelectingHandler = UserSelectingHandler(imageView: userImageView, delegate: delegate, user: stream.user)
        }
    }
}
