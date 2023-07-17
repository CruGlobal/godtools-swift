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
    
    // MARK: - Body
    
    var body: some View {
        
        GeometryReader { geo in
            let width = geo.size.width
            let leadingTrailingPadding = DashboardView.getMargin(for: width)
            
            BackwardCompatibleList(rootViewType: Self.self) {
                Group {
                    Text(viewModel.sectionTitle)
                        .font(FontLibrary.sfProTextRegular.font(size: 22))
                        .foregroundColor(ColorPalette.gtGrey.color)
                        .padding(.leading, leadingTrailingPadding)
                        .padding(.top, 30)
                        .padding(.bottom, 15)
                    
                    ToolCardsView(viewModel: viewModel, cardType: .standardWithNavButtons, width: width, leadingPadding: leadingTrailingPadding)
                }
                .listRowInsets(EdgeInsets())
            } refreshHandler: {}
                .animation(.default, value: viewModel.tools)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.pageViewed()
        }
    }
}

struct AllFavoriteToolsView_Previews: PreviewProvider {
    static var previews: some View {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        
        let viewModel = AllFavoriteToolsViewModel(
            localizationServices: appDiContainer.dataLayer.getLocalizationServices(),
            getAllFavoritedToolsUseCase: appDiContainer.domainLayer.getAllFavoritedToolsUseCase(),
            getBannerImageUseCase: appDiContainer.domainLayer.getBannerImageUseCase(),
            getLanguageAvailabilityUseCase: appDiContainer.domainLayer.getLanguageAvailabilityUseCase(),
            getSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getSettingsParallelLanguageUseCase(),
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            getToolIsFavoritedUseCase: appDiContainer.domainLayer.getToolIsFavoritedUseCase(),
            removeToolFromFavoritesUseCase: appDiContainer.domainLayer.getRemoveToolFromFavoritesUseCase(),
            flowDelegate: nil,
            analytics: appDiContainer.dataLayer.getAnalytics()
        )
        
        AllFavoriteToolsView(viewModel: viewModel)
    }
}
