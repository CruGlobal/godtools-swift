//
//  AnimatedView.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import Lottie

class AnimatedView: UIView {
    
    private var animationView: AnimationView?
        
    override init(frame: CGRect) {
        
        super.init(frame: frame)
    }
    
    required init(frame: CGRect, resource: AnimatedResource, shouldAutoPlay: Bool, shouldLoop: Bool) {
                
        super.init(frame: frame)
        
        setAnimation(resource: resource, shouldAutoPlay: shouldAutoPlay, shouldLoop: shouldLoop)
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
    }
    
    func setAnimation(resource: AnimatedResource, shouldAutoPlay: Bool, shouldLoop: Bool) {
        
        if let currentAnimationView = self.animationView {
            
            currentAnimationView.stop()
            currentAnimationView.removeFromSuperview()
            animationView = nil
            
            let viewConstraints: [NSLayoutConstraint] = constraints
            removeConstraints(viewConstraints)
        }
        
        let newAnimationView = AnimationView()
        let loopMode: LottieLoopMode = shouldLoop ? .loop : .playOnce
        
        let animationResource: Animation?
        
        switch resource {
        case .filepathJsonFile(let filepath):
            animationResource = Animation.filepath(filepath, animationCache: nil)
        case .mainBundleJsonFile(let filename):
            animationResource = Animation.named(filename)
        }
                        
        newAnimationView.animation = animationResource
        newAnimationView.loopMode = loopMode
        
        addSubview(newAnimationView)
        newAnimationView.constrainEdgesToSuperview()
        
        if shouldAutoPlay {
            newAnimationView.play()
        }
        else {
            newAnimationView.stop()
        }
        
        self.animationView = newAnimationView
    }
}
