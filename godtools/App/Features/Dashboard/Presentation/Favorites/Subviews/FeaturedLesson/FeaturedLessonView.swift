//
//  FeaturedLessonView.swift
//  godtools
//
//  Created by Rachael Skeath on 7/13/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct FeaturedLessonView: View {
        
    private let width: CGFloat
    private let leadingPadding: CGFloat
    private let lessonTappedClosure: ((_ lesson: LessonDomainModel) -> Void)?
    
    @ObservedObject private var viewModel: FeaturedLessonViewModel
    
    init(viewModel: FeaturedLessonViewModel, width: CGFloat, leadingPadding: CGFloat, lessonTappedClosure: ((_ lesson: LessonDomainModel) -> Void)?) {
        
        self.viewModel = viewModel
        self.width = width
        self.leadingPadding = leadingPadding
        self.lessonTappedClosure = lessonTappedClosure
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            Text(viewModel.sectionTitle)
                .font(FontLibrary.sfProTextRegular.font(size: 22))
                .foregroundColor(ColorPalette.gtGrey.color)
                .padding(.leading, leadingPadding)
            
            VStack(alignment: .leading, spacing: 0) {
                
                ForEach(viewModel.featuredLessons) { (lesson: LessonDomainModel) in
                    
                    LessonCardView(viewModel: viewModel.cardViewModel(for: lesson), cardWidth: width - 2 * leadingPadding, cardTappedClosure: {
                        
                        lessonTappedClosure?(lesson)
                    })
                    .padding([.top, .bottom], 8)
                    .padding([.leading, .trailing], leadingPadding)
                }
            }
        }
    }
}

struct FeaturedLessonView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        
        let viewModel = FeaturedLessonViewModel(
            localizationServices: appDiContainer.dataLayer.getLocalizationServices(),
            getFeaturedLessonsUseCase: appDiContainer.domainLayer.getFeaturedLessonsUseCase(),
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            attachmentsRepository: appDiContainer.dataLayer.getAttachmentsRepository()
        )
        
        FeaturedLessonView(
            viewModel: viewModel,
            width: 350,
            leadingPadding: 20,
            lessonTappedClosure: nil
        )
    }
}
