//
//  LessonCardView.swift
//  godtools
//
//  Created by Rachael Skeath on 6/27/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct LessonCardView: View {
        
    private let backgroundColor: Color = Color.white
    private let cornerRadius: CGFloat = 6
    private let cardWidth: CGFloat
    private let bannerImageAspectRatio: CGSize = CGSize(width: 335, height: 87)
    private let contentHorizontalPadding: CGFloat = 15
    private let cardTappedClosure: (() -> Void)?
        
    @ObservedObject private var viewModel: LessonCardViewModel
    
    init(viewModel: LessonCardViewModel, cardWidth: CGFloat, cardTappedClosure: (() -> Void)?) {
        
        self.viewModel = viewModel
        self.cardWidth = cardWidth
        self.cardTappedClosure = cardTappedClosure
    }
    
    var body: some View {
        
        ZStack {
            
            backgroundColor
            
            VStack(alignment: .leading, spacing: 0) {
                
                OptionalImage(
                    image: viewModel.bannerImage,
                    imageSize: .aspectRatio(width: cardWidth, aspectRatio: bannerImageAspectRatio),
                    contentMode: .fill,
                    placeholderColor: ColorPalette.gtLightestGrey.color
                )
                
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
                        
                        ToolCardLanguageAvailabilityView(
                            languageAvailability: viewModel.languageAvailability
                        )
                    }
                }
                .padding([.top, .bottom], 15)
                .padding([.leading, .trailing], contentHorizontalPadding)
                .frame(width: cardWidth, alignment: .topLeading)
                
            }
            .frame(width: cardWidth)
        }
        .frame(width: cardWidth)
        .cornerRadius(cornerRadius)
        .shadow(color: Color.black.opacity(0.25), radius: 4, y: 2)
        .contentShape(Rectangle()) // onTapGesture's tappable area doesn't always line up with the card's actual position-- possibly due to added padding (?).  This is especially noticeable on iOS14.  Adding .contentShape fixed this
        .onTapGesture {
            cardTappedClosure?()
        }
    }
}

struct LessonCardView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        
        let lesson = LessonDomainModel(
            analyticsToolName: "five",
            bannerImageId: "1",
            dataModelId: "9",
            languageIds: [],
            languageAvailability: "Chinese x",
            title: "Five Reasons to be Courageous"
        )
        
        let viewModel = LessonCardViewModel(
            lesson: lesson,
            attachmentsRepository: appDiContainer.dataLayer.getAttachmentsRepository()
        )
        
        LessonCardView(viewModel: viewModel, cardWidth: 345, cardTappedClosure: nil)
    }
}
