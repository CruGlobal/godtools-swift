//
//  LessonCardView.swift
//  godtools
//
//  Created by Rachael Skeath on 6/27/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct LessonCardView: View {
        
    private let cornerRadius: CGFloat = 6
    private let cardWidth: CGFloat
    private let cardTappedClosure: (() -> Void)?
        
    @ObservedObject private var viewModel: LessonCardViewModel
    
    init(viewModel: LessonCardViewModel, cardWidth: CGFloat, cardTappedClosure: (() -> Void)?) {
        
        self.viewModel = viewModel
        self.cardWidth = cardWidth
        self.cardTappedClosure = cardTappedClosure
    }
    
    var body: some View {
        
        ZStack {
            
            RoundedCardBackgroundView(cornerRadius: cornerRadius, fillColor: .white)
            
            VStack(alignment: .leading, spacing: 0) {
                
                ResourceCardBannerImageView(bannerImage: viewModel.bannerImage, isSquareLayout: false, cardWidth: cardWidth, cornerRadius: cornerRadius)
                                
                VStack(alignment: .leading, spacing: 0) {
                    
                    Text(viewModel.title)
                        .font(FontLibrary.sfProTextBold.font(size: 17))
                        .foregroundColor(ColorPalette.gtGrey.color)
                        .lineSpacing(2)
                        .lineLimit(3)
                        .padding(.trailing, 41)
                    
                    FixedVerticalSpacer(height: 9)
                    
                    HStack {
                        Spacer()
                        ResourceCardLanguageView(languageName: viewModel.translationAvailableText)
                    }
                }
                .padding([.top, .bottom], 15)
                .padding([.leading, .trailing], 15)
                .frame(width: cardWidth, alignment: .topLeading)
            }
            
        }
        .contentShape(Rectangle()) // onTapGesture's tappable area doesn't always line up with the card's actual position-- possibly due to added padding (?).  This is especially noticeable on iOS14.  Adding .contentShape fixed this.
        .onTapGesture {
            cardTappedClosure?()
        }
    }
}

struct LessonCardView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        
        let lesson = LessonDomainModel(
            abbreviation: "five",
            bannerImageId: "1",
            dataModelId: "9",
            description: "five reasons",
            languageIds: [],
            name: "Five Reasons to be Courageous"
        )
        
        let viewModel = LessonCardViewModel(
            lesson: lesson,
            dataDownloader: appDiContainer.dataLayer.getInitialDataDownloader(),
            translationsRepository: appDiContainer.dataLayer.getTranslationsRepository(),
            getBannerImageUseCase: appDiContainer.domainLayer.getBannerImageUseCase(),
            getLanguageAvailabilityUseCase: appDiContainer.domainLayer.getLanguageAvailabilityUseCase(),
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase()
        )
        
        LessonCardView(viewModel: viewModel, cardWidth: 345, cardTappedClosure: nil)
    }
}
