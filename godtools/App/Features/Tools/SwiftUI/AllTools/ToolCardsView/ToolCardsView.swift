//
//  ToolCardsView.swift
//  godtools
//
//  Created by Rachael Skeath on 5/9/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolCardsView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: ToolCardProvider
    let cardType: ToolCardType
    let width: CGFloat
    let leadingPadding: CGFloat
    
    // MARK: - Body
    
    var body: some View {
        
        ForEach(viewModel.tools) { tool in
            
            ToolCardView(viewModel: viewModel.cardViewModel(for: tool), cardType: cardType, cardWidth: width - 2 * leadingPadding)
                .listRowInsets(EdgeInsets())
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
            dataDownloader: appDiContainer.initialDataDownloader,
            languageSettingsService: appDiContainer.languageSettingsService,
            localizationServices: appDiContainer.localizationServices,
            getAllToolsUseCase: appDiContainer.domainLayer.getAllToolsUseCase(),
            getBannerImageUseCase: appDiContainer.domainLayer.getBannerImageUseCase(),
            getLanguageAvailabilityStringUseCase: appDiContainer.getLanguageAvailabilityStringUseCase(),
            getToolIsFavoritedUseCase: appDiContainer.domainLayer.getToolIsFavoritedUseCase(),
            delegate: nil
        )
        
        GeometryReader { geo in
            ToolCardsView(viewModel: viewModel, cardType: .standardWithNavButtons, width: geo.size.width, leadingPadding: 20)
        }
    }
}
