//
//  ToolCardsView.swift
//  godtools
//
//  Created by Rachael Skeath on 5/9/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolCardsView: View {
        
    private let cardType: ToolCardType
    private let width: CGFloat
    private let leadingPadding: CGFloat
        
    @ObservedObject private var viewModel: ToolCardProvider
    
    init(viewModel: ToolCardProvider, cardType: ToolCardType, width: CGFloat, leadingPadding: CGFloat) {
        
        self.viewModel = viewModel
        self.cardType = cardType
        self.width = width
        self.leadingPadding = leadingPadding
    }
    
    var body: some View {
        
        ForEach(viewModel.tools) { tool in
            
            ToolCardView(viewModel: viewModel.cardViewModel(for: tool), cardType: cardType, cardWidth: width - 2 * leadingPadding)
                .contentShape(Rectangle())
                .padding([.top, .bottom], 8)
                .padding([.leading, .trailing], leadingPadding)
            
        }
    }
}

// MARK: - Preview

struct ToolCardsView_Previews: PreviewProvider {
    static var previews: some View {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        
        let viewModel = ToolCardsViewModel(
            dataDownloader: appDiContainer.dataLayer.getInitialDataDownloader(),
            localizationServices: appDiContainer.dataLayer.getLocalizationServices(),
            getAllToolsUseCase: appDiContainer.domainLayer.getAllToolsUseCase(),
            getBannerImageUseCase: appDiContainer.domainLayer.getBannerImageUseCase(),
            getLanguageAvailabilityUseCase: appDiContainer.domainLayer.getLanguageAvailabilityUseCase(),
            getSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getSettingsParallelLanguageUseCase(),
            getToolIsFavoritedUseCase: appDiContainer.domainLayer.getToolIsFavoritedUseCase(),
            delegate: nil
        )
        
        GeometryReader { geo in
            ToolCardsView(viewModel: viewModel, cardType: .standardWithNavButtons, width: geo.size.width, leadingPadding: 20)
        }
    }
}
