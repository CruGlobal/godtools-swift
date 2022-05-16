//
//  AllToolsList.swift
//  godtools
//
//  Created by Rachael Skeath on 4/19/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

// AllToolsList built using a List, since that's the only type of view on iOS 13 that supports lazy loading

struct AllToolsListIOS13: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: AllToolsContentViewModel
    let width: CGFloat
        
    // MARK: - Constants
    
    private enum Sizes {
        static let toolsPaddingMultiplier: CGFloat = 20/375
        static let toolsVerticalSpacing: CGFloat = 10
    }
    
    // MARK: - Body
    
    var body: some View {
        let leadingTrailingPadding = width * Sizes.toolsPaddingMultiplier

        List {
            ToolSpotlightView(viewModel: viewModel.spotlightViewModel(), width: width)
                .listRowInsets(EdgeInsets())
            
            // TODO: - Category filter sections will be completed in GT-1265
            
            ForEach(viewModel.tools) { tool in
                Group {
                    ToolCardView(viewModel: viewModel.cardViewModel(for: tool), cardWidth: width - (2 * leadingTrailingPadding))
                }
                .onTapGesture {
                    viewModel.toolTapped(resource: tool)
                }
            }
            .listRowInsets(EdgeInsets(top: Sizes.toolsVerticalSpacing, leading: leadingTrailingPadding, bottom: Sizes.toolsVerticalSpacing, trailing: leadingTrailingPadding))
        }
        .frame(maxWidth: .infinity)
        .edgesIgnoringSafeArea([.leading, .trailing])
        .listStyle(.plain)
        .padding(.top, 8)
    }
}

// MARK: - Preview

struct AllToolsListIOS13_Previews: PreviewProvider {
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

