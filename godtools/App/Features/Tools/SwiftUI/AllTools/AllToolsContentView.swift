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
    
    // MARK: - Constants
    
    private enum Sizes {
        static let toolsPaddingMultiplier: CGFloat = 20/375
        static let toolsVerticalSpacing: CGFloat = 15
    }
    
    // MARK: - Init
    
    init(viewModel: AllToolsContentViewModel) {
        self.viewModel = viewModel
        
        // TODO: - GT-1528: This doesn't work on iOS 14, and iOS 15 has a modifier that will do it.
        // List is built on UITableView. For iOS 13, modifiers don't yet exist to override certain default styles on List, so we use `appearance` on UITableView instead. This changes the style system-wide, so we'll have to watch out for this causing issues in other areas.
        UITableView.appearance().separatorColor = .clear
        
    }
    
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
                
                GeometryReader { geo in
                    let width = geo.size.width
                    
                    if #available(iOS 15.0, *) {
                        
                        // Pull to refresh is supported only in iOS 15+
                        AllToolsList(viewModel: viewModel, width: width)
                            .refreshable {
                                viewModel.refreshTools()
                            }
                        
                    } else {
                        
                        AllToolsList(viewModel: viewModel, width: width)
                    }
                }
            }
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
