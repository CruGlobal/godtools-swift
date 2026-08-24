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

    init(
        viewModel: LessonsViewModel,
        contentHorizontalInsets: CGFloat = DashboardView.contentHorizontalInsets,
        lessonCardSpacing: CGFloat = DashboardView.toolCardVerticalSpacing
    ) {
        
        self.viewModel = viewModel
        self.contentHorizontalInsets = contentHorizontalInsets
        self.lessonCardSpacing = lessonCardSpacing
    }
    
    var body: some View {
        
        GeometryReader { geometry in
                    
            AccessibilityScreenElementView(screenAccessibility: .dashboardLessons)
            
            VStack(alignment: .center, spacing: 0) {

                if GodToolsApp.showsPersonalization {
                    
                    PersonalizedToolToggle(
                        geometry: geometry,
                        selectedToggle: $viewModel.selectedToggle,
                        toggleOptions: viewModel.toggleOptions
                    )
                    .padding([.top], ToolsView.personalizedToggleTopPadding)
                }

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
                            Text(viewModel.strings.languageFilterTitle)
                                .font(FontLibrary.sfProTextBold.font(size: 18))
                                .foregroundColor(ColorPalette.gtGrey.color)

                            FixedHorizontalSpacer(width: 30)

                            ToolFilterButtonView(
                                title: viewModel.languageFilterButtonTitle,
                                accessibility: .lessonsLanguageFilter
                            ) {
                                viewModel.lessonLanguageFilterTapped()
                            }
                        }
                        .padding(.bottom, 15)
                        .padding(.horizontal, contentHorizontalInsets)
                        
                        if viewModel.selectedToggle == .personalized, let personalizedLessonsUnavailable = viewModel.personalizedLessons.unavailableStrings {
                            
                            PersonalizationUnavailableView(
                                title: personalizedLessonsUnavailable.title,
                                message: personalizedLessonsUnavailable.message,
                                changeSettingsButtonTitle: viewModel.strings.changeLocalizationSettingsAction,
                                goToAllToolsButtonTitle: viewModel.strings.viewAllLessonsAction,
                                changeLocalizationSettingsTapped: {
                                    viewModel.changeLocalizationSettingsTapped()
                                },
                                goToAllToolsTapped: {
                                    viewModel.goToAllLessonsTapped()
                                }
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, contentHorizontalInsets)
                        }
                        else if !viewModel.lessonsList.isEmpty {
                            
                            LazyVStack(alignment: .center, spacing: lessonCardSpacing) {

                                ForEach(viewModel.lessonsList) { (lessonListItem: LessonListItemDomainModel) in

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
                        }

                        if viewModel.selectedToggle == .personalized && viewModel.personalizedLessons.unavailableStrings == nil {
                            
                            PersonalizedChangeLocalizationView(
                                geometry: geometry,
                                title: viewModel.strings.personalizedLessonExplanationTitle,
                                subtitle: viewModel.strings.personalizedLessonExplanationSubtitle,
                                changeLocalizationSettingsAction: viewModel.strings.changeLocalizationSettingsAction,
                                changeLocalizationSettingsTapped: {
                                    viewModel.changeLocalizationSettingsTapped()
                                }
                            )
                            .padding(.top, lessonCardSpacing * 2)
                        }
                    }
                    .padding([.bottom], 0)

                } refreshHandler: {
                    viewModel.pullToRefresh()
                }
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
            stepEmitter: PreviewFlowStepEmitter.emitter,
            pullToRefreshLessonsUseCase: appDiContainer.feature.lessons.domainLayer.getPullToRefreshLessonsUseCase(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getLocalizationSettingsUseCase: appDiContainer.feature.personalizedTools.domainLayer.getLocalizationSettingsUseCase(),
            getPersonalizedLessonsUseCase: appDiContainer.feature.personalizedTools.domainLayer.getPersonalizedLessonsUseCase(),
            getLessonsStringsUseCase: appDiContainer.feature.lessons.domainLayer.getLessonsStringsUseCase(),
            getAllLessonsUseCase: appDiContainer.feature.lessons.domainLayer.getAllLessonsUseCase(),
            getUserLessonFiltersUseCase: appDiContainer.feature.lessonFilter.domainLayer.getUserLessonFiltersUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.core.domainLayer.getTrackScreenViewAnalyticsUseCase(),
            trackActionAnalyticsUseCase: appDiContainer.core.domainLayer.getTrackActionAnalyticsUseCase(),
            getToolBannerUseCase: appDiContainer.core.domainLayer.getToolBannerUseCase(),
            imageCache: appDiContainer.core.dataLayer.getSharedImageCache()
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
