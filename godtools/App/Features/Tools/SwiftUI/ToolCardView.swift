//
//  AllToolsContentView.swift
//  godtools
//
//  Created by Rachael Skeath on 3/30/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolCardView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: ToolCardViewModel
    var cardWidth: CGFloat
    
    // MARK: - Constants
    
    private enum Sizes {
        static let cardAspectRatio: CGFloat = cardWidth/cardHeight
        static let cardHeight: CGFloat = 150
        static let cardHeightSpotlight: CGFloat = 240
        static let cardWidth: CGFloat = 335
        static let cardWidthSpotlight: CGFloat = 200
        static let bannerImageAspectRatio: CGFloat = cardWidth/bannerImageHeight
        static let bannerImageHeight: CGFloat = 87
        static let bannerImageHeightSpotlight: CGFloat = 162
        static let leadingPadding: CGFloat = 15
        static let cornerRadius: CGFloat = 6
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: Sizes.cornerRadius, style: .circular)
                .fill(.white)
                .frame(width: cardWidth, height: cardWidth / Sizes.cardAspectRatio)
                .shadow(color: .black.opacity(0.25), radius: 4, y: 2)
            
            VStack(alignment: .leading, spacing: 12) {
                ZStack(alignment: .topTrailing) {
                    viewModel.bannerImage?
                        .resizable()
                        .scaledToFill()
                        .frame(width: cardWidth, height: cardWidth / Sizes.bannerImageAspectRatio)
                        .clipped()
                        .cornerRadius(Sizes.cornerRadius, corners: [.topLeft, .topRight])
                    
                    Image(viewModel.isFavorited ? "favorited_circle" : "unfavorited_circle")
                        .padding([.top, .trailing], 10)
                        .onTapGesture {
                            viewModel.favoritedButtonTapped()
                        }
                }
                
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(viewModel.title)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(ColorPalette.gtGrey.color)
                        Text(viewModel.category)
                            .font(.system(size: 12))
                    }
                    .padding(.leading, Sizes.leadingPadding)
                    
                    Spacer()
                    
                    Text(viewModel.parallelLanguageName)
                        .font(.system(size: 10))
                        .foregroundColor(ColorPalette.gtGrey.color)
                        .padding(.trailing, 10)
                        .padding(.top, 4)
                }
                .frame(width: cardWidth)
                
            }
            
        }
        .frame(width: cardWidth, height: cardWidth / Sizes.cardAspectRatio)
    }
}

// MARK: - Preview

struct ToolCardView_Previews: PreviewProvider {
    static var previews: some View {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        
        let viewModel = ToolCardViewModel(
            resourceId: "abc123",
            getBannerImageUseCase: MockGetBannerImageUseCase(),
            getToolDataUseCase: MockGetToolDataUseCase(),
            getLanguageNameUseCase: MockGetDefaultLanguageNameUseCase(),
            favoritedResourcesCache: appDiContainer.favoritedResourcesCache,
            languageSettingsService: appDiContainer.languageSettingsService
        )
        
        GeometryReader { geo in
            ToolCardView(viewModel: viewModel, cardWidth: geo.size.width)
        }
            .padding()
    }
}
