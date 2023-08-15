//
//  FavoriteToolsView.swift
//  godtools
//
//  Created by Rachael Skeath on 6/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct FavoriteToolsView: View {
        
    private let width: CGFloat
    private let leadingPadding: CGFloat
    
    @ObservedObject private var viewModel: FavoriteToolsViewModel
        
    init(viewModel: FavoriteToolsViewModel, width: CGFloat, leadingPadding: CGFloat) {
        
        self.viewModel = viewModel
        self.width = width
        self.leadingPadding = leadingPadding
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 15) {
            
            FavoriteToolsHeaderView(viewModel: viewModel, leadingPadding: leadingPadding)
            
            switch viewModel.viewState {
            
            case .loading:
                
                EmptyView()
                
            case .noTools:
                
                NoFavoriteToolsView(viewModel: viewModel)
                    .padding([.leading, .trailing], leadingPadding)
                
            case .tools:
                
                ToolCardsCarouselView(viewModel: viewModel, cardType: .squareWithNavButtons, width: width, leadingTrailingPadding: leadingPadding)
                
            }
        }
    }
}

struct FavoriteToolsView_Previews: PreviewProvider {
    static var previews: some View {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()

        let viewModel = FavoriteToolsViewModel(
            dataDownloader: appDiContainer.dataLayer.getInitialDataDownloader(),
            localizationServices: appDiContainer.dataLayer.getLocalizationServices(),
            getAllFavoritedToolsUseCase: appDiContainer.domainLayer.getAllFavoritedToolsUseCase(),
            getBannerImageUseCase: appDiContainer.domainLayer.getBannerImageUseCase(),
            getLanguageAvailabilityUseCase: appDiContainer.domainLayer.getLanguageAvailabilityUseCase(),
            getSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getSettingsParallelLanguageUseCase(),
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            getToolIsFavoritedUseCase: appDiContainer.domainLayer.getToolIsFavoritedUseCase(),
            delegate: nil
        )
        
        FavoriteToolsView(viewModel: viewModel, width: 375, leadingPadding: 20)
    }
}
