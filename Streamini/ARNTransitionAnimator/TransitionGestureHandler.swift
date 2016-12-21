//
//  TransitionGestureHandler.swift
//  ARNTransitionAnimator
//
//  Created by xxxAIRINxxx on 2016/08/25.
//  Copyright © 2016 xxxAIRINxxx. All rights reserved.
//

import Foundation
import UIKit
import UIKit.UIGestureRecognizerSubclass

public enum DirectionType {
    case top
    case bottom
    case left
    case right
}

public enum TransitionState {
    case start
    case update(percentComplete: CGFloat)
    case finish
    case cancel
}

public final class TransitionGestureHandler : NSObject {
    
    public let direction: DirectionType
    
    public var updateGestureHandler: ((TransitionState) -> Void)?
    
    public var panStartThreshold: CGFloat = 10.0
    public var panCompletionThreshold: CGFloat = 30.0
    
    private(set) var isTransitioning: Bool = false
    private(set) var percentComplete: CGFloat = 0.0
    
    private weak var targetVC: UIViewController!
    
    private var panLocationStart: CGFloat = 0.0
    private var gesture: UIPanGestureRecognizer?
    
    deinit {
        self.unregisterGesture()
    }
    
    public init(targetVC: UIViewController, direction: DirectionType) {
        self.targetVC = targetVC
        self.direction = direction
        
        super.init()
    }
    
    public func registerGesture(view: UIView) {
        self.unregisterGesture()
        
        self.gesture = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        self.gesture?.maximumNumberOfTouches = 1
        self.gesture?.delegate = self
        view.addGestureRecognizer(self.gesture!)
    }
    
    public func unregisterGesture() {
        guard let g = self.gesture else { return }
        g.view?.removeGestureRecognizer(g)
        self.gesture = nil
    }
    
    @objc private func handleGesture(recognizer: UIPanGestureRecognizer) {
        let window = self.targetVC.view.window
        
        var location = recognizer.locationInView(window)
        location=CGPointApplyAffineTransform(location, CGAffineTransformInvert(recognizer.view!.transform))
        var velocity = recognizer.locationInView(window)
        velocity=CGPointApplyAffineTransform(velocity, CGAffineTransformInvert(recognizer.view!.transform))
        
        self.updatePercentComplete(location)
        
        switch recognizer.state {
        case .Began:
            self.setPanStartPoint(location)
        case .Changed:
            self.startTransitionIfNeeded(location)
            
            if self.isTransitioning {
                self.updateGestureHandler?(.update(percentComplete: self.percentComplete))
            }
        case .Ended:
            var velocityForSelectedDirection: CGFloat = 0.0
            switch self.direction {
            case .top, .bottom:
                velocityForSelectedDirection = abs(velocity.y)
            case .left, .right:
                velocityForSelectedDirection = abs(velocity.x)
            }
            
            if velocityForSelectedDirection > 0.0 && (self.percentComplete * 100) > self.panCompletionThreshold {
                self.updateGestureHandler?(.finish)
                self.percentComplete = 1.0
            } else {
                self.updateGestureHandler?(.cancel)
                self.percentComplete = 0.0
            }
            self.isTransitioning = false
        default:
            self.updateGestureHandler?(.cancel)
            self.isTransitioning = false
            self.percentComplete = 0.0
        }
    }
    
    private func setPanStartPoint(location: CGPoint) {
        switch self.direction {
        case .top, .bottom:
            self.panLocationStart = location.y
        case .left, .right:
            self.panLocationStart = location.x
        }
    }
    
    private func updatePercentComplete(location: CGPoint) {
        let bounds = self.targetVC.view.bounds
        switch self.direction {
        case .top:
            self.percentComplete = (self.panLocationStart - location.y) / bounds.height
        case .bottom:
            self.percentComplete = (location.y - self.panLocationStart) / bounds.height
        case .left:
            self.percentComplete = (self.panLocationStart - location.x) / bounds.width
        case .right:
            self.percentComplete = (location.x - self.panLocationStart) / bounds.width
        }
    }
    
    private func startTransitionIfNeeded(location: CGPoint) {
        if self.isTransitioning { return }
        
        switch self.direction {
        case .top:
            if (self.panLocationStart - location.y) < self.panStartThreshold { return }
        case .bottom:
            if (location.y - self.panLocationStart) < self.panStartThreshold { return }
        case .left:
            if (self.panLocationStart - location.x) < self.panStartThreshold { return }
        case .right:
            if (location.x - self.panLocationStart) < self.panStartThreshold { return }
        }
        self.isTransitioning = true
        self.updateGestureHandler?(.start)
        self.setPanStartPoint(location)
        self.updatePercentComplete(location)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension TransitionGestureHandler : UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let g = self.gesture else { return false }
        guard g.view is UIScrollView else { return false }
        return true
    }
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy
        otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
