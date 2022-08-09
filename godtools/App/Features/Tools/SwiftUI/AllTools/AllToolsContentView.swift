//
//  AllToolsContentView.swift
//  godtools
//
//  Created by Rachael Skeath on 4/6/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct AllToolsContentView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: AllToolsContentViewModel
    
    // MARK: - Init
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            if viewModel.hideFavoritingToolBanner == false {
                FavoritingToolBannerView(viewModel: viewModel.getFavoritingToolBannerViewModel())
                    .transition(.move(edge: .top))
            }
            
            if viewModel.isLoading {
                
                ActivityIndicator(style: .medium, isAnimating: .constant(true))
                
            } else {
                
                GeometryReader { geo in
                    let width = geo.size.width
                    
                    BackwardCompatibleList(rootViewType: Self.self) {
                        
                        AllToolsList(viewModel: viewModel, width: width)
                        
                    } refreshHandler: {
                        viewModel.refreshTools()
                    }
                }
            }
        }
    }
}

// MARK: - Preview

struct AllToolsContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        
        let viewModel = AllToolsContentViewModel(
            flowDelegate: MockFlowDelegate(),
            dataDownloader: appDiContainer.initialDataDownloader,
            languageSettingsService: appDiContainer.languageSettingsService,
            localizationServices: appDiContainer.localizationServices,
            favoritedResourcesCache: appDiContainer.favoritedResourcesCache,
            favoritingToolMessageCache: appDiContainer.favoritingToolMessageCache,
            analytics: appDiContainer.analytics,
            getBannerImageUseCase: appDiContainer.domainLayer.getBannerImageUseCase(),
            getLanguageAvailabilityStringUseCase: appDiContainer.getLanguageAvailabilityStringUseCase(),
            getToolIsFavoritedUseCase: appDiContainer.domainLayer.getToolIsFavoritedUseCase()
        )
        
        AllToolsContentView(viewModel: viewModel)
    }
}
