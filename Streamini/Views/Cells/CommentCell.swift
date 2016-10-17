//
//  CommentCellTableViewCell.swift
//  Streamini
//
//  Created by Vasily Evreinov on 16/07/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var commentLabel: CommentLabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var usernameLabelWidthConstraint: NSLayoutConstraint!
    weak var userSelectedDelegate: UserSelecting?
    var userSelectingHandler: UserSelectingHandler?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func update(message: Message, width: CGFloat) {
        if let delegate = userSelectedDelegate {
            self.userSelectingHandler = UserSelectingHandler(imageView: userImageView, delegate: delegate, user: message.sender)
        }
        
        usernameLabel.text = message.sender.name
        
        userImageView.sd_setImageWithURL(message.sender.avatarURL())
        
        commentLabel.text = message.text
        usernameLabelWidthConstraint.constant = width
        self.layoutIfNeeded()
    }
    
    func setAlphaValue(alpha: CGFloat) {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.contentView.alpha = alpha
        })
    }
}
