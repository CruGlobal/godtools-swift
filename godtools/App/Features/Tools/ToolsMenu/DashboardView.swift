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
    
    init(viewModel: DashboardViewModel) {
        self.viewModel = viewModel
        
        UITabBar.appearance().unselectedItemTintColor = ColorPalette.gtGrey.uiColor
        UITabBarItem.appearance().setTitleTextAttributes([.font: FontLibrary.sfProTextRegular.uiFont(size: 16) as Any], for: .normal)
    }
    
    var body: some View {
        TabView {
            
            LessonsView(viewModel: viewModel.lessonsViewModel)
                .tabItem {
                    makeTabItemView(tabName: "Lessons", imageName: ImageCatalog.toolsMenuLessons.name)
                }
                
            
            FavoritesContentView(viewModel: viewModel.favoritesViewModel)
                .tabItem {
                    makeTabItemView(tabName: "Favorites", imageName: ImageCatalog.toolsMenuFavorites.name)
                }
            
            AllToolsContentView(viewModel: viewModel.allToolsViewModel)
                .tabItem {
                    makeTabItemView(tabName: "All Tools", imageName: ImageCatalog.toolsMenuAllTools.name)
                }
            
        }
        .accentColor(ColorPalette.gtBlue.color)
    }
    
    @ViewBuilder func makeTabItemView(tabName: String, imageName: String) -> some View {
        
        if #available(iOS 14.0, *) {

            Label(tabName, image: imageName)

        } else {
            // TODO: - make sure this works
            VStack {
                Image(imageName)
                Text(tabName)
                    .font(FontLibrary.sfProTextRegular.font(size: 16))
            }
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
        
        DashboardView(viewModel: viewModel)
    }
}
