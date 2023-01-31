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
        
        // Note: In iOS 16+, the preferred way to hide the tab bar is through the view modifier `.toolbar(.hidden, for: .tabBar)`, but there seems to be a bug where it only hides on the tab's first appearance.  May want to reinvestigate this in future versions.
        UITabBar.appearance(whenContainedInInstancesOf: [UIHostingController<DashboardView>.self]).isHidden = true
    }
    
    var body: some View {
        GeometryReader { geo in
            
            let leadingTrailingPadding = DashboardView.getMargin(for: geo.size.width)
            
            VStack(spacing: 0) {

                tabView(padding: leadingTrailingPadding)

                DashboardTabBarView(viewModel: viewModel)
            }
        }
    }
    
    @ViewBuilder private func tabView(padding: CGFloat) -> some View {
        
        TabView(selection: $viewModel.selectedTab) {
            makeTabs(padding: padding)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.easeInOut)
        .transition(.slide)
    }
    
    @ViewBuilder private func makeTabs(padding: CGFloat) -> some View {
        
        Group {
            LessonsView(viewModel: viewModel.lessonsViewModel, leadingTrailingPadding: padding)
                .tag(DashboardTabTypeDomainModel.lessons)
            
            FavoritesContentView(viewModel: viewModel.favoritesViewModel, leadingTrailingPadding: padding)
                .tag(DashboardTabTypeDomainModel.favorites)
            
            AllToolsContentView(viewModel: viewModel.allToolsViewModel, leadingTrailingPadding: padding)
                .tag(DashboardTabTypeDomainModel.allTools)
        }
    }
}

// MARK: - Inputs
    
extension DashboardView {
    
    static func getMargin(for width: CGFloat) -> CGFloat {
        return marginMultiplier * width
    }
    
    func navigateToTab(_ tab: DashboardTabTypeDomainModel) {
        viewModel.selectedTab = tab
    }
}

// MARK: - Preview

struct DashboardView_Previews: PreviewProvider {
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
        
        DashboardView(viewModel: viewModel)
    }
}
