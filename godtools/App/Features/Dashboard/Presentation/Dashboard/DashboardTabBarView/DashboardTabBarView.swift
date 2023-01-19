//
//  DashboardTabBarView.swift
//  godtools
//
//  Created by Rachael Skeath on 10/27/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct DashboardTabBarView: View {
    
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        
        ZStack {
            HStack {
                                
                DashboardTabItem(tabType: .lessons, title: viewModel.lessonsTabTitle, imageName: ImageCatalog.toolsMenuLessons.name, selectedTab: $viewModel.selectedTab)
                    .frame(maxWidth: .infinity)
                
                DashboardTabItem(tabType: .favorites, title: viewModel.favoritesTabTitle, imageName: ImageCatalog.toolsMenuFavorites.name, selectedTab: $viewModel.selectedTab)
                    .frame(maxWidth: .infinity)
                                
                DashboardTabItem(tabType: .allTools, title: viewModel.allToolsTabTitle, imageName: ImageCatalog.toolsMenuAllTools.name, selectedTab: $viewModel.selectedTab)
                    .frame(maxWidth: .infinity)
                
            }
            .padding(.top, 16)
            .padding(.bottom, 8)
            .padding([.leading, .trailing], 8)
            .frame(maxWidth: .infinity)
            .background(
                Color.white
                    .edgesIgnoringSafeArea(.bottom)
                    .shadow(color: .black.opacity(0.35), radius: 4, y: 0)
            )
        }
    }
    
    @ViewBuilder private func doubleSpacer() -> some View {
        Group {
            Spacer()
            Spacer()
        }
    }
    
    @ViewBuilder private func tripleSpacer() -> some View {
        Group {
            Spacer()
            Spacer()
            Spacer()
        }
    }
}

struct DashboardTabBarView_Previews: PreviewProvider {
    static var previews: some View {
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        
        let viewModel = DashboardViewModel(
            startingTab: .favorites,
            flowDelegate: MockFlowDelegate(),
            initialDataDownloader: appDiContainer.dataLayer.getInitialDataDownloader(),
            translationsRepository: appDiContainer.dataLayer.getTranslationsRepository(),
            localizationServices: appDiContainer.localizationServices,
            favoritingToolMessageCache: appDiContainer.dataLayer.getFavoritingToolMessageCache(),
            analytics: appDiContainer.dataLayer.getAnalytics(),
            disableOptInOnboardingBannerUseCase: appDiContainer.getDisableOptInOnboardingBannerUseCase(),
            getAllFavoritedToolsUseCase: appDiContainer.domainLayer.getAllFavoritedToolsUseCase(),
            getAllToolsUseCase: appDiContainer.domainLayer.getAllToolsUseCase(),
            getBannerImageUseCase: appDiContainer.domainLayer.getBannerImageUseCase(),
            getFeaturedLessonsUseCase: appDiContainer.domainLayer.getFeaturedLessonsUseCase(),
            getLanguageAvailabilityUseCase: appDiContainer.domainLayer.getLanguageAvailabilityUseCase(),
            getLessonsUseCase: appDiContainer.domainLayer.getLessonsUseCase(),
            getOptInOnboardingBannerEnabledUseCase: appDiContainer.getOpInOnboardingBannerEnabledUseCase(),
            getSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getSettingsParallelLanguageUseCase(),
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            getShouldShowLanguageSettingsBarButtonUseCase: appDiContainer.domainLayer.getShouldShowLanguageSettingsBarButtonUseCase(),
            getSpotlightToolsUseCase: appDiContainer.domainLayer.getSpotlightToolsUseCase(),
            getToolCategoriesUseCase: appDiContainer.domainLayer.getToolCategoriesUseCase(),
            getToolIsFavoritedUseCase: appDiContainer.domainLayer.getToolIsFavoritedUseCase(),
            removeToolFromFavoritesUseCase: appDiContainer.domainLayer.getRemoveToolFromFavoritesUseCase(),
            toggleToolFavoritedUseCase: appDiContainer.domainLayer.getToggleToolFavoritedUseCase()
        )
        
        DashboardTabBarView(viewModel: viewModel)
    }
}
