//
//  UserHeaderView.swift
// Streamini
//
//  Created by Vasily Evreinov on 06/08/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

protocol UserHeaderViewDelegate: class {
    func usernameLabelPressed()
    func descriptionWillStartEdit()
}

class UserHeaderView: UIView, UITextViewDelegate {
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var likeIcon: UIImageView!
    @IBOutlet var likeCountLabel: UILabel!
    @IBOutlet var liveLabel: UILabel!
    @IBOutlet var userDescriptionLabel: UILabel!
    @IBOutlet var userDescriptionTextView: UITextView!
    
    weak var delegate: UserHeaderViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
      //  likeIcon.tintColor = UIColor.navigationBarColor()
        
        // Set placeholder for NameTextView
        if userDescriptionTextView != nil {
            userDescriptionTextView.tintColor = UIColor.navigationBarColor()
            let placeholderText = NSLocalizedString("profile_description_placeholder", comment: "")
            applyPlaceholderStyle(userDescriptionTextView, placeholderText: placeholderText)
            userDescriptionTextView.alpha = 0.0
        }
    }
    
    func applyPlaceholderStyle(aTextview: UITextView, placeholderText: String)
    {
        // make it look (initially) like a placeholder
        aTextview.textColor = UIColor(white: 0.5, alpha: 1.0)
        aTextview.text = placeholderText
    }
    
    func applyNonPlaceholderStyle(aTextview: UITextView)
    {
        // make it look like normal text instead of a placeholder
        aTextview.textColor = UIColor.darkTextColor()
        aTextview.alpha = 1.0
    }
    
    func update(user: User) {
        userImageView.sd_setImageWithURL(user.avatarURL())
        
        usernameLabel.text  = user.name
        likeCountLabel.text = "\(user.likes)"
        
//        if let label = userDescriptionLabel {
//            userDescriptionLabel.text   = user.desc
//        } else {
//            userDescriptionTextView.alpha = 1.0
//            if let text = user.desc {
//                if !text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).isEmpty {
//                    applyNonPlaceholderStyle(userDescriptionTextView)
//                    userDescriptionTextView.text = user.desc
//                }
//            }
//        }
        
        if let live = liveLabel {
            live.hidden = !user.isLive
        }
    }
    
    func updateAvatar(user: User, placeholder: UIImage) {
        // Change image in UIImageView
        UIView.animateWithDuration(0.15, animations: { () -> Void in
            self.userImageView.alpha = 0.0
            }, completion: { (finished) -> Void in
                self.userImageView.image = placeholder
                UIView.animateWithDuration(0.15, animations: { () -> Void in
                    self.userImageView.alpha = 1.0
                })
        })
        
        // Clear cache
        SDImageCache.sharedImageCache().removeImageForKey(user.avatarURL().absoluteString, fromDisk: true)
        
        // Download and put in cache new image
        user.avatar = nil
        SDWebImagePrefetcher.sharedImagePrefetcher().prefetchURLs([user.avatarURL()])
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        if let del = delegate {
            del.descriptionWillStartEdit()
        }
        
        if textView.textColor == UIColor(white: 0.5, alpha: 1.0)
        {
            // move cursor to start
            moveCursorToStart(textView)
        }
        
        return true
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        var updatedText = (textView.text as NSString).stringByReplacingCharactersInRange(range, withString: text)
        updatedText = updatedText.handleEmoji()
        
        if updatedText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).isEmpty {
            let placeholderText = NSLocalizedString("profile_description_placeholder", comment: "")
            applyPlaceholderStyle(textView, placeholderText: placeholderText)
            moveCursorToStart(textView)
            return false
        }
        
        // Remove placeholder text if it is shown
        if userDescriptionTextView.textColor == UIColor(white: 0.5, alpha: 1.0) && !text.isEmpty {
            textView.text = ""
            applyNonPlaceholderStyle(textView)
            return true
        }
        
        return true
    }
    
    func moveCursorToStart(textView: UITextView)
    {
        dispatch_async(dispatch_get_main_queue(), {
            textView.selectedRange = NSMakeRange(0, 0);
        })
    }
}
