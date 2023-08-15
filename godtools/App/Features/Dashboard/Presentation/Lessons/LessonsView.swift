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
                
                VStack(alignment: .leading, spacing: 0) {
                                        
                    LessonsHeaderView(
                        viewModel: viewModel
                    )
                    .padding(EdgeInsets(top: 24, leading: leadingTrailingPadding, bottom: 0, trailing: 0))
                    
                    LazyVStack(alignment: .leading, spacing: 0) {
                        
                        ForEach(viewModel.lessons) { (lesson: LessonDomainModel) in
                            
                            let cardWidth: CGFloat = geometry.size.width - (2 * leadingTrailingPadding)
                            
                            LessonCardView(viewModel: viewModel.cardViewModel(for: lesson), cardWidth: cardWidth, cardTappedClosure: {
                                
                                viewModel.lessonCardTapped(lesson: lesson)
                            })
                            .padding([.top, .bottom], 8)
                            .padding([.leading, .trailing], leadingTrailingPadding)
                        }
                    }
                    .padding([.top], 7)
                    .padding([.bottom], 27)
                }
                
            } refreshHandler: {
                viewModel.refreshData()
            }
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
            getLessonsUseCase: appDiContainer.domainLayer.getLessonsUseCase(),
            getSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getSettingsParallelLanguageUseCase(),
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            attachmentsRepository: appDiContainer.dataLayer.getAttachmentsRepository()
        )
        
        LessonsView(viewModel: viewModel, leadingTrailingPadding: 20)
    }
}
