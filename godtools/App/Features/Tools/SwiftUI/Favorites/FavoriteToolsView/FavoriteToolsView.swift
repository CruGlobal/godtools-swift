//
//  FavoriteToolsView.swift
//  godtools
//
//  Created by Rachael Skeath on 6/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct FavoriteToolsView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: FavoriteToolsViewModel
    let width: CGFloat
    let leadingPadding: CGFloat
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            
            FavoriteToolsHeaderView(viewModel: viewModel, leadingPadding: leadingPadding)
            
            if viewModel.tools.isEmpty {
                
                NoFavoriteToolsView(viewModel: viewModel)
                    .padding([.leading, .trailing], leadingPadding)
                
            } else {
                
                ToolCardsCarouselView(viewModel: viewModel, cardType: .squareWithNavButtons, width: width, leadingTrailingPadding: leadingPadding)
            }
        }
    }
}

struct FavoriteToolsView_Previews: PreviewProvider {
    static var previews: some View {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()

        let viewModel = FavoriteToolsViewModel(
            dataDownloader: appDiContainer.initialDataDownloader,
            deviceAttachmentBanners: appDiContainer.deviceAttachmentBanners,
            favoritedResourcesCache: appDiContainer.favoritedResourcesCache,
            languageSettingsService: appDiContainer.languageSettingsService,
            localizationServices: appDiContainer.localizationServices,
            getLanguageAvailabilityStringUseCase: appDiContainer.getLanguageAvailabilityStringUseCase(),
            delegate: nil
        )
        
        FavoriteToolsView(viewModel: viewModel, width: 375, leadingPadding: 20)
    }
}
