//
//  AllFavoriteToolsView.swift
//  godtools
//
//  Created by Rachael Skeath on 6/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct AllFavoriteToolsView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: AllFavoriteToolsViewModel
    
    // MARK: - Constants
    
    private enum Sizes {
        static let toolsPaddingMultiplier: CGFloat = 15/375
    }
    
    // MARK: - Body
    var body: some View {
        
        GeometryReader { geo in
            let width = geo.size.width
            let leadingTrailingPadding = width * Sizes.toolsPaddingMultiplier
            
            BackwardCompatibleList {
                VStack(alignment: .leading) {
                    Text(viewModel.sectionTitle)
                        .font(FontLibrary.sfProTextRegular.font(size: 22))
                        .foregroundColor(ColorPalette.gtGrey.color)
                        .padding(.leading, leadingTrailingPadding)
                        .padding(.top, 40)
                    
                    ToolCardsView(viewModel: viewModel, width: width, leadingPadding: leadingTrailingPadding)
                }
                .listRowInsets(EdgeInsets())
            } refreshHandler: {}
        }
    }
}

struct AllFavoriteToolsView_Previews: PreviewProvider {
    static var previews: some View {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        
        let viewModel = AllFavoriteToolsViewModel(
            dataDownloader: appDiContainer.initialDataDownloader,
            deviceAttachmentBanners: appDiContainer.deviceAttachmentBanners,
            favoritedResourcesCache: appDiContainer.favoritedResourcesCache,
            languageSettingsService: appDiContainer.languageSettingsService,
            localizationServices: appDiContainer.localizationServices,
            flowDelegate: nil
        )
        
        AllFavoriteToolsView(viewModel: viewModel)
    }
}
