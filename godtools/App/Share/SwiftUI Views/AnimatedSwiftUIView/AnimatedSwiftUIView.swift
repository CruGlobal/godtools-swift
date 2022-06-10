//
//  AnimatedSwiftUIView.swift
//  godtools
//
//  Created by Levi Eggert on 6/10/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Lottie
import SwiftUI

struct AnimatedSwiftUIView: UIViewRepresentable {
    
    private let viewModel: AnimatedViewModelType
    
    init(viewModel: AnimatedViewModelType) {
        
        self.viewModel = viewModel
    }
    
    func makeUIView(context: Context) -> some UIView {
        
        let animationView: AnimationView = AnimationView()
        
        animationView.animation = viewModel.animationData
        animationView.loopMode = viewModel.loop ? .loop : .playOnce
        
        if viewModel.autoPlay {
            animationView.play()
        }
        else {
            animationView.stop()
        }
        
        return animationView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}
