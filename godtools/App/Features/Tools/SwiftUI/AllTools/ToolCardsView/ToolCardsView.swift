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
    let width: CGFloat
    let leadingPadding: CGFloat
    
    // MARK: - Body
    
    var body: some View {
        
        ForEach(viewModel.tools) { tool in
            
            ToolCardView(viewModel: viewModel.cardViewModel(for: tool), cardWidth: width - 2 * leadingPadding)
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
            deviceAttachmentBanners: appDiContainer.deviceAttachmentBanners,
            languageSettingsService: appDiContainer.languageSettingsService,
            localizationServices: appDiContainer.localizationServices,
            favoritedResourcesCache: appDiContainer.favoritedResourcesCache,
            delegate: nil
        )
        
        GeometryReader { geo in
            ToolCardsView(viewModel: viewModel, width: geo.size.width, leadingPadding: 20)
        }
    }
}
