//
//  FullScreenVideoView.swift
//  godtools
//
//  Created by Levi Eggert on 1/31/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct FullScreenVideoView: View {
    
    private let screenAccessibility: AccessibilityStrings.Screen
    
    @State private var videoPlayerState: VideoViewPlayerState = .stopped
    
    @ObservedObject private var viewModel: FullScreenVideoViewModel
    
    let backgroundColor: Color
    
    init(viewModel: FullScreenVideoViewModel, backgroundColor: Color, screenAccessibility: AccessibilityStrings.Screen) {
        
        self.viewModel = viewModel
        self.backgroundColor = backgroundColor
        self.screenAccessibility = screenAccessibility
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            VStack(alignment: .center, spacing: 0) {
                
                Spacer()

                let aspectRatio: CGSize = CGSize(width: 16, height: 9)
                let videoWidth: CGFloat = geometry.size.width
                let videoHeight: CGFloat = (videoWidth / aspectRatio.width) * aspectRatio.height
                
                VideoView(playerState: $videoPlayerState, frameSize: CGSize(width: videoWidth, height: videoHeight), videoId: viewModel.videoId, videoPlayerParameters: viewModel.videoPlayerParameters, configuration: VideoViewConfiguration(videoContainerBackgroundColor: backgroundColor, videoBackgroundColor: backgroundColor, loadingViewBackgroundColor: backgroundColor, loadingActivityIndicatorColor: .white), videoPlayingClosure: nil, videoEndedClosure: {
                    viewModel.videoEnded()
                })
                .frame(width: videoWidth, height: videoHeight)
                
                
                Spacer()
            }
        }
        .onAppear {
            videoPlayerState = .playing
        }
        .onDisappear {
            videoPlayerState = .paused
        }
        .accessibilityIdentifier(screenAccessibility.id)
        .statusBarHidden(true)
        .background(backgroundColor)
    }
}
