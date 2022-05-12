//
//  AllToolsContentView.swift
//  godtools
//
//  Created by Rachael Skeath on 4/6/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct AllToolsContentView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: AllToolsContentViewModel
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            if viewModel.hideFavoritingToolBanner == false {
                FavoritingToolBannerView(viewModel: viewModel.favoritingToolBannerViewModel())
                    .transition(.move(edge: .top))
            }
            
            if viewModel.isLoading {
                
                ActivityIndicator(style: .medium, isAnimating: .constant(true))
                
            } else {
                
                GeometryReader { geometry in
                    
                    let geometryWidth: CGFloat = geometry.size.width
                    let toolsVerticalSpacing: CGFloat = 10
                    let toolsPaddingMultiplier: CGFloat = 20/375
                    let leadingTrailingPadding: CGFloat = geometryWidth * toolsPaddingMultiplier
                    let cardWidth: CGFloat = geometryWidth - (2 * leadingTrailingPadding)
                    
                    ItemsList<ResourceModel, ToolCardView>(hidesSeparatorInContainerTypes: [UIHostingController<AllToolsContentView>.self], listItems: $viewModel.tools, refreshList: {
                        
                        viewModel.refreshTools()
                        
                    }, viewForItem: { item in
                        
                        let cardViewModel = viewModel.cardViewModel(for: item)
                        
                        return ToolCardView(viewModel: cardViewModel, cardWidth: cardWidth)
                        
                    }, itemTapped: { item in
                        
                        viewModel.toolTapped(resource: item)
                        
                    }, listTopPadding: 8, listRowInsets: EdgeInsets(top: toolsVerticalSpacing, leading: leadingTrailingPadding, bottom: toolsVerticalSpacing, trailing: leadingTrailingPadding), lazyVStackItemHorizontalPadding: leadingTrailingPadding, lazyVStackItemVerticalPadding: 6, lazyVStackTopPadding: 12)
                }
            }
        }
        .onAppear {
            viewModel.pageViewed()
        }
    }
    
    func pageViewed() {
        viewModel.pageViewed()
    }
}

// MARK: - Preview

struct AllToolsContentView_Previews: PreviewProvider {
    
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
        
        AllToolsContentView(viewModel: viewModel)
    }
}
