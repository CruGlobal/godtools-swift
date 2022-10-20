//
//  DashboardView.swift
//  godtools
//
//  Created by Rachael Skeath on 10/6/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct DashboardView: View {
    
    @ObservedObject var viewModel: DashboardViewModel
    @State var selectedTab: DashboardTabType
    
    init(viewModel: DashboardViewModel, startingTab: DashboardTabType) {
        self.viewModel = viewModel
        self.selectedTab = startingTab
        
        UITabBar.appearance().barTintColor = .white
        UITabBar.appearance().unselectedItemTintColor = UIColor(red: 170 / 255, green: 170 / 255, blue: 170 / 255, alpha: 1)
        UITabBarItem.appearance().setTitleTextAttributes([.font: FontLibrary.sfProTextRegular.uiFont(size: 12) as Any], for: .normal)
        
        viewModel.tabChanged(to: startingTab)
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            LessonsView(viewModel: viewModel.lessonsViewModel)
                .tabItem {
                    Label("Lessons", image: ImageCatalog.toolsMenuLessons.name)
                }
                .tag(DashboardTabType.lessons)
                
            
            FavoritesContentView(viewModel: viewModel.favoritesViewModel)
                .tabItem {
                    Label("Favorites", image: ImageCatalog.toolsMenuFavorites.name)
                }
                .tag(DashboardTabType.favorites)
            
            AllToolsContentView(viewModel: viewModel.allToolsViewModel)
                .tabItem {
                    Label("All Tools", image: ImageCatalog.toolsMenuAllTools.name)
                }
                .tag(DashboardTabType.allTools)
        }
        .accentColor(ColorPalette.gtBlue.color)
        .onChange(of: selectedTab) { newValue in
            
            viewModel.tabChanged(to: newValue)
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        
        let viewModel = DashboardViewModel(
            flowDelegate: MockFlowDelegate(),
            initialDataDownloader: appDiContainer.initialDataDownloader,
            languageSettingsService: appDiContainer.languageSettingsService,
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
            getSpotlightToolsUseCase: appDiContainer.domainLayer.getSpotlightToolsUseCase(),
            getToolCategoriesUseCase: appDiContainer.domainLayer.getToolCategoriesUseCase(),
            getToolIsFavoritedUseCase: appDiContainer.domainLayer.getToolIsFavoritedUseCase(),
            removeToolFromFavoritesUseCase: appDiContainer.domainLayer.getRemoveToolFromFavoritesUseCase(),
            toggleToolFavoritedUseCase: appDiContainer.domainLayer.getToggleToolFavoritedUseCase(),
            fontService: appDiContainer.getFontService()
        )
        
        DashboardView(viewModel: viewModel, startingTab: .favorites)
    }
}
