//
//  LessonsView.swift
//  godtools
//
//  Created by Rachael Skeath on 7/12/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct LessonsView: View {
        
    private let contentHorizontalInsets: CGFloat
    private let lessonCardSpacing: CGFloat
    
    @ObservedObject private var viewModel: LessonsViewModel
    
    init(viewModel: LessonsViewModel, contentHorizontalInsets: CGFloat = DashboardView.contentHorizontalInsets, lessonCardSpacing: CGFloat = DashboardView.toolCardVerticalSpacing) {
        
        self.viewModel = viewModel
        self.contentHorizontalInsets = contentHorizontalInsets
        self.lessonCardSpacing = lessonCardSpacing
    }
    
    var body: some View {
        
        GeometryReader { geometry in
                        
            PullToRefreshScrollView(showsIndicators: true) {
                
                VStack(alignment: .leading, spacing: 0) {
                                            
                    LessonsHeaderView(
                        viewModel: viewModel
                    )
                    .padding([.top], 24)
                    .padding([.leading, .trailing], contentHorizontalInsets)
                    
                    LazyVStack(alignment: .center, spacing: lessonCardSpacing) {
                        
                        ForEach(viewModel.lessons) { (lesson: LessonDomainModel) in
                                                        
                            LessonCardView(
                                viewModel: viewModel.getLessonViewModel(lesson: lesson),
                                geometry: geometry,
                                cardTappedClosure: {
                                
                                viewModel.lessonCardTapped(lesson: lesson)
                            })
                        }
                    }
                    .padding([.top], lessonCardSpacing)
                }
                .padding([.bottom], DashboardView.scrollViewBottomSpacingToTabBar)
                
            } refreshHandler: {
                viewModel.refreshData()
            }
        }
        .onAppear {
            viewModel.pageViewed()
        }
    }
}

// MARK: - Preview

struct LessonsView_Preview: PreviewProvider {
    
    static func getLessonsViewModel() -> LessonsViewModel {
        
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
        
        return viewModel
    }
    
    static var previews: some View {
        
        LessonsView(
            viewModel: LessonsView_Preview.getLessonsViewModel(),
            contentHorizontalInsets: 20
        )
    }
}
