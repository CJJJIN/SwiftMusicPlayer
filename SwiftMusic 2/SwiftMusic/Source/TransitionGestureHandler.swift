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
    public var panBoundsPoint: CGPoint?
    
    fileprivate(set) var isTransitioning: Bool = false
    fileprivate(set) var percentComplete: CGFloat = 0.0
    
    fileprivate weak var targetVC: UIViewController!
    
    fileprivate var panLocationStart: CGFloat = 0.0
    fileprivate var gesture: UIPanGestureRecognizer?
    
    deinit {
        self.unregisterGesture()
    }
    
    public init(targetVC: UIViewController, direction: DirectionType) {
        self.targetVC = targetVC
        self.direction = direction
        
        super.init()
    }
    
    public func registerGesture(_ view: UIView) {
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
    
    @objc fileprivate func handleGesture(_ recognizer: UIPanGestureRecognizer) {
        let window = self.targetVC.view.window
        
        var location = recognizer.location(in: window)
        location = location.applying(recognizer.view!.transform.inverted())
        var velocity = recognizer .velocity(in: window)
        velocity = velocity.applying(recognizer.view!.transform.inverted())
        
        self.updatePercentComplete(location)
        
        switch recognizer.state {
        case .began:
            self.setPanStartPoint(location)
        case .changed:
            self.startTransitionIfNeeded(location)
            
            if self.isTransitioning {
                self.updateGestureHandler?(.update(percentComplete: self.percentComplete))
            }
        case .ended:
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
    
    fileprivate func setPanStartPoint(_ location: CGPoint) {
        switch self.direction {
        case .top, .bottom:
            self.panLocationStart = location.y
        case .left, .right:
            self.panLocationStart = location.x
        }
    }
    
    fileprivate func updatePercentComplete(_ location: CGPoint) {
        var bounds = CGFloat(0)
        if let boundsPoint = panBoundsPoint {
            switch self.direction {
            case .top, .bottom:
                bounds = abs(boundsPoint.y - panLocationStart)
            case .left, .right:
                bounds = abs(boundsPoint.x - panLocationStart)
            }
        } else {
            switch self.direction {
            case .top, .bottom:
                bounds = self.targetVC.view.bounds.height
            case .left, .right:
                bounds = self.targetVC.view.bounds.width
            }
        }
        switch self.direction {
        case .top:
            self.percentComplete = min((self.panLocationStart - location.y) / bounds, 1)
        case .bottom:
            self.percentComplete = min((location.y - self.panLocationStart) / bounds, 1)
        case .left:
            self.percentComplete = min((self.panLocationStart - location.x) / bounds, 1)
        case .right:
            self.percentComplete = min((location.x - self.panLocationStart) / bounds, 1)
        }
    }
    
    fileprivate func startTransitionIfNeeded(_ location: CGPoint) {
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
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let g = self.gesture else { return false }
        guard g.view is UIScrollView else { return false }
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy
        otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
