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
    
    @ObservedObject var viewModel: BaseToolCardViewModel
    let cardWidth: CGFloat
    var isSpotlight = false
    
    // MARK: - Constants
    
    private enum Sizes {
        static let cornerRadius: CGFloat = 6
        static let spotlightCardWidth: CGFloat = 200
        static let spotlightCardHeight: CGFloat = 255
        static let spotlightCardHeightRatio: CGFloat = spotlightCardHeight / spotlightCardWidth
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .top) {
            
            RoundedCardBackgroundView(cornerRadius: Sizes.cornerRadius)
            
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    
                    ToolCardBannerImageView(bannerImage: viewModel.bannerImage, isSpotlight: isSpotlight, cardWidth: cardWidth, cornerRadius: Sizes.cornerRadius)
                    
                    ToolCardFavoritedView(isFavorited: viewModel.isFavorited)
                        .onTapGesture {
                            viewModel.favoritedButtonTapped()
                        }
                }
                
                ToolCardProgressView(frontProgress: viewModel.translationDownloadProgressValue, backProgress: viewModel.attachmentsDownloadProgressValue)
                
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) {
                        
                        ToolCardTitleView(title: viewModel.title)
                        
                        if isSpotlight {
                            
                            Spacer(minLength: 0)
                            ToolCardParallelLanguageView(languageName: viewModel.parallelLanguageName)
                            
                        } else {
                            ToolCardCategoryView(category: viewModel.category)
                        }
                    }
                    .padding([.leading, .bottom], 15)
                    
                    Spacer()
                    
                    if isSpotlight == false {
                        
                        ToolCardParallelLanguageView(languageName: viewModel.parallelLanguageName)
                            .padding(.top, 4)
                            .padding(.trailing, 10)
                    }
                }
                .frame(width: cardWidth)
                .padding(.top, 12)
                
            }
            
        }
        .frame(height: isSpotlight ? cardWidth * Sizes.spotlightCardHeightRatio : nil)
        .fixedSize(horizontal: true, vertical: true)
        .environment(\.layoutDirection, viewModel.layoutDirection)
    }
}

// MARK: - Preview

struct ToolCardView_Previews: PreviewProvider {
    
    static var previews: some View {
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        let isSpotlight = true
        
        ToolCardView(viewModel:
                        MockToolCardViewModel(
                            title: "Knowing God Personally",
                            category: "Gospel Invitation",
                            showParallelLanguage: true,
                            showBannerImage: true,
                            attachmentsDownloadProgress: 0.80,
                            translationDownloadProgress: 0.55,
                            deviceAttachmentBanners: appDiContainer.deviceAttachmentBanners
                        ),
                     cardWidth: isSpotlight ? 200 : 375,
                     isSpotlight: isSpotlight
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
