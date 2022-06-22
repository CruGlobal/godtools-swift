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
        case .standard:     return nil
        case .spotlight:    return 75
        case .favorites:    return 136
        }
    }
    
    // MARK: - Constants
    
    private enum Sizes {
        static let cornerRadius: CGFloat = 6
        static let leadingPadding: CGFloat = 15
        static let flowButtonSpacing: CGFloat = 4
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
                            viewModel.favoritedButtonTapped()
                        }
                }
                
                ToolCardProgressView(frontProgress: viewModel.translationDownloadProgressValue, backProgress: viewModel.attachmentsDownloadProgressValue)
                
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) {
                        
                        ToolCardTitleView(title: viewModel.title)
                        
                        switch viewModel.cardType {
                        case .standard:
                            ToolCardCategoryView(category: viewModel.category)
                            
                        case .spotlight:
                            Spacer(minLength: 0)
                            ToolCardParallelLanguageView(languageName: viewModel.parallelLanguageName)
                            
                        case .favorites:
                            ToolCardCategoryView(category: viewModel.category)
                            ToolCardParallelLanguageView(languageName: viewModel.parallelLanguageName)
                                .padding(.top, 2)
                            
                            Spacer(minLength: 0)
                            HStack(spacing: Sizes.flowButtonSpacing) {
                                
                                let whiteSpaceAroundButtons = 2 * Sizes.leadingPadding + Sizes.flowButtonSpacing
                                let buttonWidth = (cardWidth - whiteSpaceAroundButtons)/2
                                
                                GTWhiteButton(title: viewModel.detailsButtonTitle, width: buttonWidth, height: 30) {
                                    // TODO: - open about
                                }
                                GTBlueButton(title: viewModel.openButtonTitle, width: buttonWidth, height: 30) {
                                    // TODO: - open tool
                                }
                            }
                        }
                    }
                    .padding(.leading, Sizes.leadingPadding)
                    .padding(.bottom, 14)
                    
                    Spacer()
                    
                    if viewModel.cardType.isSquareLayout == false {
                        
                        ToolCardParallelLanguageView(languageName: viewModel.parallelLanguageName)
                            .padding(.top, 4)
                            .padding(.trailing, 10)
                    }
                }
                .frame(width: cardWidth, height: whiteSpaceHeight, alignment: .topLeading)
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
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        let cardType: ToolCardType = .favorites
        
        ToolCardView(viewModel:
                        MockToolCardViewModel(
                            cardType: cardType,
                            title: "Knowing God Personally",
                            category: "Gospel Invitation",
                            showParallelLanguage: true,
                            showBannerImage: true,
                            attachmentsDownloadProgress: 0.80,
                            translationDownloadProgress: 0.55,
                            deviceAttachmentBanners: appDiContainer.deviceAttachmentBanners
                        ),
                     cardWidth: cardType.isSquareLayout ? 200 : 375
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
