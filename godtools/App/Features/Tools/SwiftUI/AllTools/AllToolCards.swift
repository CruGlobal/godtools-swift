//
//  AllToolsList.swift
//  godtools
//
//  Created by Rachael Skeath on 5/9/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct AllToolCards: View {
    
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

        ForEach(viewModel.tools) { tool in
            
            HStack {
                Spacer()
                
                ToolCardView(viewModel: viewModel.cardViewModel(for: tool), cardWidth: width - (2 * leadingTrailingPadding))
                    .onTapGesture {
                        viewModel.toolTapped(resource: tool)
                    }
                    .padding([.top, .bottom], 4)
                
                Spacer()
                
            }
        }
    }
}

// MARK: - Preview

struct AllToolCards_Previews: PreviewProvider {
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
            AllToolCards(viewModel: viewModel, width: geo.size.width)
        }
    }
}
