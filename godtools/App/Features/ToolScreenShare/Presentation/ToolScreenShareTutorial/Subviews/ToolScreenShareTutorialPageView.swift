//
//  ToolScreenShareTutorialPageView.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct ToolScreenShareTutorialPageView: View {
    
    private let tutorialPage: ToolScreenShareTutorialPageDomainModel
    private let textHorizontalSpacing: CGFloat = 30
    private let videoAssetHorizontalSpacing: CGFloat = 30
    private let imageAssetHorizontalSpacing: CGFloat = 30
    private let geometry: GeometryProxy
    
    @State private var videoPlayerState: VideoViewPlayerState = .stopped
        
    init(tutorialPage: ToolScreenShareTutorialPageDomainModel, geometry: GeometryProxy) {
        
        self.tutorialPage = tutorialPage
        self.geometry = geometry
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
                }
                
                /*
                if animationMedia {
                    
                    AnimatedSwiftUIView(
                        viewModel: AnimatedViewModel(animationDataResource: animatedResource, autoPlay: true, loop: true),
                        contentMode: .scaleAspectFit
                    )
                }
                else {
                    
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 100, height: 100)
                }*/
                
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
