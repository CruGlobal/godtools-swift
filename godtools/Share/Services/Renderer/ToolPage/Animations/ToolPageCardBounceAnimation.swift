//
//  ToolPageCardBounceAnimation.swift
//  godtools
//
//  Created by Levi Eggert on 11/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageCardBounceAnimation {
    
    private let animationOptions: UIView.AnimationOptions = [.curveEaseOut, .allowUserInteraction]
    private let bounceDuration: Double = 0.15
    private let largeBounceTransformation: CGFloat = -44
    private let maxNumberOfMiniBounces: Int = 3
    private let cardStartingTopConstant: CGFloat
    
    private var numberOfMiniBounces: Int = 0
    private var isRunning: Bool = false
    
    private weak var card: ToolPageCardView?
    private weak var cardTopConstraint: NSLayoutConstraint?
    private weak var layoutView: UIView?
    
    required init(card: ToolPageCardView, cardTopConstraint: NSLayoutConstraint, cardStartingTopConstant: CGFloat, layoutView: UIView) {
        
        self.card = card
        self.cardTopConstraint = cardTopConstraint
        self.cardStartingTopConstant = cardStartingTopConstant
        self.layoutView = layoutView
    }
    
    func startAnimation() {
        
        guard !isRunning else {
            return
        }
        
        isRunning = true
        
        playLargeBounceAnimation(delay: 0)
    }
    
    func stopAnimation(forceStop: Bool) {
        
        guard isRunning else {
            return
        }
        
        isRunning = false
        
        playToStartingPositionAnimation(forceStop: forceStop)
    }
    
    private func playLargeBounceAnimation(delay: Double) {
        
        numberOfMiniBounces = 0
        
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
        
        numberOfMiniBounces += 1
        
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
            
            if self.numberOfMiniBounces < self.maxNumberOfMiniBounces {
                self.playMiniBounceAnimation()
            }
            else {
                self.playLargeBounceAnimation(delay: 0.6)
            }
        }
    }
}
