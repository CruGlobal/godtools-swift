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
    
    // MARK: - Constants
    
    private enum Sizes {
        static let cardAspectRatio: CGFloat = cardWidth/cardHeight
        static let cardHeight: CGFloat = 150
        static let cardWidth: CGFloat = 335
        static let bannerImageAspectRatio: CGFloat = cardWidth/bannerImageHeight
        static let bannerImageHeight: CGFloat = 87
        static let cornerRadius: CGFloat = 6
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
                    OptionalImage(image: viewModel.bannerImage, width: cardWidth, height: cardWidth / Sizes.bannerImageAspectRatio)
                        .cornerRadius(Sizes.cornerRadius, corners: [.topLeft, .topRight])
                    
                    Image(viewModel.isFavorited ? ImageCatalog.favoritedCircle.name : ImageCatalog.unfavoritedCircle.name)
                        .padding([.top, .trailing], 10)
                        .onTapGesture {
                            viewModel.favoritedButtonTapped()
                        }
                }
                .transition(.opacity)
                
                // MARK: - Progress Bars
                ZStack {
                    ProgressBarView(color: .yellow, progress: viewModel.attachmentsDownloadProgressValue)
                    ProgressBarView(color: ColorPalette.progressBarBlue.color, progress: viewModel.translationDownloadProgressValue)
                }
                .frame(height: 2)
                
                // MARK: - Text
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(viewModel.title)
                            .font(FontLibrary.sfProTextBold.font(size: 18))
                            .foregroundColor(ColorPalette.gtGrey.color)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text(viewModel.category)
                            .font(FontLibrary.sfProTextRegular.font(size: 14))
                            .foregroundColor(ColorPalette.gtGrey.color)
                    }
                    .padding([.leading, .bottom], 15)
                    
                    Spacer()
                    
                    Text(viewModel.parallelLanguageName)
                        .font(FontLibrary.sfProTextRegular.font(size: 12))
                        .foregroundColor(ColorPalette.gtLightGrey.color)
                        .padding(.trailing, 10)
                        .padding(.top, 4)
                }
                .frame(width: cardWidth)
                .padding(.top, 12)
                
            }
            
        }
        .fixedSize(horizontal: false, vertical: true)
        .environment(\.layoutDirection, viewModel.layoutDirection)
    }
}

// MARK: - Preview

struct ToolCardView_Previews: PreviewProvider {
    static var previews: some View {
        
            ToolCardView(viewModel:
                            MockToolCardViewModel(
                                title: "Knowing God Personally",
                                category: "Gospel Invitation",
                                showParallelLanguage: true,
                                showBannerImage: true,
                                attachmentsDownloadProgress: 0.80,
                                translationDownloadProgress: 0.55
                            ),
                         cardWidth: 375)
                .padding()
                .previewLayout(.sizeThatFits)
    }
}
