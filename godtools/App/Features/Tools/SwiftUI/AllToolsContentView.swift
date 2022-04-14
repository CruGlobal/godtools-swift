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
        GeometryReader { geo in
            let width = geo.size.width
            let leadingTrailingPadding = width * Sizes.toolsPaddingMultiplier
            
            List {
                // TODO: - These sections will be completed in GT-1265 & GT-1498
                Text("Spotlight")
                Text("Categories")
                
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

// MARK: - Preview

struct AllToolsContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        
        let viewModel = AllToolsContentViewModel(
            dataDownloader: appDiContainer.initialDataDownloader,
            deviceAttachmentBanners: appDiContainer.deviceAttachmentBanners,
            languageSettingsService: appDiContainer.languageSettingsService,
            localizationServices: appDiContainer.localizationServices,
            favoritedResourcesCache: appDiContainer.favoritedResourcesCache
        )
        
        AllToolsContentView(viewModel: viewModel)
    }
}
