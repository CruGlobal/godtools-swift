//
//  FavoriteToolsView.swift
//  godtools
//
//  Created by Rachael Skeath on 6/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct FavoriteToolsView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: FavoriteToolsViewModel
    let width: CGFloat
    let leadingPadding: CGFloat
    
    // MARK: - Body
    
    var body: some View {
//        if viewModel.tools.isEmpty == false {
            
            VStack(alignment: .leading, spacing: 10) {
                
                Text("Your favorite tools")
                    .font(FontLibrary.sfProTextRegular.font(size: 22))
                    .foregroundColor(ColorPalette.gtGrey.color)
                    .padding(.leading, leadingPadding)
                    .padding(.top, 24)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    
                    HorizontalToolCardsView(viewModel: viewModel, width: width)
                    .padding(.leading, leadingPadding)
                }
            }
//        }
    }
}

struct FavoriteToolsView_Previews: PreviewProvider {
    static var previews: some View {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()

        let viewModel = FavoriteToolsViewModel(
            dataDownloader: appDiContainer.initialDataDownloader,
            deviceAttachmentBanners: appDiContainer.deviceAttachmentBanners,
            favoritedResourcesCache: appDiContainer.favoritedResourcesCache,
            languageSettingsService: appDiContainer.languageSettingsService,
            localizationServices: appDiContainer.localizationServices
        )
        
        FavoriteToolsView(viewModel: viewModel, width: 375, leadingPadding: 20)
    }
}
