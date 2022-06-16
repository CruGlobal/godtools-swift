//
//  AnimatedSwiftUIView.swift
//  godtools
//
//  Created by Levi Eggert on 6/10/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import Lottie
import SwiftUI

struct AnimatedSwiftUIView: UIViewRepresentable {
    
    private let viewModel: AnimatedViewModelType
    private let frameSize: CGSize
    private let contentMode: UIView.ContentMode
    
    init(viewModel: AnimatedViewModelType, frameSize: CGSize, contentMode: UIView.ContentMode) {
        
        self.viewModel = viewModel
        self.frameSize = frameSize
        self.contentMode = contentMode
    }
    
    func makeUIView(context: Context) -> AnimationView {
                
        let animationView: AnimationView = AnimationView()
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        _ = animationView.addWidthConstraint(constant: frameSize.width)
        _ = animationView.addHeightConstraint(constant: frameSize.height)
        
        animationView.animation = viewModel.animationData
        animationView.loopMode = viewModel.loop ? .loop : .playOnce
        animationView.contentMode = contentMode
                
        if viewModel.autoPlay {
            animationView.play()
        }
        else {
            animationView.stop()
        }
        
        return animationView
    }
    
    func updateUIView(_ uiView: AnimationView, context: Context) {
        
    }
}
