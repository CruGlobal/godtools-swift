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
    let leadingTrailingPadding: CGFloat
    
    // MARK: - Body
    
    var body: some View {
        
        VStack {
            if viewModel.hideTutorialBanner == false {
                
                OpenTutorialBannerView(viewModel: viewModel.getTutorialBannerViewModel())
            }
            
            if viewModel.isLoading {
                
                Spacer()
                ActivityIndicator(style: .medium, isAnimating: .constant(true))
                Spacer()
                
            } else {
                
                GeometryReader { geo in
                    let width = geo.size.width
                    
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
            localizationServices: appDiContainer.localizationServices,
            analytics: appDiContainer.dataLayer.getAnalytics(),
            translationsRepository: appDiContainer.dataLayer.getTranslationsRepository(),
            disableOptInOnboardingBannerUseCase: appDiContainer.getDisableOptInOnboardingBannerUseCase(),
            getAllFavoritedToolsUseCase: appDiContainer.domainLayer.getAllFavoritedToolsUseCase(),
            getBannerImageUseCase: appDiContainer.domainLayer.getBannerImageUseCase(),
            getFeaturedLessonsUseCase: appDiContainer.domainLayer.getFeaturedLessonsUseCase(),
            getLanguageAvailabilityUseCase: appDiContainer.domainLayer.getLanguageAvailabilityUseCase(),
            getOptInOnboardingBannerEnabledUseCase: appDiContainer.getOpInOnboardingBannerEnabledUseCase(),
            getSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getSettingsParallelLanguageUseCase(),
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            getToolIsFavoritedUseCase: appDiContainer.domainLayer.getToolIsFavoritedUseCase(),
            removeToolFromFavoritesUseCase: appDiContainer.domainLayer.getRemoveToolFromFavoritesUseCase()
        )
        
        FavoritesContentView(viewModel: viewModel, leadingTrailingPadding: 20)
    }
}
