//
//  FavoritesView.swift
//  godtools
//
//  Created by Rachael Skeath on 6/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct FavoritesView: View {
        
    private let contentHorizontalInsets: CGFloat
    
    @ObservedObject private var viewModel: FavoritesViewModel
    
    init(viewModel: FavoritesViewModel, contentHorizontalInsets: CGFloat = DashboardView.contentHorizontalInsets) {
        
        self.viewModel = viewModel
        self.contentHorizontalInsets = contentHorizontalInsets
    }
    
    var body: some View {
        
        GeometryReader { geometry in
                  
            VStack(alignment: .leading, spacing: 0) {
                
                if viewModel.showsOpenTutorialBanner {
                    
                    OpenTutorialBannerView(
                        viewModel: viewModel,
                        closeTappedClosure: {
                            
                            viewModel.closeOpenTutorialBannerTapped()
                        },
                        openTutorialTappedClosure: {
                            
                            viewModel.openTutorialBannerTapped()
                        }
                    )
                }
                
                PullToRefreshScrollView(showsIndicators: true) {
                    
                    VStack(alignment: .leading, spacing: 0) {
                        
                        Text(viewModel.welcomeTitle)
                            .font(FontLibrary.sfProTextRegular.font(size: 30))
                            .foregroundColor(ColorPalette.gtGrey.color)
                            .padding([.top], 24)
                            .padding([.leading], contentHorizontalInsets)
                        
                        FeaturedLessonView(
                            viewModel: viewModel,
                            geometry: geometry,
                            contentHorizontalInsets: contentHorizontalInsets,
                            lessonTappedClosure: { (lesson: LessonDomainModel) in
                            
                            viewModel.featuredLessonTapped(lesson: lesson)
                        })
                        .padding([.top], 30)
                        
                        YourFavoriteToolsView(
                            viewModel: viewModel,
                            geometry: geometry,
                            contentHorizontalInsets: contentHorizontalInsets
                        )
                        .padding([.top], 45)
                    }
                    .padding([.bottom], DashboardView.scrollViewBottomSpacingToTabBar)

                } refreshHandler: {
                    
                    viewModel.pullToRefresh()
                }
            }
        }
        .onAppear {
            
            viewModel.pageViewed()
        }
    }
}

// MARK: - Preview

struct FavoritesView_Preview: PreviewProvider {
    
    static func getFavoritesViewModel() -> FavoritesViewModel {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        
        let viewModel = FavoritesViewModel(
            flowDelegate: MockFlowDelegate(),
            dataDownloader: appDiContainer.dataLayer.getInitialDataDownloader(),
            localizationServices: appDiContainer.dataLayer.getLocalizationServices(),
            analytics: appDiContainer.dataLayer.getAnalytics(),
            attachmentsRepository: appDiContainer.dataLayer.getAttachmentsRepository(),
            disableOptInOnboardingBannerUseCase: appDiContainer.getDisableOptInOnboardingBannerUseCase(),
            getAllFavoritedToolsUseCase: appDiContainer.domainLayer.getAllFavoritedToolsUseCase(),
            getFeaturedLessonsUseCase: appDiContainer.domainLayer.getFeaturedLessonsUseCase(),
            getLanguageAvailabilityUseCase: appDiContainer.domainLayer.getLanguageAvailabilityUseCase(),
            getOptInOnboardingBannerEnabledUseCase: appDiContainer.getOpInOnboardingBannerEnabledUseCase(),
            getSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getSettingsParallelLanguageUseCase(),
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            getToolIsFavoritedUseCase: appDiContainer.domainLayer.getToolIsFavoritedUseCase(),
            removeToolFromFavoritesUseCase: appDiContainer.domainLayer.getRemoveToolFromFavoritesUseCase()
        )
        
        return viewModel
    }
    
    static var previews: some View {
        
        FavoritesView(
            viewModel: FavoritesView_Preview.getFavoritesViewModel(),
            contentHorizontalInsets: 20
        )
    }
}