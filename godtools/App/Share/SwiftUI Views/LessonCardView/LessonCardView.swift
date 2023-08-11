//
//  LessonCardView.swift
//  godtools
//
//  Created by Rachael Skeath on 6/27/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct LessonCardView: View {
        
    private enum Sizes {
        static let cornerRadius: CGFloat = 6
        static let leadingPadding: CGFloat = 15
    }
    
    private let cardWidth: CGFloat
        
    @ObservedObject private var viewModel: BaseLessonCardViewModel
    
    init(viewModel: BaseLessonCardViewModel, cardWidth: CGFloat) {
        
        self.viewModel = viewModel
        self.cardWidth = cardWidth
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            
            RoundedCardBackgroundView(cornerRadius: Sizes.cornerRadius)
            
            VStack(alignment: .leading, spacing: 0) {
                ResourceCardBannerImageView(bannerImage: viewModel.bannerImage, isSquareLayout: false, cardWidth: cardWidth, cornerRadius: Sizes.cornerRadius)
                
                ResourceCardProgressView(frontProgress: viewModel.translationDownloadProgressValue, backProgress: viewModel.attachmentsDownloadProgressValue)
                
                VStack(alignment: .leading, spacing: 9) {
                    
                    Text(viewModel.title)
                        .font(FontLibrary.sfProTextBold.font(size: 17))
                        .foregroundColor(ColorPalette.gtGrey.color)
                        .lineSpacing(2)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.trailing, 41)
                    
                    HStack {
                        Spacer()
                        ResourceCardLanguageView(languageName: viewModel.translationAvailableText)
                    }
                }
                .padding([.top, .bottom], 15)
                .padding([.leading, .trailing], Sizes.leadingPadding)
                .frame(width: cardWidth, alignment: .topLeading)
            }
            
        }
        .fixedSize(horizontal: true, vertical: true)
        // onTapGesture's tappable area doesn't always line up with the card's actual position-- possibly due to added padding (?).  This is especially noticeable on iOS14.  Adding .contentShape fixed this.
        .contentShape(Rectangle())
        .animation(.default, value: viewModel.bannerImage)
        .onTapGesture {
            viewModel.lessonCardTapped()
        }
    }
}

struct LessonCardView_Previews: PreviewProvider {
    static var previews: some View {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        let lesson = LessonDomainModel(abbreviation: "five", bannerImageId: "1", dataModelId: "9", description: "five reasons", languageIds: [], name: "Five Reasons to be Courageous")
        
        let viewModel = LessonCardViewModel(
            lesson: lesson,
            dataDownloader: appDiContainer.dataLayer.getInitialDataDownloader(),
            translationsRepository: appDiContainer.dataLayer.getTranslationsRepository(),
            getBannerImageUseCase: appDiContainer.domainLayer.getBannerImageUseCase(),
            getLanguageAvailabilityUseCase: appDiContainer.domainLayer.getLanguageAvailabilityUseCase(),
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            delegate: nil
        )
        
        LessonCardView(viewModel: viewModel, cardWidth: 345)
    }
}
