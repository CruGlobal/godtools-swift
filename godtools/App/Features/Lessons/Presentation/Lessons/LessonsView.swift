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

            VStack(alignment: .center, spacing: 0) {

                PersonalizedToolToggle(
                    selectedToggle: $viewModel.selectedToggle,
                    toggleOptions: viewModel.toggleOptions
                )
                .padding([.top], ToolsView.personalizedToggleTopPadding)

                PullToRefreshScrollView(showsIndicators: true) {

                    VStack(alignment: .leading, spacing: 0) {

                        LessonsHeaderView(
                            viewModel: viewModel
                        )
                        .padding([.top], 24)
                        .padding(.horizontal, contentHorizontalInsets)

                        SeparatorView()
                            .padding(.vertical, 15)
                            .padding(.horizontal, contentHorizontalInsets)

                        HStack(spacing: 0) {
                            Text(viewModel.languageFilterTitle)
                                .font(FontLibrary.sfProTextBold.font(size: 18))
                                .foregroundColor(ColorPalette.gtGrey.color)

                            FixedHorizontalSpacer(width: 30)

                            ToolFilterButtonView(title: viewModel.languageFilterButtonTitle, accessibility: .lessonsLanguageFilter) {
                                viewModel.lessonLanguageFilterTapped()
                            }
                        }
                        .padding(.bottom, 15)
                        .padding(.horizontal, contentHorizontalInsets)

                        LazyVStack(alignment: .center, spacing: lessonCardSpacing) {

                            ForEach(viewModel.lessons) { (lessonListItem: LessonListItemDomainModel) in

                                LessonCardView(
                                    viewModel: viewModel.getLessonViewModel(lessonListItem: lessonListItem),
                                    geometry: geometry,
                                    cardTappedClosure: {

                                        viewModel.lessonCardTapped(lessonListItem: lessonListItem)
                                    }
                                )
                            }
                        }
                        .padding([.top], lessonCardSpacing)

                        if viewModel.selectedToggle == .personalized {
                            PersonalizedToolFooterView(
                                title: viewModel.strings.personalizedLessonExplanationTitle,
                                subtitle: viewModel.strings.personalizedLessonExplanationSubtitle,
                                buttonTitle: viewModel.strings.changePersonalizedLessonSettingsActionLabel,
                                buttonAction: {
                                    viewModel.localizationSettingsTapped()
                                }
                            )
                            .padding(.top, lessonCardSpacing * 2)
                        }
                    }
                    .padding([.bottom], 0)

                } refreshHandler: {
                    viewModel.pullToRefresh()
                }
                .opacity(viewModel.isLoadingLessons ? 0 : 1)
                .animation(.easeOut, value: !viewModel.isLoadingLessons)
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.75), value: viewModel.selectedToggle)
            .onAppear {
                viewModel.pageViewed()
            }
        }

    }
}

// MARK: - Preview

struct LessonsView_Preview: PreviewProvider {
    
    static func getLessonsViewModel() -> LessonsViewModel {
        
        let appDiContainer = AppDiContainer.createUITestsDiContainer()
        
        let viewModel = LessonsViewModel(
            flowDelegate: MockFlowDelegate(),
            resourcesRepository: appDiContainer.dataLayer.getResourcesRepository(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(), 
            getUserLessonFiltersUseCase: appDiContainer.feature.lessonFilter.domainLayer.getUserLessonFiltersUseCase(),
            viewLessonsUseCase: appDiContainer.feature.lessons.domainLayer.getViewLessonsUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.domainLayer.getTrackScreenViewAnalyticsUseCase(),
            trackActionAnalyticsUseCase: appDiContainer.domainLayer.getTrackActionAnalyticsUseCase(),
            getToolBannerUseCase: appDiContainer.domainLayer.getToolBannerUseCase()
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
