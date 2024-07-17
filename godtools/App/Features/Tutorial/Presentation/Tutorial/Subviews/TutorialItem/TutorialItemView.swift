//
//  TutorialItemView.swift
//  godtools
//
//  Created by Levi Eggert on 8/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct TutorialItemView: View {
    
    private let tutorialPage: TutorialPageDomainModel
    private let textHorizontalSpacing: CGFloat = 30
    private let videoAssetHorizontalSpacing: CGFloat = 30
    private let imageAssetHorizontalSpacing: CGFloat = 30
    private let geometry: GeometryProxy
    private let videoPlayingClosure: (() -> Void)?
    
    @State private var videoPlayerState: VideoViewPlayerState = .stopped
        
    init(tutorialPage: TutorialPageDomainModel, geometry: GeometryProxy, videoPlayingClosure: (() -> Void)?) {
        
        self.tutorialPage = tutorialPage
        self.geometry = geometry
        self.videoPlayingClosure = videoPlayingClosure
    }
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 0) {
            
            Text(tutorialPage.title)
                .foregroundColor(ColorPalette.gtBlue.color)
                .font(FontLibrary.sfProDisplayLight.font(size: 27))
                .multilineTextAlignment(.center)
                .lineSpacing(1)
                .padding(EdgeInsets(top: 0, leading: textHorizontalSpacing, bottom: 0, trailing: textHorizontalSpacing))
            
            Text(tutorialPage.message)
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
                
                switch tutorialPage.media {
                
                case .animation(let animatedResource):
                    
                    AnimatedSwiftUIView(
                        viewModel: AnimatedViewModel(animationDataResource: animatedResource, autoPlay: true, loop: true),
                        contentMode: .scaleAspectFit
                    )
                
                case .image(let name):
                    
                    Image(name)
                        .resizable()
                        .scaledToFit()
                        .padding(EdgeInsets(top: 0, leading: imageAssetHorizontalSpacing, bottom: 0, trailing: imageAssetHorizontalSpacing))
                
                case .noMedia:
                    
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 100, height: 100)
                
                case .video(let videoId):
                    
                    let videoAspectRatio: CGSize = CGSize(width: 16, height: 9)
                    let videoViewWidth: CGFloat = (mediaContainerWidth * 1) - (videoAssetHorizontalSpacing * 2)
                    let videoViewHeight: CGFloat = (videoViewWidth / videoAspectRatio.width) * videoAspectRatio.height
                    
                    let playsInFullScreen: Int = 0
                    let playerParameters: [String: Any] = [YoutubePlayerParameters.playsInline.rawValue: playsInFullScreen]
                    
                    VideoViewRepresentable(
                        playerState: $videoPlayerState,
                        frameSize: CGSize(width: videoViewWidth, height: videoViewHeight),
                        videoId: videoId,
                        videoPlayerParameters: playerParameters,
                        configuration: nil,
                        videoPlayingClosure: videoPlayingClosure,
                        videoEndedClosure: nil
                    )
                    .frame(width: videoViewWidth, height: videoViewHeight)
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
