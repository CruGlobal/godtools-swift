//
//  AllToolsList.swift
//  godtools
//
//  Created by Rachael Skeath on 4/19/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct AllToolsList: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: AllToolsContentViewModel
    let width: CGFloat
    let leadingTrailingPadding: CGFloat
    
    // MARK: - Body
    
    var body: some View {
        
        Group {
            
            ToolSpotlightView(viewModel: viewModel.spotlightViewModel, width: width, leadingPadding: leadingTrailingPadding)
                .listRowInsets(EdgeInsets())
            
            ToolCategoriesView(viewModel: viewModel.categoriesViewModel, leadingPadding: leadingTrailingPadding)
                .listRowInsets(EdgeInsets())
                .animation(.default, value: viewModel.categoriesViewModel.selectedCategoryId)
            
            SeparatorView()
                .listRowInsets(EdgeInsets())
                .padding([.leading, .trailing], leadingTrailingPadding)
            
            
            ToolCardsView(viewModel: viewModel.toolCardsViewModel, cardType: .standard, width: width, leadingPadding: leadingTrailingPadding)
            
            Spacer(minLength: 20)
        }
        
    }
}

// MARK: - Preview

struct AllToolsList_Previews: PreviewProvider {
    static var previews: some View {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        
        let viewModel = AllToolsContentViewModel(
            flowDelegate: MockFlowDelegate(),
            dataDownloader: appDiContainer.dataLayer.getInitialDataDownloader(),
            localizationServices: appDiContainer.localizationServices,
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
        
        GeometryReader { geo in
            VStack {
                AllToolsList(viewModel: viewModel, width: geo.size.width, leadingTrailingPadding: 20)
            }
        }
    }
}

