//
//  ToolSpotlightView.swift
//  godtools
//
//  Created by Rachael Skeath on 5/10/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolSpotlightView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: ToolSpotlightViewModel
    let width: CGFloat
    let leadingPadding: CGFloat
    
    // MARK: - Body
    
    var body: some View {
        
        if viewModel.tools.isEmpty == false {
            
            VStack(alignment: .leading, spacing: 10) {
                
                SpotlightTitleView(title: viewModel.spotlightTitle, subtitle: viewModel.spotlightSubtitle)
                .padding(.leading, leadingPadding)
                .padding(.top, 24)
                
                ToolCardsCarouselView(viewModel: viewModel, cardType: .square, width: width, leadingTrailingPadding: leadingPadding)
            }
        }
    }
}

// MARK: - Preview

struct ToolSpotlightView_Previews: PreviewProvider {
    static var previews: some View {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()

        let viewModel = ToolSpotlightViewModel(
            dataDownloader: appDiContainer.initialDataDownloader,
            favoritedResourcesCache: appDiContainer.favoritedResourcesCache,
            languageSettingsService: appDiContainer.languageSettingsService,
            localizationServices: appDiContainer.localizationServices,
            getBannerImageUseCase: appDiContainer.domainLayer.getBannerImageUseCase(),
            getLanguageAvailabilityStringUseCase: appDiContainer.getLanguageAvailabilityStringUseCase(),
            delegate: nil
        )
        
        ToolSpotlightView(viewModel: viewModel, width: 375, leadingPadding: 20)
    }
}
