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
        
        // TODO: - In iOS 14/15, remove this and use appropriate modifiers instead.
        // List is built on UITableView. For iOS 13, modifiers don't yet exist to override certain default styles on List, so we use `appearance` on UITableView instead. This changes the style system-wide, so we'll have to watch out for this causing issues in other areas.
        UITableView.appearance().separatorColor = .clear
    }
    
    // MARK: - Body
    
    var body: some View {
        if viewModel.isLoading {
            
            ActivityIndicator(style: .medium, isAnimating: .constant(true))
            
        } else {
            
            GeometryReader { geo in
                let width = geo.size.width
                let leadingTrailingPadding = width * Sizes.toolsPaddingMultiplier
                
                // TODO: - Pull to refresh is supported only in iOS 15+. Need to figure out how we want to address this.
                if #available(iOS 15.0, *) {
                    // TODO: - figure out how to move the List into a separate var/method/etc so we don't have repeated code
                    List {
                        // TODO: - Spotlight and Category filter sections will be completed in GT-1265 & GT-1498

                        ForEach(viewModel.tools) { tool in
                            ToolCardView(viewModel: viewModel.cardViewModel(for: tool), cardWidth: geo.size.width - (2 * leadingTrailingPadding))
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: leadingTrailingPadding, bottom: Sizes.toolsVerticalSpacing, trailing: leadingTrailingPadding))
                    }
                    .frame(maxWidth: .infinity)
                    .edgesIgnoringSafeArea([.leading, .trailing])
                    .listStyle(.plain)
                    .padding(.top, 20)
                    .refreshable {
                        viewModel.refreshTools()
                    }
                    
                } else {
                    
                    List {
                        // TODO: - Spotlight and Category filter sections will be completed in GT-1265 & GT-1498

                        ForEach(viewModel.tools) { tool in
                            ToolCardView(viewModel: viewModel.cardViewModel(for: tool), cardWidth: geo.size.width - (2 * leadingTrailingPadding))
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: leadingTrailingPadding, bottom: Sizes.toolsVerticalSpacing, trailing: leadingTrailingPadding))
                    }
                    .frame(maxWidth: .infinity)
                    .edgesIgnoringSafeArea([.leading, .trailing])
                    .listStyle(.plain)
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
            reloadAllToolsFromCacheUseCase: ReloadAllToolsFromCacheUseCase(dataDownloader: appDiContainer.initialDataDownloader),
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
