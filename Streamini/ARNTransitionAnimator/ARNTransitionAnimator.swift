//
//  TransitionAnimator.swift
//  ARNTransitionAnimator
//
//  Created by xxxAIRINxxx on 2016/07/02.
//  Copyright © 2016 xxxAIRINxxx. All rights reserved.
//

import Foundation
import UIKit

public enum TransitionType {
    case push
    case pop
    case present
    case dismiss
    
    public var isPresenting: Bool {
        return self == .push || self == .present
    }
    
    public var isDismissing: Bool {
        return self == .pop || self == .dismiss
    }
}

public final class ARNTransitionAnimator : NSObject {
    
    public let duration: NSTimeInterval
    public let animation: TransitionAnimatable
    
    private var interactiveTransitioning: InteractiveTransitioning?
    
    public init(duration: NSTimeInterval, animation: TransitionAnimatable) {
        self.duration = duration
        self.animation = animation
        
        super.init()
    }
    
    public func registerInteractiveTransitioning(transitionType: TransitionType, gestureHandler: TransitionGestureHandler) {
        let d = CGFloat(self.duration)
        let animator = TransitionAnimator(transitionType: transitionType, animation: animation)
        self.interactiveTransitioning = InteractiveTransitioning(duration: d, animator: animator, gestureHandler)
    }
    
    public func unregisgterInteractiveTransitioning() {
        self.interactiveTransitioning = nil
    }
}

extension ARNTransitionAnimator : UIViewControllerTransitioningDelegate {
    
    public func animationControllerForPresentedController(presented:UIViewController, presentingController presenting:UIViewController, sourceController source:UIViewController)->UIViewControllerAnimatedTransitioning?
    {
        let animator = TransitionAnimator(transitionType: .present, animation: self.animation)
        return AnimatedTransitioning(animator: animator, duration: self.duration)
    }
    
    public func animationControllerForDismissedController(dismissed:UIViewController)->UIViewControllerAnimatedTransitioning?
    {
        let animator = TransitionAnimator(transitionType: .dismiss, animation: self.animation)
        return AnimatedTransitioning(animator: animator, duration: self.duration)
    }
    
    public func interactionControllerForPresentation(animator:UIViewControllerAnimatedTransitioning)->UIViewControllerInteractiveTransitioning?
    {
        guard let i = self.interactiveTransitioning  where i.animator.transitionType.isPresenting else { return nil }
        if !i.gestureHandler.isTransitioning { return nil }
        return i
    }
    
    public func interactionControllerForDismissal(animator:UIViewControllerAnimatedTransitioning)->UIViewControllerInteractiveTransitioning?
    {
        guard let i = self.interactiveTransitioning  where !i.animator.transitionType.isPresenting else { return nil }
        if !i.gestureHandler.isTransitioning { return nil }
        return i
    }
}
