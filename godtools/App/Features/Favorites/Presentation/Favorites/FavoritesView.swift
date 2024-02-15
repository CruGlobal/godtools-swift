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
            
            if viewModel.isLoadingYourFavoritedTools {
                CenteredCircularProgressView(
                    progressColor: ColorPalette.gtGrey.color
                )
            }
            
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
                        
                        FeaturedLessonsView(
                            viewModel: viewModel,
                            geometry: geometry,
                            contentHorizontalInsets: contentHorizontalInsets,
                            lessonTappedClosure: { (featuredLesson: FeaturedLessonDomainModel) in
                            
                            viewModel.featuredLessonTapped(featuredLesson: featuredLesson)
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
                .opacity(viewModel.isLoadingYourFavoritedTools ? 0 : 1)
                .animation(.easeOut, value: !viewModel.isLoadingYourFavoritedTools)
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
            resourcesRepository: appDiContainer.dataLayer.getResourcesRepository(),
            viewFavoritesUseCase: appDiContainer.feature.favorites.domainLayer.getViewFavoritesUseCase(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            attachmentsRepository: appDiContainer.dataLayer.getAttachmentsRepository(),
            disableOptInOnboardingBannerUseCase: appDiContainer.domainLayer.getDisableOptInOnboardingBannerUseCase(),
            getFeaturedLessonsUseCase: appDiContainer.feature.featuredLessons.domainLayer.getFeaturedLessonsUseCase(),
            getLanguageAvailabilityUseCase: appDiContainer.domainLayer.getLanguageAvailabilityUseCase(),
            getOptInOnboardingBannerEnabledUseCase: appDiContainer.domainLayer.getOptInOnboardingBannerEnabledUseCase(),
            getToolIsFavoritedUseCase: appDiContainer.domainLayer.getToolIsFavoritedUseCase(),
            getInterfaceStringInAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getInterfaceStringInAppLanguageUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.domainLayer.getTrackScreenViewAnalyticsUseCase(),
            trackActionAnalyticsUseCase: appDiContainer.domainLayer.getTrackActionAnalyticsUseCase()
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
