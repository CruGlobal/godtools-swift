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
    
    private let viewModel: AnimatedViewModel
    private let contentMode: UIView.ContentMode
    
    init(viewModel: AnimatedViewModel, contentMode: UIView.ContentMode) {
        
        self.viewModel = viewModel
        self.contentMode = contentMode
    }
    
    func makeUIView(context: Context) -> UIView {
                
        let view: UIView = UIView(frame: .zero)
        
        let animationView: LottieAnimationView = LottieAnimationView()
        
        animationView.animation = viewModel.animationData
        animationView.loopMode = viewModel.loop ? .loop : .playOnce
        animationView.contentMode = contentMode
                
        if viewModel.autoPlay {
            animationView.play()
        }
        else {
            animationView.stop()
        }
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
                
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}
