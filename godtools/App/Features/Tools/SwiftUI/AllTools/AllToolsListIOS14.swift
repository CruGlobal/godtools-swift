//
//  AllToolsList.swift
//  godtools
//
//  Created by Rachael Skeath on 5/9/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

// MARK: - AllToolsListIOS14

// This view should be visually equivalent to AllToolsList. iOS 14 has no way of removing separators on List, so this is the workaround.
// TODO: - When we stop supporting iOS 14, remove this view.
@available(iOS 14.0, *)
struct AllToolsListIOS14: View {
    
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

        ScrollView {
            LazyVStack {
                // TODO: - Spotlight and Category filter sections will be completed in GT-1265 & GT-1498
                
                ForEach(viewModel.tools) { tool in

                    ToolCardView(viewModel: viewModel.cardViewModel(for: tool), cardWidth: width - (2 * leadingTrailingPadding))
                        .onTapGesture {
                            viewModel.toolTapped(resource: tool)
                        }
                        .padding([.leading, .trailing], leadingTrailingPadding)
                        .padding([.top, .bottom], 6)
                }
            }
            .padding(.top, 12)
        }
    }
}

// MARK: - Preview

struct AllToolsListIOS14_Previews: PreviewProvider {
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
            AllToolsList(viewModel: viewModel, width: geo.size.width)
        }
    }
}

