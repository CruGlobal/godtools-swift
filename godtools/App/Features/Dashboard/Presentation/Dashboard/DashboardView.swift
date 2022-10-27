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
    
    private static let marginMultiplier: CGFloat = 15/375
    
    init(viewModel: DashboardViewModel) {
        self.viewModel = viewModel
        
        // TODO: - find a better way to hide the default tab bar
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        GeometryReader { geo in
            
            let leadingTrailingPadding = DashboardView.getMargin(for: geo.size.width)
            ZStack(alignment: .bottom) {
                
                TabView(selection: $viewModel.selectedTab) {
                    
                    LessonsView(viewModel: viewModel.lessonsViewModel, leadingTrailingPadding: leadingTrailingPadding)
                        .tag(DashboardTabTypeDomainModel.lessons)
                    
                    
                    FavoritesContentView(viewModel: viewModel.favoritesViewModel, leadingTrailingPadding: leadingTrailingPadding)
                        .tag(DashboardTabTypeDomainModel.favorites)
                    
                    AllToolsContentView(viewModel: viewModel.allToolsViewModel, leadingTrailingPadding: leadingTrailingPadding)
                        .tag(DashboardTabTypeDomainModel.allTools)
                }
                .accentColor(ColorPalette.gtBlue.color)
                
                HStack {
                    DashboardTabItem(title: "Lessons", imageName: ImageCatalog.toolsMenuLessons.name, isSelected: viewModel.selectedTab == .lessons)
                        .onTapGesture {
                            viewModel.selectedTab = DashboardTabTypeDomainModel.lessons
                        }
                    
                    DashboardTabItem(title: "Favorites", imageName: ImageCatalog.toolsMenuFavorites.name, isSelected: viewModel.selectedTab == .favorites)
                        .onTapGesture {
                            viewModel.selectedTab = DashboardTabTypeDomainModel.favorites
                        }
                    
                    DashboardTabItem(title: "All Tools", imageName: ImageCatalog.toolsMenuAllTools.name, isSelected: viewModel.selectedTab == .allTools)
                        .onTapGesture {
                            viewModel.selectedTab = DashboardTabTypeDomainModel.allTools
                        }
                }
            }
        }
    }
    
    static func getMargin(for width: CGFloat) -> CGFloat {
        return marginMultiplier * width
    }
    
    func navigateToTab(_ tab: DashboardTabTypeDomainModel) {
        viewModel.selectedTab = tab
    }
}

struct DashboardView_Previews: PreviewProvider {
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
        
        DashboardView(viewModel: viewModel)
    }
}
