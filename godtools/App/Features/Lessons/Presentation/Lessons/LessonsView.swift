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
                    
            AccessibilityScreenElementView(screenAccessibility: .dashboardLessons)
            
            if viewModel.isLoadingLessons {
                CenteredCircularProgressView(
                    progressColor: ColorPalette.gtGrey.color
                )
            }
            
            PullToRefreshScrollView(showsIndicators: true) {
                
                VStack(alignment: .leading, spacing: 0) {
                                            
                    LessonsHeaderView(
                        viewModel: viewModel
                    )
                    .padding([.top], 24)
                    .padding([.leading, .trailing], contentHorizontalInsets + 5)
                    
                    HStack(spacing: 0) {
                        Text("Lessons in:")
                            .font(FontLibrary.sfProTextBold.font(size: 18))
                            .foregroundColor(ColorPalette.gtGrey.color)
                        
                        FixedHorizontalSpacer(width: 30)
                        
                        ToolFilterButtonView(title: "Language") {
                            print("yes")
                        }
                    }
                    .padding([.top, .bottom], 20)
                    .padding([.leading, .trailing], contentHorizontalInsets)
                    
                    LazyVStack(alignment: .center, spacing: lessonCardSpacing) {
                        
                        ForEach(viewModel.lessons) { (lessonListItem: LessonListItemDomainModel) in
                                                        
                            LessonCardView(
                                viewModel: viewModel.getLessonViewModel(lessonListItem: lessonListItem),
                                geometry: geometry,
                                cardTappedClosure: {
                                
                                viewModel.lessonCardTapped(lessonListItem: lessonListItem)
                            })
                        }
                    }
                    .padding([.top], lessonCardSpacing)
                }
                .padding([.bottom], DashboardView.scrollViewBottomSpacingToTabBar)
                
            } refreshHandler: {
                viewModel.refreshData()
            }
            .opacity(viewModel.isLoadingLessons ? 0 : 1)
            .animation(.easeOut, value: !viewModel.isLoadingLessons)
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
            resourcesRepository: appDiContainer.dataLayer.getResourcesRepository(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            viewLessonsUseCase: appDiContainer.feature.lessons.domainLayer.getViewLessonsUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.domainLayer.getTrackScreenViewAnalyticsUseCase(),
            trackActionAnalyticsUseCase: appDiContainer.domainLayer.getTrackActionAnalyticsUseCase(),
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
