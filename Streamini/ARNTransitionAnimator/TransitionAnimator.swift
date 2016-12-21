//
//  TransitionAnimator.swift
//  ARNTransitionAnimator
//
//  Created by xxxAIRINxxx on 2016/07/25.
//  Copyright © 2016 xxxAIRINxxx. All rights reserved.
//

import Foundation
import UIKit

final class TransitionAnimator {
    
    let transitionType: TransitionType
    let animation: TransitionAnimatable
    
    init(transitionType: TransitionType, animation: TransitionAnimatable) {
        self.transitionType = transitionType
        self.animation = animation
    }
    
    func willAnimation(containerView: UIView) {
        self.animation.prepareContainer(self.transitionType, containerView: containerView, from: self.fromVC, to: self.toVC)
        self.animation.willAnimation(self.transitionType, containerView: containerView)
    }
    
    func animate(duration: NSTimeInterval, animations: ((Void) -> Void), completion: ((Bool) -> Void)? = nil) {
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        UIView.animateWithDuration(duration,
                       delay: 0.0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0,
                       options: .CurveEaseOut,
                       animations: animations) { finished in
                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                        completion?(finished)
        }
    }
    
    func updateAnimation(percentComplete: CGFloat) {
        self.animation.updateAnimation(self.transitionType, percentComplete: percentComplete)
    }
    
    func finishAnimation(didComplete: Bool) {
        if didComplete {
            if !self.transitionType.isPresenting {
                self.fromVC.view.removeFromSuperview()
            }
        } else {
            if self.transitionType.isPresenting {
                self.toVC.view.removeFromSuperview()
            }
        }
        self.animation.finishAnimation(self.transitionType, didComplete: didComplete)
    }
}

extension TransitionAnimator {
    
    var fromVC: UIViewController {
        return self.transitionType.isPresenting ? self.animation.sourceVC() : self.animation.destVC()
    }
    
    var toVC: UIViewController {
        return self.transitionType.isPresenting ? self.animation.destVC() : self.animation.sourceVC()
    }
}
