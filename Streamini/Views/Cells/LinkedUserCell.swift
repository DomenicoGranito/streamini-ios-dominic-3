//
//  LinkedUserCellTableViewCell.swift
//  Streamini
//
//  Created by Vasily Evreinov on 07/08/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

protocol LinkedUserCellDelegate:class {
    func willStatusChanged(cell: UITableViewCell)
}

class LinkedUserCell: UITableViewCell {
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userStatusButton: SensibleButton!
    weak var delegate: LinkedUserCellDelegate?

    var isStatusOn = false {
        didSet {
            let image: UIImage?
            if isStatusOn {
                image = UIImage(named: "checkmark")
            } else {
                image = UIImage(named: "plus")
            }
            userStatusButton.setImage(image!, forState: UIControlState.Normal)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func update(user: User) {
        usernameLabel.text = user.name
        userImageView.contentMode = UIViewContentMode.ScaleToFill
        userImageView.sd_setImageWithURL(user.avatarURL())
     
        userStatusButton.hidden = UserContainer.shared.logged().id == user.id
        isStatusOn = user.isFollowed
        userStatusButton.addTarget(self, action: #selector(LinkedUserCell.statusButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func updateRecent(recent: Stream, isMyStream: Bool = false) {
        userImageView.contentMode = UIViewContentMode.Center
        
        if isMyStream {
            self.textLabel!.text = recent.title
        } else {
            usernameLabel.text      = recent.title
            userImageView.image     = UIImage(named: "play")
            userImageView.tintColor = UIColor.navigationBarColor()
            userStatusButton.hidden = true
        }
    }
    
    func statusButtonPressed(sender: AnyObject) {
        if let del = delegate {
            del.willStatusChanged(self)
        }
    }
}
