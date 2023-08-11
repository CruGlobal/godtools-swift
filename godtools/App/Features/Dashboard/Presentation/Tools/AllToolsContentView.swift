//
//  AllToolsContentView.swift
//  godtools
//
//  Created by Rachael Skeath on 4/6/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct AllToolsContentView: View {
        
    private let leadingTrailingPadding: CGFloat
        
    @ObservedObject private var viewModel: AllToolsContentViewModel
    
    init(viewModel: AllToolsContentViewModel, leadingTrailingPadding: CGFloat) {
        
        self.viewModel = viewModel
        self.leadingTrailingPadding = leadingTrailingPadding
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.hideFavoritingToolBanner == false {
                FavoritingToolBannerView(viewModel: viewModel.getFavoritingToolBannerViewModel())
                    .transition(.move(edge: .top))
            }
            
            if viewModel.isLoading {
                
                ActivityIndicator(style: .medium, isAnimating: .constant(true))
                
            } else {
                
                GeometryReader { geo in
                    let width = geo.size.width
                    
                    PullToRefreshList(rootViewType: Self.self) {
                        
                        AllToolsList(viewModel: viewModel, width: width, leadingTrailingPadding: leadingTrailingPadding)
                        
                    } refreshHandler: {
                        viewModel.refreshTools()
                    }
                    .animation(.default, value: viewModel.toolCardsViewModel.tools)

                }
            }
        }
        .onAppear {
            viewModel.pageViewed()
        }
    }
}

// MARK: - Preview

struct AllToolsContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        
        let viewModel = AllToolsContentViewModel(
            flowDelegate: MockFlowDelegate(),
            dataDownloader: appDiContainer.dataLayer.getInitialDataDownloader(),
            localizationServices: appDiContainer.dataLayer.getLocalizationServices(),
            favoritingToolMessageCache: appDiContainer.dataLayer.getFavoritingToolMessageCache(),
            analytics: appDiContainer.dataLayer.getAnalytics(),
            getAllToolsUseCase: appDiContainer.domainLayer.getAllToolsUseCase(),
            getBannerImageUseCase: appDiContainer.domainLayer.getBannerImageUseCase(),
            getLanguageAvailabilityUseCase: appDiContainer.domainLayer.getLanguageAvailabilityUseCase(),
            getSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getSettingsParallelLanguageUseCase(),
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            getSpotlightToolsUseCase: appDiContainer.domainLayer.getSpotlightToolsUseCase(),
            getToolCategoriesUseCase: appDiContainer.domainLayer.getToolCategoriesUseCase(),
            getToolIsFavoritedUseCase: appDiContainer.domainLayer.getToolIsFavoritedUseCase(),
            toggleToolFavoritedUseCase: appDiContainer.domainLayer.getToggleToolFavoritedUseCase()
        )
        
        AllToolsContentView(viewModel: viewModel, leadingTrailingPadding: 20)
    }
}
