//
//  TutorialItemView.swift
//  godtools
//
//  Created by Levi Eggert on 8/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct TutorialItemView: View {
    
    private let textHorizontalSpacing: CGFloat = 30
    private let videoAssetHorizontalSpacing: CGFloat = 30
    private let imageAssetHorizontalSpacing: CGFloat = 30
    private let geometry: GeometryProxy
    private let videoPlayingClosure: (() -> Void)?
    
    @State private var videoPlayerState: VideoViewPlayerState = .stopped
    
    @ObservedObject private var viewModel: TutorialItemViewModel
    
    init(viewModel: TutorialItemViewModel, geometry: GeometryProxy, videoPlayingClosure: (() -> Void)?) {
        
        self.viewModel = viewModel
        self.geometry = geometry
        self.videoPlayingClosure = videoPlayingClosure
    }
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 0) {
            
            Text(viewModel.title)
                .foregroundColor(ColorPalette.gtBlue.color)
                .font(FontLibrary.sfProDisplayLight.font(size: 27))
                .multilineTextAlignment(.center)
                .lineSpacing(1)
                .padding(EdgeInsets(top: 0, leading: textHorizontalSpacing, bottom: 0, trailing: textHorizontalSpacing))
            
            Text(viewModel.message)
                .foregroundColor(ColorPalette.gtGrey.color)
                .font(FontLibrary.sfProTextLight.font(size: 17))
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .padding(EdgeInsets(top: 18, leading: textHorizontalSpacing, bottom: 0, trailing: textHorizontalSpacing))
            
            let mediaContainerAspectRatio: CGSize = CGSize(width: 1, height: 1)
            let mediaContainerWidth: CGFloat = geometry.size.width * 1
            let mediaContainerHeight: CGFloat = (mediaContainerWidth / mediaContainerAspectRatio.width) * mediaContainerAspectRatio.height
            
            VStack(alignment: .center, spacing: 0) {
             
                Spacer()
                
                if let youtubeVideoId = viewModel.youtubeVideoId, !youtubeVideoId.isEmpty {
                    
                    let videoAspectRatio: CGSize = CGSize(width: 16, height: 9)
                    let videoViewWidth: CGFloat = (mediaContainerWidth * 1) - (videoAssetHorizontalSpacing * 2)
                    let videoViewHeight: CGFloat = (videoViewWidth / videoAspectRatio.width) * videoAspectRatio.height
                    
                    VideoView(
                        playerState: $videoPlayerState,
                        frameSize: CGSize(width: videoViewWidth, height: videoViewHeight),
                        videoId: youtubeVideoId,
                        videoPlayerParameters: viewModel.youtubePlayerParameters,
                        configuration: nil,
                        videoPlayingClosure: videoPlayingClosure,
                        videoEndedClosure: nil
                    )
                    .frame(width: videoViewWidth, height: videoViewHeight)
                }
                else if let animatedViewModel = viewModel.animatedViewModel {
                                        
                    AnimatedSwiftUIView(viewModel: animatedViewModel, contentMode: .scaleAspectFit)
                }
                else if let imageName = viewModel.imageName, !imageName.isEmpty {
                    
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .padding(EdgeInsets(top: 0, leading: imageAssetHorizontalSpacing, bottom: 0, trailing: imageAssetHorizontalSpacing))
                }
                
                Spacer()
            }
            .frame(minWidth: mediaContainerWidth, idealWidth: mediaContainerWidth, maxWidth: mediaContainerWidth, minHeight: nil, idealHeight: nil, maxHeight: mediaContainerHeight, alignment: .top)
            
            Spacer()
        }
        .onDisappear {
            videoPlayerState = .stopped
        }
    }
}
