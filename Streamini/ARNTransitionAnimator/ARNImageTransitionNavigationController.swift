//
//  ARNImageTransitionNavigationController.swift
//  ARNZoomImageTransition
//
//  Created by xxxAIRINxxx on 2015/08/08.
//  Copyright (c) 2015 xxxAIRINxxx. All rights reserved.
//

import UIKit
//import ARNVTransitionAnimator

class ARNImageTransitionNavigationController: UINavigationController, UINavigationControllerDelegate {
    
    
    //let interactiveAnimator : ARNVTransitionAnimator
    weak var interactiveAnimator : ARNVTransitionAnimator?
    var currentOperation : UINavigationControllerOperation = .None
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.interactivePopGestureRecognizer?.enabled = false
        self.delegate = self
    }
    
    func navigationController(navigationController: UINavigationController,
        animationControllerForOperation operation: UINavigationControllerOperation,
        fromViewController fromVC: UIViewController,
        toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        self.currentOperation = operation
        
        if let interactiveAnimator = self.interactiveAnimator {
            return interactiveAnimator
        }
        
        if operation == .Push {
            return ARNImageZoomTransition.createAnimator(.Push, fromVC: fromVC, toVC: toVC)
        } else if operation == .Pop {
            return ARNImageZoomTransition.createAnimator(.Pop, fromVC: fromVC, toVC: toVC)
        }
        
        return nil
    }
    
    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if let interactiveAnimator = self.interactiveAnimator {
            if  self.currentOperation == .Pop {
                return interactiveAnimator
            }
        }
        return nil
    }
}
