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
                  
            AccessibilityScreenElementView(screenAccessibility: .dashboardFavorites)
            
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
                        
                        Text(viewModel.strings.welcomeTitle)
                            .font(FontLibrary.sfProTextRegular.font(size: 30))
                            .foregroundColor(ColorPalette.gtGrey.color)
                            .padding([.top], 24)
                            .padding([.leading], contentHorizontalInsets)
                        
                        FeaturedLessonsView(
                            viewModel: viewModel,
                            geometry: geometry,
                            contentHorizontalInsets: contentHorizontalInsets,
                            lessonTappedClosure: { (featuredLesson: FeaturedLessonDomainModel) in
                                
                                viewModel.featuredLessonTapped(featuredLesson: featuredLesson)
                            }
                        )
                        .padding([.top], 30)
                        
                        YourFavoriteToolsView(
                            viewModel: viewModel,
                            geometry: geometry,
                            contentHorizontalInsets: contentHorizontalInsets
                        )
                        .padding([.top], 45)
                    }
                    .padding([.bottom], 30)

                } refreshHandler: {
                    
                    viewModel.pullToRefresh()
                }
            }
        }//end GeometryReader
        .onAppear {
            
            viewModel.pageViewed()
        }
    }
}

// MARK: - Preview

struct FavoritesView_Preview: PreviewProvider {
    
    static func getFavoritesViewModel() -> FavoritesViewModel {
        
        let appDiContainer = AppDiContainer.createUITestsDiContainer()
        
        let viewModel = FavoritesViewModel(
            stepEmitter: PreviewFlowStepEmitter.emitter,
            resourcesRepository: appDiContainer.core.dataLayer.getResourcesRepository(),
            getFavoritesStringsUseCase: appDiContainer.feature.favorites.domainLayer.getFavoritesStringsUseCase(),
            getYourFavoritedToolsUseCase: appDiContainer.feature.favorites.domainLayer.getYourFavoritedToolsUseCase(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getToolIsFavoritedUseCase: appDiContainer.feature.favorites.domainLayer.getToolIsFavoritedUseCase(),
            getToolBannerUseCase: appDiContainer.core.domainLayer.getToolBannerUseCase(),
            dataCache: appDiContainer.core.dataLayer.getSharedDataCache(),
            disableOptInOnboardingBannerUseCase: appDiContainer.feature.tools.domainLayer.getDisableOptInOnboardingBannerUseCase(),
            getFeaturedLessonsUseCase: appDiContainer.feature.featuredLessons.domainLayer.getFeaturedLessonsUseCase(),
            getOptInOnboardingBannerEnabledUseCase: appDiContainer.feature.tools.domainLayer.getOptInOnboardingBannerEnabledUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.core.domainLayer.getTrackScreenViewAnalyticsUseCase(),
            trackActionAnalyticsUseCase: appDiContainer.core.domainLayer.getTrackActionAnalyticsUseCase()
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
