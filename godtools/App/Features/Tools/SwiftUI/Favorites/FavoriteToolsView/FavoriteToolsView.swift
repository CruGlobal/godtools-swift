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
        VStack(alignment: .leading, spacing: 15) {
            
            HStack(alignment: .bottom) {
                Text(viewModel.sectionTitle)
                    .font(FontLibrary.sfProTextRegular.font(size: 22))
                    .foregroundColor(ColorPalette.gtGrey.color)
                    .padding(.leading, leadingPadding)
                    .padding(.top, 24)
                
                Spacer()
                
                if viewModel.tools.isEmpty == false {
                    
                    Text(viewModel.viewAllButtonText)
                        .font(FontLibrary.sfProTextRegular.font(size: 12))
                        .foregroundColor(ColorPalette.gtBlue.color)
                        .background(Color.white)
                        .padding(.bottom, 2)
                        .frame(height: 30, alignment: .bottom)
                        .onTapGesture {
                            viewModel.viewAllButtonTapped()
                        }
                }
            }
            .padding(.trailing, 20)
            
            if viewModel.tools.isEmpty {
                
                FindFavoriteToolsView()
                    .padding([.leading, .trailing], leadingPadding)
                
            } else {
                
                ToolCardsCarouselView(viewModel: viewModel, width: width, leadingTrailingPadding: leadingPadding)
            }
        }
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
            localizationServices: appDiContainer.localizationServices,
            delegate: nil
        )
        
        FavoriteToolsView(viewModel: viewModel, width: 375, leadingPadding: 20)
    }
}
