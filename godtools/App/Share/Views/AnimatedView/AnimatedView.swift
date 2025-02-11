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
    
    private let viewModel: AnimatedViewModel
    private let animationView: LottieAnimationView = LottieAnimationView()
                
    init(viewModel: AnimatedViewModel, frame: CGRect) {
                
        self.viewModel = viewModel
        
        super.init(frame: frame)
        
        setupLayout()
        setupBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        destroyAnimation()
    }
    
    private func setupLayout() {
        
        addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.constrainEdgesToView(view: self)
    }
    
    private func setupBinding() {
        
        animationView.animation = viewModel.animationData
        animationView.loopMode = viewModel.loop ? .loop : .playOnce
        
        if viewModel.autoPlay {
            animationView.play()
        }
        else {
            animationView.stop()
        }
    }
    
    func setAnimationContentMode(contentMode: UIView.ContentMode) {
        animationView.contentMode = contentMode
    }
    
    func destroyAnimation() {
        
        animationView.stop()
        animationView.animation = nil
    }
    
    var isPlaying: Bool {
        return animationView.isAnimationPlaying
    }
    
    func play(completion: ((_ completed: Bool) -> Void)? = nil) {
      
        if let completion = completion {
            animationView.play { (completed: Bool) in
                completion(completed)
            }
        }
        else {
            animationView.play()
        }
    }
    
    func pause() {
        
        animationView.pause()
    }
    
    func stop() {
        
        animationView.stop()
    }
}
