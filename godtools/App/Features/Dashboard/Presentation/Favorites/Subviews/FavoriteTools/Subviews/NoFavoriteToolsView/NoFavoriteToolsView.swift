//
//  NoFavoriteToolsView.swift
//  godtools
//
//  Created by Rachael Skeath on 6/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct NoFavoriteToolsView: View {
        
    @ObservedObject private var viewModel: FavoriteToolsViewModel

    init(viewModel: FavoriteToolsViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            Color(.sRGB, red: 243/256, green: 243/256, blue: 243/256, opacity: 1)
            
            VStack(spacing: 4) {
                Text(viewModel.noFavoriteToolsTitle)
                    .font(FontLibrary.sfProTextRegular.font(size: 18))
                    .foregroundColor(ColorPalette.gtGrey.color)
                    .multilineTextAlignment(.center)
                
                Text(viewModel.noFavoriteToolsDescription)
                    .font(FontLibrary.sfProTextRegular.font(size: 14))
                    .foregroundColor(ColorPalette.gtGrey.color)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                
                GTBlueButton(title: viewModel.noFavoriteToolsButtonText, fontSize: 12, width: 118, height: 30) {
                    
                    viewModel.goToToolsButtonTapped()
                }
                .padding(.top, 10)
            }
            .padding([.top, .bottom], 56)
            .padding([.leading, .trailing], 35)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct NoFavoriteToolsView_Previews: PreviewProvider {
    static var previews: some View {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()

        let viewModel = FavoriteToolsViewModel(
            dataDownloader: appDiContainer.dataLayer.getInitialDataDownloader(),
            localizationServices: appDiContainer.dataLayer.getLocalizationServices(),
            getAllFavoritedToolsUseCase: appDiContainer.domainLayer.getAllFavoritedToolsUseCase(),
            getBannerImageUseCase: appDiContainer.domainLayer.getBannerImageUseCase(),
            getLanguageAvailabilityUseCase: appDiContainer.domainLayer.getLanguageAvailabilityUseCase(),
            getSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getSettingsParallelLanguageUseCase(),
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            getToolIsFavoritedUseCase: appDiContainer.domainLayer.getToolIsFavoritedUseCase(),
            delegate: nil
        )
        
        NoFavoriteToolsView(viewModel: viewModel)
    }
}
