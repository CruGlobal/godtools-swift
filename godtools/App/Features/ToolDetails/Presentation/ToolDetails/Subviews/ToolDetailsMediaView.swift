//
//  ToolDetailsMediaView.swift
//  godtools
//
//  Created by Levi Eggert on 6/9/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolDetailsMediaView: View {
    
    private let aspectRatio: CGSize = CGSize(width: 16, height: 9)
    private let mediaViewSize: CGSize
    
    @State private var videoPlayerState: VideoViewPlayerState = .stopped
    
    @ObservedObject var viewModel: ToolDetailsViewModel
        
    init(viewModel: ToolDetailsViewModel, width: CGFloat) {
        
        let mediaWidth: CGFloat = width
        let mediaHeight: CGFloat = floor((mediaWidth / aspectRatio.width) * aspectRatio.height)
        
        self.viewModel = viewModel
        self.mediaViewSize = CGSize(width: mediaWidth, height: mediaHeight)
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            switch viewModel.mediaType {
                
            case .animation(let viewModel):
                
                AnimatedSwiftUIView(
                    viewModel: viewModel,
                    contentMode: .scaleAspectFill
                )
                .frame(width: mediaViewSize.width, height: mediaViewSize.height)
            
            case .image(let image):
                
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: mediaViewSize.width, height: mediaViewSize.height, alignment: .center)
                    .clipped()
           
            case .youtube(let videoId, let playerParameters):
                
                VideoView(
                    playerState: $videoPlayerState,
                    frameSize: mediaViewSize,
                    videoId: videoId,
                    videoPlayerParameters: playerParameters,
                    configuration: nil,
                    videoPlayingClosure: nil,
                    videoEndedClosure: nil
                )
                
            case .empty:
                VStack {
                    
                }
            }
        }
        .frame(width: mediaViewSize.width, height: mediaViewSize.height, alignment: .leading)
        .background(ColorPalette.gtLightestGrey.color)
    }
}
