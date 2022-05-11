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
        
        enum Default {
            static let cardAspectRatio: CGFloat = cardWidth/cardHeight
            static let cardHeight: CGFloat = 150
            static let cardWidth: CGFloat = 335
            static let bannerImageAspectRatio: CGFloat = cardWidth/bannerImageHeight
            static let bannerImageHeight: CGFloat = 87
        }
        enum Spotlight {
            static let cardAspectRatio: CGFloat = cardWidth/cardHeight
            static let cardHeight: CGFloat = 240
            static let cardWidth: CGFloat = 200
            static let bannerImageAspectRatio: CGFloat = cardWidth/bannerImageHeight
            static let bannerImageHeight: CGFloat = 162
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .top) {
            // MARK: - Card Background
            RoundedRectangle(cornerRadius: Sizes.cornerRadius, style: .circular)
                .fill(.white)
                .shadow(color: .black.opacity(0.25), radius: 4, y: 2)
            
            VStack(alignment: .leading, spacing: 0) {
                
                // MARK: - Image
                ZStack(alignment: .topTrailing) {
                    ToolCardBannerImageView(bannerImage: viewModel.bannerImage, isSpotlight: isSpotlight, cardWidth: cardWidth, cornerRadius: Sizes.cornerRadius)
                    
                    Image(viewModel.isFavorited ? ImageCatalog.favoritedCircle.name : ImageCatalog.unfavoritedCircle.name)
                        .padding([.top, .trailing], 10)
                        .onTapGesture {
                            viewModel.favoritedButtonTapped()
                        }
                }
                .transition(.opacity)
                
                ToolCardProgressView(frontProgress: viewModel.translationDownloadProgressValue, backProgress: viewModel.attachmentsDownloadProgressValue)
                
                // MARK: - Text
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(viewModel.title)
                            .font(FontLibrary.sfProTextBold.font(size: 18))
                            .foregroundColor(ColorPalette.gtGrey.color)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        if isSpotlight {
                            ToolCardParallelLanguageView(languageName: viewModel.parallelLanguageName)
                            
                        } else {
                            Text(viewModel.category)
                                .font(FontLibrary.sfProTextRegular.font(size: 14))
                                .foregroundColor(ColorPalette.gtGrey.color)
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
        .fixedSize(horizontal: true, vertical: true)
        .environment(\.layoutDirection, viewModel.layoutDirection)
    }
}

// MARK: - Preview

struct ToolCardView_Previews: PreviewProvider {
    
    static var previews: some View {
        let isSpotlight = true
        
        ToolCardView(viewModel:
                        MockToolCardViewModel(
                            title: "Knowing God Personally",
                            category: "Gospel Invitation",
                            showParallelLanguage: true,
                            showBannerImage: true,
                            attachmentsDownloadProgress: 0.80,
                            translationDownloadProgress: 0.55
                        ),
                     cardWidth: isSpotlight ? 200 : 375,
                     isSpotlight: isSpotlight
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
