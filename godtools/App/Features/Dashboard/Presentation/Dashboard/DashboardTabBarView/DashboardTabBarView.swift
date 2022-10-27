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
                
                doubleSpacer()
                
                DashboardTabItem(title: "Lessons", imageName: ImageCatalog.toolsMenuLessons.name, isSelected: viewModel.selectedTab == .lessons)
                    .onTapGesture {
                        viewModel.selectedTab = DashboardTabTypeDomainModel.lessons
                    }
                
                tripleSpacer()
                
                DashboardTabItem(title: "Favorites", imageName: ImageCatalog.toolsMenuFavorites.name, isSelected: viewModel.selectedTab == .favorites)
                    .onTapGesture {
                        viewModel.selectedTab = DashboardTabTypeDomainModel.favorites
                    }
                
                tripleSpacer()
                
                DashboardTabItem(title: "All Tools", imageName: ImageCatalog.toolsMenuAllTools.name, isSelected: viewModel.selectedTab == .allTools)
                    .onTapGesture {
                        viewModel.selectedTab = DashboardTabTypeDomainModel.allTools
                    }
                
                doubleSpacer()
            }
            .padding(.top, 16)
            .padding(.bottom, 8)
            .frame(maxWidth: .infinity)
            .background(
                Color.white
                    .edgesIgnoringSafeArea(.bottom)
                    .shadow(color: .black.opacity(0.35), radius: 4, y: 0)
            )
        }
    }
    
    @ViewBuilder func doubleSpacer() -> some View {
        Group {
            Spacer()
            Spacer()
        }
    }
    
    @ViewBuilder func tripleSpacer() -> some View {
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
            initialDataDownloader: appDiContainer.initialDataDownloader,
            translationsRepository: appDiContainer.dataLayer.getTranslationsRepository(),
            localizationServices: appDiContainer.localizationServices,
            favoritingToolMessageCache: appDiContainer.dataLayer.getFavoritingToolMessageCache(),
            analytics: appDiContainer.analytics,
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
