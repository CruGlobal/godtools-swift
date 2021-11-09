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
    
    private let animationView: AnimationView = AnimationView()
    
    private var viewModel: AnimatedViewModelType?
        
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        setupLayout()
    }
    
    required init(frame: CGRect, viewModel: AnimatedViewModelType) {
                
        self.viewModel = viewModel
        
        super.init(frame: frame)
        
        setupLayout()
        configure(viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        
        setupLayout()
    }
    
    deinit {
        destroyAnimation()
    }
    
    private func setupLayout() {
        
        addSubview(animationView)
        animationView.constrainEdgesToSuperview()
    }
    
    func configure(viewModel: AnimatedViewModelType) {
        
        self.viewModel = viewModel
        
        destroyAnimation()
        
        animationView.animation = viewModel.animationData
        animationView.loopMode = viewModel.loop ? .loop : .playOnce
        
        if viewModel.autoPlay {
            animationView.play()
        }
        else {
            animationView.stop()
        }
    }
    
    func destroyAnimation() {
        
        animationView.stop()
        animationView.animation = nil
    }
    
    func play() {
        animationView.play()
    }
    
    func stop() {
        animationView.stop()
    }
}
