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
        
        /*
         About removing the List separators:
         - iOS 15 - use the `listRowSeparator` view modifier to hide the separators
         - iOS 13 - list is built on UITableView, so `UITableView.appearance` works to set the separator style
         - iOS 14 - `appearance` no longer works, and the modifier doesn't yet exist.  Solution is the AllToolsListIOS14 view.
         */
        if #available(iOS 14.0, *) {} else {
            // TODO: - When we stop supporting iOS 13, get rid of this.
            UITableView.appearance(whenContainedInInstancesOf: [UIHostingController<AllToolsContentView>.self]).separatorStyle = .none
        }
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
                        
                    } else if #available(iOS 14.0, *) {
                        
                        AllToolsListIOS14(viewModel: viewModel, width: width)
                        
                    } else {
                        
                        AllToolsList(viewModel: viewModel, width: width)
                    }
                }
            }
        }
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
