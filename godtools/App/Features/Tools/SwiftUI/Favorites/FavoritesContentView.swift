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
    
    // MARK: - Constants
    
    private enum Sizes {
        static let toolsPaddingMultiplier: CGFloat = 15/375
    }
    
    // MARK: - Body
    
    var body: some View {
        
        VStack {
            if viewModel.hideTutorialBanner == false {
                
                OpenTutorialBannerView(viewModel: viewModel.getTutorialBannerViewModel())
            }
            
            if viewModel.lessonsLoading && viewModel.toolsLoading {
                
                ActivityIndicator(style: .medium, isAnimating: .constant(true))
                
            } else {
                
                GeometryReader { geo in
                    let width = geo.size.width
                    let leadingTrailingPadding = width * Sizes.toolsPaddingMultiplier
                    
                    BackwardCompatibleList {
                        
                        Text(viewModel.pageTitle)
                            .font(FontLibrary.sfProTextRegular.font(size: 30))
                            .foregroundColor(ColorPalette.gtGrey.color)
                            .padding(.top, 12)
                            .padding(.bottom, 15)
                        
                        LessonCardsView(viewModel: viewModel.lessonCardsViewModel, width: width, leadingPadding: leadingTrailingPadding)
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
            deviceAttachmentBanners: appDiContainer.deviceAttachmentBanners,
            languageSettingsService: appDiContainer.languageSettingsService,
            localizationServices: appDiContainer.localizationServices,
            favoritedResourcesCache: appDiContainer.favoritedResourcesCache,
            analytics: appDiContainer.analytics,
            getTutorialIsAvailableUseCase: appDiContainer.getTutorialIsAvailableUseCase(),
            openTutorialCalloutCache: appDiContainer.openTutorialCalloutCache
        )
        
        FavoritesContentView(viewModel: viewModel)
    }
}
