//
//  InteractiveAnimator.swift
//  ARNTransitionAnimator
//
//  Created by xxxAIRINxxx on 2016/07/26.
//  Copyright © 2016 xxxAIRINxxx. All rights reserved.
//

import Foundation
import UIKit

final class InteractiveTransitioning : UIPercentDrivenInteractiveTransition {
    
    let animator: TransitionAnimator
    let gestureHandler: TransitionGestureHandler
    let transitionDuration: CGFloat
    
    private var transitionContext: UIViewControllerContextTransitioning?
    
    init(duration: CGFloat, animator: TransitionAnimator, _ gestureHandler: TransitionGestureHandler) {
        self.transitionDuration = duration
        self.animator = animator
        self.gestureHandler = gestureHandler
        
        super.init()
        
        self.handleGesture()
    }
    
    private func handleGesture() {
        self.gestureHandler.updateGestureHandler = { [weak self] state in
            switch state {
            case .start:
                self?.startTransition()
            case .update(let percentComplete):
                self?.updateInteractiveTransition(percentComplete)
            case .finish:
                self?.finishInteractiveTransition()
            case .cancel:
                self?.cancelInteractiveTransition()
            }
        }
    }
    
    private func completeTransition(didComplete: Bool) {
        self.transitionContext?.completeTransition(didComplete)
        self.transitionContext = nil
    }
    
    private func startTransition() {
        switch self.animator.transitionType {
        case .push:
            self.animator.fromVC.navigationController?.pushViewController(self.animator.toVC, animated: true)
        case .present:
            self.animator.fromVC.presentViewController(self.animator.toVC, animated:true, completion:nil)
        case .pop:
            _ = self.animator.fromVC.navigationController?.popViewControllerAnimated(true)
        case .dismiss:
            self.animator.fromVC.dismissViewControllerAnimated(true, completion:nil)
        }
    }
}

extension InteractiveTransitioning {
    
    override func startInteractiveTransition(transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        self.animator.willAnimation(transitionContext.containerView())
    }
    
    override func updateInteractiveTransition(percentComplete: CGFloat) {
        super.updateInteractiveTransition(percentComplete)
        
        self.animator.updateAnimation(percentComplete)
    }
    
    override func finishInteractiveTransition() {
        super.finishInteractiveTransition()
        
        let d = self.transitionDuration - (self.transitionDuration * self.percentComplete)
        
        self.animator.animate(NSTimeInterval(d), animations: { [weak self] in self?.animator.updateAnimation(1.0) }) { [weak self] finished in
            self?.animator.finishAnimation(true)
            self?.completeTransition(true)
        }
    }
    
    override func cancelInteractiveTransition() {
        super.cancelInteractiveTransition()
        
        let d = self.transitionDuration * (1.0 - self.percentComplete)
        
        self.animator.animate(NSTimeInterval(d), animations: { [weak self] in self?.animator.updateAnimation(0.0) }) { [weak self] finished in
            self?.animator.finishAnimation(false)
            self?.completeTransition(false)
        }
    }
}
