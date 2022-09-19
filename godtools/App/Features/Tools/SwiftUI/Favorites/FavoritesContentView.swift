//
//  FavoritesContentView.swift
//  godtools
//
//  Created by Rachael Skeath on 6/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct FavoritesContentView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: FavoritesContentViewModel
    
    // MARK: - Body
    
    var body: some View {
        
        VStack {
            if viewModel.hideTutorialBanner == false {
                
                OpenTutorialBannerView(viewModel: viewModel.getTutorialBannerViewModel())
            }
            
            GeometryReader { geo in
                let width = geo.size.width
                let leadingTrailingPadding = ToolsMenuView.getMargin(for: width)
                
                BackwardCompatibleList(rootViewType: Self.self) {
                    
                    Text(viewModel.pageTitle)
                        .font(FontLibrary.sfProTextRegular.font(size: 30))
                        .foregroundColor(ColorPalette.gtGrey.color)
                        .padding(.top, 12)
                        .padding(.bottom, 15)
                    
                    FeaturedLessonCardsView(viewModel: viewModel.featuredLessonCardsViewModel, width: width, leadingPadding: leadingTrailingPadding)
                        .listRowInsets(EdgeInsets())
                        .padding(.bottom, 10)
                    
                    FavoriteToolsView(viewModel: viewModel.favoriteToolsViewModel, width: width, leadingPadding: leadingTrailingPadding)
                        .listRowInsets(EdgeInsets())
                        
                    Spacer()
                    
                } refreshHandler: {
                    viewModel.refreshData()
                }
            }
        }
        .onAppear {
            viewModel.pageViewed()
        }
    }
}

struct FavoritesContentView_Previews: PreviewProvider {
    static var previews: some View {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        
        let viewModel = FavoritesContentViewModel(
            flowDelegate: MockFlowDelegate(),
            dataDownloader: appDiContainer.initialDataDownloader,
            languageSettingsService: appDiContainer.languageSettingsService,
            localizationServices: appDiContainer.localizationServices,
            analytics: appDiContainer.analytics,
            getAllFavoritedToolsUseCase: appDiContainer.domainLayer.getAllFavoritedToolsUseCase(),
            getBannerImageUseCase: appDiContainer.domainLayer.getBannerImageUseCase(),
            getOptInOnboardingBannerEnabledUseCase: appDiContainer.getOpInOnboardingBannerEnabledUseCase(),
            disableOptInOnboardingBannerUseCase: appDiContainer.getDisableOptInOnboardingBannerUseCase(),
            getLanguageAvailabilityStringUseCase: appDiContainer.getLanguageAvailabilityStringUseCase(),
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            getToolIsFavoritedUseCase: appDiContainer.domainLayer.getToolIsFavoritedUseCase(),
            removeToolFromFavoritesUseCase: appDiContainer.domainLayer.getRemoveToolFromFavoritesUseCase()
        )
        
        FavoritesContentView(viewModel: viewModel)
    }
}
