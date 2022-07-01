//
//  ToolCardsCarouselView.swift
//  godtools
//
//  Created by Rachael Skeath on 5/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolCardsCarouselView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: ToolCardProvider
    let cardType: ToolCardType
    let width: CGFloat
    let leadingTrailingPadding: CGFloat
    
    // MARK: - Constants
    
    private enum Sizes {
        static let spotlightCardWidthMultiplier: CGFloat = 200/375
    }
    
    // MARK: - Body
    
    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            
            HStack(spacing: 15) {
                if let maxNumberCardsToShow = viewModel.maxNumberCardsToShow, viewModel.tools.count > maxNumberCardsToShow {
                    
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
        }
    }
    
    @ViewBuilder
    func makeToolCardView(with tool: ResourceModel) -> some View {
        
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
            dataDownloader: appDiContainer.initialDataDownloader,
            deviceAttachmentBanners: appDiContainer.deviceAttachmentBanners,
            favoritedResourcesCache: appDiContainer.favoritedResourcesCache,
            languageSettingsService: appDiContainer.languageSettingsService,
            localizationServices: appDiContainer.localizationServices,
            delegate: nil
        )
        
        ToolCardsCarouselView(viewModel: viewModel, cardType: .squareWithNavButtons, width: 375, leadingTrailingPadding: 20)
    }
}
