//
//  Animator.swift
//  Streamini
//
//  Created by Vasily Evreinov on 14/07/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

protocol Animator {
    func like(view: UIView)
}

class HeartAnimator: Animator {
    
    func like(view: UIView) {
        
        let imageView = UIImageView(image: UIImage(named: "heart"))
        
        let hue = CGFloat((arc4random() % 100)) / 100.0
        imageView.tintColor = UIColor(hue: hue, saturation: 0.8, brightness: 0.8, alpha: 1.0)
        
        let xmin = UInt32((imageView.bounds.size.width)/2)
        let ymin = UInt32((imageView.bounds.size.height)/2)
        
        let x = xmin + arc4random() % UInt32(view.bounds.size.width - imageView.bounds.size.width)
        let y = ymin + arc4random() % UInt32(view.bounds.size.height - imageView.bounds.size.height)
        
        imageView.center = CGPointMake(CGFloat(x), CGFloat(y))
        view.addSubview(imageView)
        addHeartEffect(imageView)
    }
    
    private func addHeartEffect(image: UIImageView) {
        image.alpha = 0
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            image.alpha = 1.0
            }) { (finished) -> Void in
                UIView.animateWithDuration(3.0, delay: 2.0, options: UIViewAnimationOptions(), animations: { () -> Void in
                    image.alpha = 0.0
                    }, completion: { (finished) -> Void in
                        image.removeFromSuperview()
                })
        }
    }

}

class HeartBounceAnimator: Animator {
    func like(view: UIView) {
        let imageView = UIImageView(image: UIImage(named: "heart"))
        
        let hue = CGFloat((arc4random() % 100)) / 100.0
        imageView.tintColor = UIColor(hue: hue, saturation: 0.8, brightness: 0.8, alpha: 1.0)
        
        let xmin = CGFloat((imageView.bounds.size.width)/2)
        let ymin = CGFloat((imageView.bounds.size.height)/2)
        
        let x = xmin + CGFloat(arc4random() % UInt32(view.bounds.size.width - imageView.bounds.size.width))
        let y = -ymin
        
        imageView.center = CGPointMake(CGFloat(x), CGFloat(y))
        view.addSubview(imageView)
        addHeartEffect(imageView, view: view)
    }
    
    private func addHeartEffect(image: UIImageView, view: UIView) {
        let y0 = image.center.y
        let y1 = view.frame.height - image.frame.height/2
        let y2 = y1 - 5

        UIView.animateWithDuration(0.3, animations: { () -> Void in
            image.center = CGPointMake(image.center.x, y1) // fall
        }) { (finished) -> Void in
                UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                    image.center = CGPointMake(image.center.x, y2) // rise
                    }, completion: { (finished) -> Void in
                        UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                            image.center = CGPointMake(image.center.x, y1) // fall
                            }, completion: { (finished) -> Void in
                                UIView.animateWithDuration(0.7, delay: 0.0, options: UIViewAnimationOptions(), animations: { () -> Void in
                                    image.center = CGPointMake(image.center.x, y0) // rise and disappear
                                    image.alpha = 0.0
                                    }, completion: { (finished) -> Void in
                                        image.removeFromSuperview()
                                })
                        })
                })
        }
    }
}