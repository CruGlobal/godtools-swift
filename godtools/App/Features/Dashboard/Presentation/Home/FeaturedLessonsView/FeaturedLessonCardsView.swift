//
//  FeaturedLessonCardsView.swift
//  godtools
//
//  Created by Rachael Skeath on 7/13/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct FeaturedLessonCardsView: View {
        
    private let width: CGFloat
    private let leadingPadding: CGFloat
    private let lessonTappedClosure: ((_ lesson: LessonDomainModel) -> Void)?
    
    @ObservedObject private var viewModel: FeaturedLessonCardsViewModel
    
    init(viewModel: FeaturedLessonCardsViewModel, width: CGFloat, leadingPadding: CGFloat, lessonTappedClosure: ((_ lesson: LessonDomainModel) -> Void)?) {
        
        self.viewModel = viewModel
        self.width = width
        self.leadingPadding = leadingPadding
        self.lessonTappedClosure = lessonTappedClosure
    }
    
    var body: some View {
        
        Group {
            
            Text(viewModel.sectionTitle)
                .font(FontLibrary.sfProTextRegular.font(size: 22))
                .foregroundColor(ColorPalette.gtGrey.color)
                .padding(.leading, leadingPadding)
            
            ForEach(viewModel.lessons) { (lesson: LessonDomainModel) in
                
                LessonCardView(viewModel: viewModel.cardViewModel(for: lesson), cardWidth: width - 2 * leadingPadding, cardTappedClosure: {
                    
                    lessonTappedClosure?(lesson)
                })
                .contentShape(Rectangle())
                .padding([.top, .bottom], 8)
                .padding([.leading, .trailing], leadingPadding)
                
            }
        }
    }
}

struct FeaturedLessonCardsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        
        let viewModel = FeaturedLessonCardsViewModel(
            localizationServices: appDiContainer.dataLayer.getLocalizationServices(),
            getFeaturedLessonsUseCase: appDiContainer.domainLayer.getFeaturedLessonsUseCase(),
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            attachmentsRepository: appDiContainer.dataLayer.getAttachmentsRepository()
        )
        
        FeaturedLessonCardsView(viewModel: viewModel, width: 350, leadingPadding: 20, lessonTappedClosure: nil)
    }
}
