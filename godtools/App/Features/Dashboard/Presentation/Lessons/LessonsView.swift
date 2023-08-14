//
//  LessonsView.swift
//  godtools
//
//  Created by Rachael Skeath on 7/12/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct LessonsView: View {
        
    @ObservedObject private var viewModel: LessonsViewModel
    
    let leadingTrailingPadding: CGFloat
    
    init(viewModel: LessonsViewModel, leadingTrailingPadding: CGFloat) {
        
        self.viewModel = viewModel
        self.leadingTrailingPadding = leadingTrailingPadding
    }
    
    var body: some View {
        
        GeometryReader { geometry in
                        
            PullToRefreshScrollView(showsIndicators: true) {
                
                LazyVStack(alignment: .leading, spacing: 0) {
                 
                    VStack(alignment: .leading, spacing: 0) {
                        
                        Text(viewModel.sectionTitle)
                            .font(FontLibrary.sfProTextRegular.font(size: 22))
                            .foregroundColor(ColorPalette.gtGrey.color)
                        
                        FixedVerticalSpacer(height: 5)
                        
                        Text(viewModel.subtitle)
                            .font(FontLibrary.sfProTextRegular.font(size: 14))
                            .foregroundColor(ColorPalette.gtGrey.color)
                    }
                    .padding(EdgeInsets(top: 24, leading: leadingTrailingPadding, bottom: 7, trailing: leadingTrailingPadding))
                    
                    VStack(spacing: 0) {
                        
                        ForEach(viewModel.lessons) { (lesson: LessonDomainModel) in
                            
                            let cardWidth: CGFloat = geometry.size.width - (2 * leadingTrailingPadding)
                            
                            LessonCardView(viewModel: viewModel.cardViewModel(for: lesson), cardWidth: cardWidth, cardTappedClosure: {
                                
                                viewModel.lessonCardTapped(lesson: lesson)
                            })
                            .padding([.top, .bottom], 8)
                            .padding([.leading, .trailing], leadingTrailingPadding)
                        }
                    }
                    .padding(.bottom, 27)
                }
                
            } refreshHandler: {
                viewModel.refreshData()
            }
            .animation(.default, value: viewModel.lessons)
        }
        .onAppear {
            viewModel.pageViewed()
        }
    }
}

struct LessonsView_Previews: PreviewProvider {
    static var previews: some View {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        
        let viewModel = LessonsViewModel(
            flowDelegate: MockFlowDelegate(),
            dataDownloader: appDiContainer.dataLayer.getInitialDataDownloader(),
            localizationServices: appDiContainer.dataLayer.getLocalizationServices(),
            analytics: appDiContainer.dataLayer.getAnalytics(),
            getBannerImageUseCase: appDiContainer.domainLayer.getBannerImageUseCase(),
            getLanguageAvailabilityUseCase: appDiContainer.domainLayer.getLanguageAvailabilityUseCase(),
            getLessonsUseCase: appDiContainer.domainLayer.getLessonsUseCase(),
            getSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getSettingsParallelLanguageUseCase(),
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            translationsRepository: appDiContainer.dataLayer.getTranslationsRepository()
        )
        
        LessonsView(viewModel: viewModel, leadingTrailingPadding: 20)
    }
}
