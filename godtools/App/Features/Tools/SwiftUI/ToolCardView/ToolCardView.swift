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
    let cardWidth: CGFloat
    
    // MARK: - Constants
    
    private enum Sizes {
        static let cardAspectRatio: CGFloat = cardWidth/cardHeight
        static let cardHeight: CGFloat = 150
        static let cardWidth: CGFloat = 335
        static let bannerImageAspectRatio: CGFloat = cardWidth/bannerImageHeight
        static let bannerImageHeight: CGFloat = 87
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
                    OptionalImage(image: viewModel.bannerImage, width: cardWidth, height: cardWidth / Sizes.bannerImageAspectRatio)
                        .cornerRadius(Sizes.cornerRadius, corners: [.topLeft, .topRight])
                    
                    Image(viewModel.isFavorited ? "favorited_circle" : "unfavorited_circle")
                        .padding([.top, .trailing], 10)
                        .onTapGesture {
                            viewModel.favoritedButtonTapped()
                        }
                }
                .transition(.opacity)
                
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
        .environment(\.layoutDirection, viewModel.layoutDirection)
    }
}

// MARK: - Preview

struct ToolCardView_Previews: PreviewProvider {
    static var previews: some View {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        
        let viewModel = ToolCardViewModel(
            resource: appDiContainer.initialDataDownloader.resourcesCache.getResource(id: "2")!,
            dataDownloader: appDiContainer.initialDataDownloader,
            deviceAttachmentBanners: appDiContainer.deviceAttachmentBanners,
            favoritedResourcesCache: appDiContainer.favoritedResourcesCache,
            languageSettingsService: appDiContainer.languageSettingsService,
            localizationServices: appDiContainer.localizationServices
        )
        
        GeometryReader { geo in
            ToolCardView(viewModel: viewModel, cardWidth: geo.size.width)
        }
            .padding()
    }
}
