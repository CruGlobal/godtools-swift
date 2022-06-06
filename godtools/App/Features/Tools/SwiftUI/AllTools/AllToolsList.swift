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
        
    // MARK: - Constants
    
    private enum Sizes {
        static let toolsPaddingMultiplier: CGFloat = 20/375
    }
    
    // MARK: - Body
    
    var body: some View {
        let leadingTrailingPadding = width * Sizes.toolsPaddingMultiplier
        
        Group {
            
            ToolSpotlightView(viewModel: viewModel.spotlightViewModel(), width: width, leadingPadding: leadingTrailingPadding)
                .listRowInsets(EdgeInsets())
            
            ToolCategoriesView(viewModel: viewModel.getCategoriesViewModel(), leadingPadding: leadingTrailingPadding)
                .listRowInsets(EdgeInsets())
            
            SeparatorView()
                .listRowInsets(EdgeInsets())
                .padding([.leading, .trailing], leadingTrailingPadding)
            
            
            ToolCardsView(viewModel: viewModel.getToolCardsViewModel(), width: width, leadingPadding: leadingTrailingPadding)
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
            deviceAttachmentBanners: appDiContainer.deviceAttachmentBanners,
            languageSettingsService: appDiContainer.languageSettingsService,
            localizationServices: appDiContainer.localizationServices,
            favoritedResourcesCache: appDiContainer.favoritedResourcesCache,
            favoritingToolMessageCache: appDiContainer.favoritingToolMessageCache,
            analytics: appDiContainer.analytics
        )
        
        GeometryReader { geo in
            VStack {
                AllToolsList(viewModel: viewModel, width: geo.size.width)
            }
        }
    }
}

