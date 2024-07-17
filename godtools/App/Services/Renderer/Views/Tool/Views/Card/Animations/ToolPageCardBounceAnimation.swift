//
//  ToolPageCardBounceAnimation.swift
//  godtools
//
//  Created by Levi Eggert on 11/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol ToolPageCardBounceAnimationDelegate: AnyObject {
    
    func toolPageCardBounceAnimationDidFinish(cardBounceAnimation: ToolPageCardBounceAnimation, forceStopped: Bool)
}

class ToolPageCardBounceAnimation {
    
    private let animationOptions: UIView.AnimationOptions = [.curveEaseOut, .allowUserInteraction]
    private let bounceDuration: Double = 0.15
    private let largeBounceTransformation: CGFloat = -44
    private let maxNumberOfMiniBounces: Int = 3
    private let maxNumberOfLargeBouncesToPlay: Int = 3
    private let cardStartingTopConstant: CGFloat
    
    private var currentNumberOfMiniBounces: Int = 0
    private var currentNumberOfLargeBounces: Int = 0
    private var isRunning: Bool = false
    
    private weak var card: ToolPageCardView?
    private weak var cardTopConstraint: NSLayoutConstraint?
    private weak var layoutView: UIView?
    private weak var delegate: ToolPageCardBounceAnimationDelegate?
    
    init(card: ToolPageCardView, cardTopConstraint: NSLayoutConstraint, cardStartingTopConstant: CGFloat, layoutView: UIView, delegate: ToolPageCardBounceAnimationDelegate) {
        
        self.card = card
        self.cardTopConstraint = cardTopConstraint
        self.cardStartingTopConstant = cardStartingTopConstant
        self.layoutView = layoutView
        self.delegate = delegate
    }
    
    func startAnimation() {
        
        guard !isRunning else {
            return
        }
        
        isRunning = true
        
        playLargeBounceAnimation(delay: 1.5)
    }
    
    func stopAnimation(forceStop: Bool) {
        
        guard isRunning else {
            return
        }
        
        isRunning = false
        
        playToStartingPositionAnimation(forceStop: forceStop)
        
        delegate?.toolPageCardBounceAnimationDidFinish(cardBounceAnimation: self, forceStopped: forceStop)
    }
    
    private func playLargeBounceAnimation(delay: Double) {
        
        guard currentNumberOfLargeBounces < maxNumberOfLargeBouncesToPlay else {
            stopAnimation(forceStop: false)
            return
        }
        
        currentNumberOfMiniBounces = 0
        
        currentNumberOfLargeBounces += 1
        
        cardTopConstraint?.constant = cardStartingTopConstant + largeBounceTransformation
        
        UIView.animate(withDuration: bounceDuration, delay: delay, options: animationOptions, animations: {
            
            self.layoutView?.layoutIfNeeded()
            
        }) { (finished: Bool) in
            
            guard self.isRunning else {
                return
            }
            
            self.playToStartingPositionAnimation(forceStop: false)
        }
    }
    
    private func playMiniBounceAnimation() {
        
        currentNumberOfMiniBounces += 1
        
        cardTopConstraint?.constant = cardStartingTopConstant + largeBounceTransformation * 0.2
        
        UIView.animate(withDuration: bounceDuration, delay: 0.1, options: animationOptions, animations: {
            
            self.layoutView?.layoutIfNeeded()
            
        }) { (finished: Bool) in
            
            guard self.isRunning else {
                return
            }
            
            self.playToStartingPositionAnimation(forceStop: false)
        }
    }
    
    private func playToStartingPositionAnimation(forceStop: Bool) {
        
        cardTopConstraint?.constant = cardStartingTopConstant
        
        guard !forceStop else {
            card?.layer.removeAllAnimations()
            layoutView?.layoutIfNeeded()
            return
        }
        
        UIView.animate(withDuration: bounceDuration, delay: 0.1, options: animationOptions, animations: {
            
            self.layoutView?.layoutIfNeeded()
        
        }) { (finished: Bool) in
            
            guard self.isRunning else {
                return
            }
            
            if self.currentNumberOfMiniBounces < self.maxNumberOfMiniBounces {
                self.playMiniBounceAnimation()
            }
            else {
                self.playLargeBounceAnimation(delay: 0.6)
            }
        }
    }
}
