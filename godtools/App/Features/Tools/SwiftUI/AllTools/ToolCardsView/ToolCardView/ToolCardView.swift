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
    
    var whiteSpaceHeight: CGFloat? {
        switch viewModel.cardType {
        case .standard, .standardWithNavButtons:
            return nil
        case .square:
            return 75
        case .squareWithNavButtons:
            return 136
        }
    }
    
    // MARK: - Constants
    
    private enum Sizes {
        static let cornerRadius: CGFloat = 6
        static let leadingPadding: CGFloat = 15
        static let navButtonWidthMultiplier: CGFloat = 192/335
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .top) {
            
            RoundedCardBackgroundView(cornerRadius: Sizes.cornerRadius)
            
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    
                    ToolCardBannerImageView(bannerImage: viewModel.bannerImage, cardType: viewModel.cardType, cardWidth: cardWidth, cornerRadius: Sizes.cornerRadius)
                    
                    ToolCardFavoritedView(isFavorited: viewModel.isFavorited)
                        .onTapGesture {
                            viewModel.favoriteToolButtonTapped()
                        }
                }
                
                ToolCardProgressView(frontProgress: viewModel.translationDownloadProgressValue, backProgress: viewModel.attachmentsDownloadProgressValue)
                
                VStack(alignment: .trailing, spacing: 5) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 3) {
                            
                            ToolCardVerticalTextView(viewModel: viewModel, cardWidth: cardWidth)
                            
                            if viewModel.cardType == .squareWithNavButtons {
                                Spacer(minLength: 0)
                                
                                ToolCardNavButtonView(sizeToFit: cardWidth, leadingPadding: Sizes.leadingPadding, buttonSpacing: 4, viewModel: viewModel)
                            }
                        }
                        .padding(.leading, Sizes.leadingPadding)
                        
                        Spacer()
                        
                        if viewModel.cardType.isStandardLayout {
                            
                            ToolCardParallelLanguageView(languageName: viewModel.parallelLanguageName)
                                .padding(.top, 4)
                                .padding(.trailing, 14)
                        }
                    }
                    
                    if viewModel.cardType == .standardWithNavButtons {
                        ToolCardNavButtonView(sizeToFit: cardWidth * Sizes.navButtonWidthMultiplier, leadingPadding: 0, buttonSpacing: 8, viewModel: viewModel)
                            .padding(.trailing, 14)
                    }
                }
                .frame(width: cardWidth, height: whiteSpaceHeight, alignment: .topLeading)
                .padding(.top, 12)
                .padding(.bottom, 14)
                
            }
            
        }
        .fixedSize(horizontal: true, vertical: true)
        .environment(\.layoutDirection, viewModel.layoutDirection)
        // onTapGesture's tappable area doesn't always line up with the card's actual position-- possibly due to added padding (?).  This is especially noticeable on iOS14.  Adding .contentShape fixed this.
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.toolCardTapped()
        }
    }
}

// MARK: - Preview

struct ToolCardView_Previews: PreviewProvider {
    
    static var previews: some View {
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        let cardType: ToolCardType = .standardWithNavButtons
        
        let viewModel = MockToolCardViewModel(
            cardType: cardType,
            title: "Knowing God Personally",
            category: "Gospel Invitation",
            showParallelLanguage: true,
            showBannerImage: true,
            attachmentsDownloadProgress: 0.80,
            translationDownloadProgress: 0.55,
            deviceAttachmentBanners: appDiContainer.deviceAttachmentBanners
        )
        
        ToolCardView(viewModel: viewModel, cardWidth: cardType.isSquareLayout ? 200 : 375)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
