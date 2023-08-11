//
//  ToolCardsCarouselView.swift
//  godtools
//
//  Created by Rachael Skeath on 5/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolCardsCarouselView: View {
        
    private enum Sizes {
        static let spotlightCardWidthMultiplier: CGFloat = 200/375
    }
    
    private let cardType: ToolCardType
    private let width: CGFloat
    private let leadingTrailingPadding: CGFloat
    
    @ObservedObject private var viewModel: ToolCardProvider
    
    init(viewModel: ToolCardProvider, cardType: ToolCardType, width: CGFloat, leadingTrailingPadding: CGFloat) {
        
        self.viewModel = viewModel
        self.cardType = cardType
        self.width = width
        self.leadingTrailingPadding = leadingTrailingPadding
    }
    
    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            
            HStack(spacing: 15) {
                
                if let maxNumberCardsToShow = viewModel.maxNumberOfCardsToShow, viewModel.tools.count > maxNumberCardsToShow {
                    
                    ForEach(viewModel.tools[0..<maxNumberCardsToShow]) { tool in
                        
                        makeToolCardView(with: tool)
                    }
                    
                } else {
                    ForEach(viewModel.tools) { tool in
                        
                        makeToolCardView(with: tool)
                    }
                }
            }
            .padding([.leading, .trailing], leadingTrailingPadding)
            .animation(.default, value: viewModel.tools)
        }
    }
    
    @ViewBuilder
    func makeToolCardView(with tool: ToolDomainModel) -> some View {
        
        ToolCardView(
            viewModel: viewModel.cardViewModel(for: tool),
            cardType: cardType,
            cardWidth: width * Sizes.spotlightCardWidthMultiplier
        )
        .padding(.bottom, 12)
        .padding(.top, 5)
    }
}

struct ToolCardsCarouselView_Previews: PreviewProvider {
    static var previews: some View {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()

        let viewModel = ToolSpotlightViewModel(
            dataDownloader: appDiContainer.dataLayer.getInitialDataDownloader(),
            localizationServices: appDiContainer.dataLayer.getLocalizationServices(),
            getBannerImageUseCase: appDiContainer.domainLayer.getBannerImageUseCase(),
            getLanguageAvailabilityUseCase: appDiContainer.domainLayer.getLanguageAvailabilityUseCase(),
            getSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getSettingsParallelLanguageUseCase(),
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            getSpotlightToolsUseCase: appDiContainer.domainLayer.getSpotlightToolsUseCase(),
            getToolIsFavoritedUseCase: appDiContainer.domainLayer.getToolIsFavoritedUseCase(),
            delegate: nil
        )
        
        ToolCardsCarouselView(viewModel: viewModel, cardType: .squareWithNavButtons, width: 375, leadingTrailingPadding: 20)
    }
}
