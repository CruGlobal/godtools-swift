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
    
    private var viewModel: AnimatedViewModelType?
    private var animationView: AnimationView?
        
    override init(frame: CGRect) {
        
        super.init(frame: frame)
    }
    
    required init(frame: CGRect, viewModel: AnimatedViewModelType) {
                
        self.viewModel = viewModel
        
        super.init(frame: frame)
        
        configure(viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
    }
    
    func configure(viewModel: AnimatedViewModelType) {
        
        self.viewModel = viewModel
        
        if let currentAnimationView = self.animationView {
            
            currentAnimationView.stop()
            currentAnimationView.removeFromSuperview()
            animationView = nil
            
            let viewConstraints: [NSLayoutConstraint] = constraints
            removeConstraints(viewConstraints)
        }
        
        let newAnimationView = AnimationView()
        let loopMode: LottieLoopMode = viewModel.loop ? .loop : .playOnce
                        
        newAnimationView.animation = viewModel.animationData
        newAnimationView.loopMode = loopMode
        
        addSubview(newAnimationView)
        newAnimationView.constrainEdgesToSuperview()
        
        if viewModel.autoPlay {
            newAnimationView.play()
        }
        else {
            newAnimationView.stop()
        }
        
        self.animationView = newAnimationView
    }
}
