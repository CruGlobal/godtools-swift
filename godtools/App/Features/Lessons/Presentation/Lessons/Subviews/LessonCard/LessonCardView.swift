//
//  LessonCardView.swift
//  godtools
//
//  Created by Rachael Skeath on 6/27/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct LessonCardView: View {
        
    private let geometry: GeometryProxy
    private let backgroundColor: Color = Color.white
    private let cornerRadius: CGFloat = 6
    private let padding: CGFloat = 15
    private let cardWidth: CGFloat
    private let bannerImageAspectRatio: CGSize = CGSize(width: 335, height: 87)
    private let cardTappedClosure: (() -> Void)?
        
    @ObservedObject private var viewModel: LessonCardViewModel
    
    init(viewModel: LessonCardViewModel, geometry: GeometryProxy, cardTappedClosure: (() -> Void)?) {
        
        self.viewModel = viewModel
        self.geometry = geometry
        self.cardWidth = geometry.size.width - (DashboardView.contentHorizontalInsets * 2)
        self.cardTappedClosure = cardTappedClosure
    }
    
    var body: some View {
        
        ZStack {
            
            backgroundColor
            
            VStack(alignment: .leading, spacing: 0) {
                
                OptionalImage(
                    imageData: viewModel.bannerImageData,
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
                       
                        Text(viewModel.completionString)
                            .font(FontLibrary.sfProDisplayRegular.font(size: 12))
                            .foregroundColor(ColorPalette.gtBlue.color)
                        
                        Spacer()
                        
                        ToolCardLanguageAvailabilityView(
                            languageAvailability: viewModel.appLanguageAvailability
                        )
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
}

// MARK: - Preview

struct LessonCardView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        
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
            attachmentsRepository: appDiContainer.dataLayer.getAttachmentsRepository()
        )
        
        GeometryReader { geometry in
            
            LessonCardView(viewModel: viewModel, geometry: geometry, cardTappedClosure: nil)
        }
    }
}
