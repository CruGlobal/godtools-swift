//
//  AnimatedSwiftUIView.swift
//  godtools
//
//  Created by Levi Eggert on 6/10/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI
import Lottie

struct AnimatedSwiftUIView: View {
    
    private let viewModel: AnimatedViewModel
    private let contentMode: ContentMode
    
    init(viewModel: AnimatedViewModel, contentMode: ContentMode) {
        
        self.viewModel = viewModel
        self.contentMode = contentMode
    }
    
    var body: some View {
        
        RetainedAnimationLottieView(viewModel: viewModel, contentMode: contentMode)
            .id(viewModel.animationDataResource)
    }
}

private struct RetainedAnimationLottieView: View {
    
    private let viewModel: AnimatedViewModel
    private let contentMode: ContentMode
    
    @State private var animation: LottieAnimation?
    
    init(viewModel: AnimatedViewModel, contentMode: ContentMode) {
        
        self.viewModel = viewModel
        self.contentMode = contentMode
        _animation = State(initialValue: viewModel.animationData)
    }
    
    var body: some View {
        
        LottieView(animation: animation)
            .playbackMode(playbackMode)
            .resizable()
            .configure(\.contentMode, to: animationViewContentMode)
    }
    
    private var playbackMode: LottiePlaybackMode {
        
        guard viewModel.autoPlay else {
            return .paused(at: .frame(0))
        }
        
        let loopMode: LottieLoopMode = viewModel.loop ? .loop : .playOnce
        
        return .playing(.fromProgress(nil, toProgress: 1, loopMode: loopMode))
    }
    
    private var animationViewContentMode: UIView.ContentMode {
        
        switch contentMode {
        case .fit:
            return .scaleAspectFit
        case .fill:
            return .scaleAspectFill
        }
    }
}
