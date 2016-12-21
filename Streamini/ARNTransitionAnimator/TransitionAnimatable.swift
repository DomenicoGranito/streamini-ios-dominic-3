//
//  TransitionAnimatable.swift
//  ARNTransitionAnimator
//
//  Created by xxxAIRINxxx on 2016/07/25.
//  Copyright © 2016 xxxAIRINxxx. All rights reserved.
//

import Foundation
import UIKit

public protocol TransitionAnimatable : class {
    
    func sourceVC() -> UIViewController
    func destVC() -> UIViewController
    
    func prepareContainer(transitionType: TransitionType, containerView: UIView, from fromVC: UIViewController, to toVC: UIViewController)
    func willAnimation(transitionType: TransitionType, containerView: UIView)
    func updateAnimation(transitionType: TransitionType, percentComplete: CGFloat)
    func finishAnimation(transitionType: TransitionType, didComplete: Bool)
}

extension TransitionAnimatable {
    
    public func prepareContainer(transitionType: TransitionType, containerView: UIView, from fromVC: UIViewController, to toVC: UIViewController) {
        if transitionType.isPresenting {
            containerView.addSubview(fromVC.view)
            containerView.addSubview(toVC.view)
        } else {
            containerView.addSubview(toVC.view)
            containerView.addSubview(fromVC.view)
        }
        fromVC.view.setNeedsLayout()
        fromVC.view.layoutIfNeeded()
        toVC.view.setNeedsLayout()
        toVC.view.layoutIfNeeded()
    }
}

