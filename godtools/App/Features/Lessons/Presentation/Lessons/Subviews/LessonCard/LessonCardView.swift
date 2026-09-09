//
//  LessonCardView.swift
//  godtools
//
//  Created by Rachael Skeath on 6/27/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct LessonCardView: View {
        
    // NOTE: The card's shadow extends this far beyond its frame.  Containers that clip their content need to inset by it. ~Rachael
    static let shadowClippingInset: CGFloat = 6

    private static let featuredCardWidthMultiplier: CGFloat = 0.58

    private let geometry: GeometryProxy
    private let backgroundColor: Color = Color.white
    private let cornerRadius: CGFloat = 6
    private let padding: CGFloat = 15
    private let layout: LessonCardLayout
    private let cardWidth: CGFloat
    private let bannerImageAspectRatio: CGSize
    private let titleFontSize: CGFloat
    private let titleTrailingPadding: CGFloat
    private let cardTappedClosure: (() -> Void)?

    @ObservedObject private var viewModel: LessonCardViewModel

    init(viewModel: LessonCardViewModel, geometry: GeometryProxy, layout: LessonCardLayout = .landscape, cardTappedClosure: (() -> Void)?) {

        self.viewModel = viewModel
        self.geometry = geometry
        self.layout = layout

        let contentWidth: CGFloat = geometry.size.width - (DashboardView.contentHorizontalInsets * 2)

        switch layout {

        case .landscape:
            self.cardWidth = contentWidth
            self.bannerImageAspectRatio = CGSize(width: 335, height: 87)
            self.titleFontSize = 17
            self.titleTrailingPadding = 41

        case .featured:
            self.cardWidth = contentWidth * LessonCardView.featuredCardWidthMultiplier
            self.bannerImageAspectRatio = CGSize(width: 217, height: 88)
            self.titleFontSize = 15
            // NOTE: The landscape card reserves trailing space for its wider layout.  A featured card is too narrow to spare it. ~Rachael
            self.titleTrailingPadding = 0
        }

        self.cardTappedClosure = cardTappedClosure
    }
    
    var body: some View {
        
        ZStack {
            
            backgroundColor
            
            VStack(alignment: .leading, spacing: 0) {
                
                OptionalImage(
                    imageData: viewModel.banner,
                    imageSize: .aspectRatio(width: cardWidth, aspectRatio: bannerImageAspectRatio),
                    contentMode: .fill,
                    placeholderColor: ColorPalette.gtLightestGrey.color
                )
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    Text(viewModel.title)
                        .font(FontLibrary.sfProTextBold.font(size: titleFontSize))
                        .foregroundColor(ColorPalette.gtGrey.color)
                        .lineSpacing(2)
                        .lineLimit(3)
                        .padding(.trailing, titleTrailingPadding)
                        .frame(width: cardWidth - (padding * 2), alignment: .leading)
                        .environment(\.layoutDirection, viewModel.titleLayoutDirection)
                    
                    FixedVerticalSpacer(height: 9)
                    
                    if viewModel.shouldShowLessonProgress {
                        LessonCompletionProgressBar(lessonProgress: viewModel.lessonProgress)
                            .padding(.bottom, 15)
                        
                    } else {
                        Spacer()
                    }
                    
                    HStack(alignment: .center, spacing: 10) {

                        switch layout {

                        case .landscape:
                            completionText
                            Spacer()
                            languageAvailability

                        case .featured:
                            languageAvailability
                            Spacer()
                            completionText
                        }
                    }
                }
                .padding(EdgeInsets(top: padding, leading: padding, bottom: padding, trailing: padding))
            }
        }
        .frame(width: cardWidth)
        .cornerRadius(cornerRadius)
        .shadow(color: Color.black.opacity(0.25), radius: 4, y: 2)
        .contentShape(Rectangle()) // This fixes tap area not taking entire card into account.  Noticeable in iOS 14.
        .onTapGesture {
            cardTappedClosure?()
        }
    }

    @ViewBuilder private var completionText: some View {

        Text(viewModel.completionString)
            .font(FontLibrary.sfProDisplayRegular.font(size: 12))
            .foregroundColor(ColorPalette.gtBlue.color)
    }

    @ViewBuilder private var languageAvailability: some View {

        ToolCardLanguageAvailabilityView(
            languageAvailability: viewModel.appLanguageAvailability
        )
    }
}

// MARK: - Preview

struct LessonCardView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let appDiContainer = AppDiContainer.createUITestsDiContainer()
        
        let lessonListItem = LessonListItemDomainModel(
            analyticsToolName: "",
            availabilityInAppLanguage: ToolLanguageAvailabilityDomainModel(availabilityString: "available in language", isAvailable: true),
            bannerImageId: "1",
            dataModelId: "1",
            name: "Five Reasons to be Courageous", 
            nameLanguageDirection: .rightToLeft,
            lessonProgress: LessonListItemProgressDomainModel.inProgress(progress: 0.7, progressString: "70% Complete")
        )
        
        let viewModel = LessonCardViewModel(
            lessonListItem: lessonListItem,
            getToolBannerUseCase: appDiContainer.core.domainLayer.getToolBannerUseCase(),
            imageCache: appDiContainer.core.dataLayer.getSharedImageCache()
        )
        
        GeometryReader { geometry in
            
            LessonCardView(viewModel: viewModel, geometry: geometry, cardTappedClosure: nil)
        }
    }
}
