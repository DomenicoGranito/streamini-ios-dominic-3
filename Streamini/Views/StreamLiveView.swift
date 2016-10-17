//
//  StreamLiveView.swift
//  Streamini
//
//  Created by Vasily Evreinov on 23/06/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

class StreamLiveView: UIView {
    let label = UILabel()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setupView() {
        self.layer.cornerRadius = 6.0
        self.backgroundColor = UIColor(red: 172.0/255.0, green: 64.0/255.0, blue: 64.0/255.0, alpha: 1.0)
        label.textColor = UIColor.whiteColor()
        label.font = UIFont(name: "HelveticaNeue", size: 14.0)
        self.addSubview(label)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.sizeToFit()
        let currentFrame = self.frame
        self.frame = CGRectMake(currentFrame.origin.x, currentFrame.origin.y, label.frame.size.width + 20, currentFrame.size.height)
        
        label.frame = CGRectMake(10, 0, self.bounds.width-20, self.bounds.height)
    }
    
    func setCount(count: UInt) {
        let liveText = NSLocalizedString("stream_live_count", comment: "")
        label.text = "\(liveText) | \(count)"
        self.layoutIfNeeded()
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
