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
    
    // MARK: - Body
    
    var body: some View {
        let leadingTrailingPadding = ToolsMenuView.getMargin(for: width)
        
        Group {
            
            ToolSpotlightView(viewModel: viewModel.spotlightViewModel, width: width, leadingPadding: leadingTrailingPadding)
                .listRowInsets(EdgeInsets())
            
            ToolCategoriesView(viewModel: viewModel.categoriesViewModel, leadingPadding: leadingTrailingPadding)
                .listRowInsets(EdgeInsets())
            
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
            dataDownloader: appDiContainer.initialDataDownloader,
            languageSettingsService: appDiContainer.languageSettingsService,
            localizationServices: appDiContainer.localizationServices,
            favoritingToolMessageCache: appDiContainer.favoritingToolMessageCache,
            analytics: appDiContainer.analytics,
            getAllToolsUseCase: appDiContainer.domainLayer.getAllToolsUseCase(),
            getBannerImageUseCase: appDiContainer.domainLayer.getBannerImageUseCase(),
            getLanguageAvailabilityStringUseCase: appDiContainer.getLanguageAvailabilityStringUseCase(),
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            getSpotlightToolsUseCase: appDiContainer.domainLayer.getSpotlightToolsUseCase(),
            getToolCategoriesUseCase: appDiContainer.domainLayer.getToolCategoriesUseCase(),
            getToolIsFavoritedUseCase: appDiContainer.domainLayer.getToolIsFavoritedUseCase(),
            toggleToolFavoritedUseCase: appDiContainer.domainLayer.getToggleToolFavoritedUseCase()
        )
        
        GeometryReader { geo in
            VStack {
                AllToolsList(viewModel: viewModel, width: geo.size.width)
            }
        }
    }
}

