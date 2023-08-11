//
//  LearnToShareToolItemView.swift
//  godtools
//
//  Created by Levi Eggert on 8/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct LearnToShareToolItemView: View {
    
    private let contentHorizontalSpacing: CGFloat = 30
    private let animationAspectRatio: CGSize = CGSize(width: 414, height: 304)
    private let geometry: GeometryProxy
    
    @ObservedObject private var viewModel: LearnToShareToolItemViewModel
    
    init(viewModel: LearnToShareToolItemViewModel, geometry: GeometryProxy) {
        
        self.viewModel = viewModel
        self.geometry = geometry
    }
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            switch viewModel.assetContent {
            
            case .animation(let animationViewModel):
               
                let animationWidth: CGFloat = geometry.size.width * 1
                let animationHeight: CGFloat = (animationWidth / animationAspectRatio.width) * animationAspectRatio.height
                
                AnimatedSwiftUIView(viewModel: animationViewModel, contentMode: .scaleAspectFit)
                    .frame(width: animationWidth, height: animationHeight)
            
            case .image(let image):
                
                image
                    .resizable()
                    .scaledToFit()
           
            case .none:
                
                Rectangle()
                    .fill(.clear)
                    .frame(width: 150, height: 150)
                    .border(.gray)
            }
            
            Text(viewModel.title)
                .foregroundColor(ColorPalette.gtGrey.color)
                .font(FontLibrary.sfProTextBold.font(size: 27))
                .multilineTextAlignment(.center)
                .lineSpacing(1)
                .padding(EdgeInsets(top: 30, leading: contentHorizontalSpacing, bottom: 0, trailing: contentHorizontalSpacing))
            
            Text(viewModel.message)
                .foregroundColor(ColorPalette.gtGrey.color)
                .font(FontLibrary.sfProTextRegular.font(size: 17))
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .padding(EdgeInsets(top: 18, leading: contentHorizontalSpacing, bottom: 0, trailing: contentHorizontalSpacing))
        }
        .frame(width: geometry.size.width)
    }
}
