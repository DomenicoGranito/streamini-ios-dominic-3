//
//  UserSelectingHandler.swift
//  Streamini
//
//  Created by Vasily Evreinov on 07/08/15.
//  Copyright (c) 2015 Evghenii Todorov. All rights reserved.
//

import UIKit

class UserSelectingHandler: NSObject {
    var imageView: UIImageView
    var user: User?
    weak var delegate: UserSelecting?
    
    init(imageView: UIImageView, delegate: UserSelecting, user: User) {
        self.imageView = imageView
        self.delegate  = delegate
        self.user      = user
        super.init()
        addTapRecognizer()
    }
    
    private func addTapRecognizer() {
        if let recognizers = imageView.gestureRecognizers as [UIGestureRecognizer]! {
            for recognizer in recognizers {
                imageView.removeGestureRecognizer(recognizer)
            }
        }
        
        imageView.userInteractionEnabled = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(UserSelectingHandler.userImageViewTapped(_:)))
        imageView.addGestureRecognizer(tapRecognizer)
    }
    
    func userImageViewTapped(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            if let del = delegate, selectedUser = user {
                del.userDidSelected(selectedUser)
            }
        }
    }
}
