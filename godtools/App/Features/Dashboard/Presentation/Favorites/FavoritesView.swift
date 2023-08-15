//
//  FavoritesView.swift
//  godtools
//
//  Created by Rachael Skeath on 6/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct FavoritesView: View {
        
    private let leadingTrailingPadding: CGFloat
    
    @ObservedObject private var viewModel: FavoritesViewModel
    
    init(viewModel: FavoritesViewModel, leadingTrailingPadding: CGFloat) {
        
        self.viewModel = viewModel
        self.leadingTrailingPadding = leadingTrailingPadding
    }
    
    var body: some View {
        
        GeometryReader { geometry in
                  
            VStack(alignment: .leading, spacing: 0) {
                
                if !viewModel.hideTutorialBanner {
                    OpenTutorialBannerView(viewModel: viewModel.getTutorialBannerViewModel())
                }
                
                PullToRefreshScrollView(showsIndicators: true) {
                    
                    VStack(alignment: .leading, spacing: 0) {
                        
                        Text(viewModel.pageTitle)
                            .font(FontLibrary.sfProTextRegular.font(size: 30))
                            .foregroundColor(ColorPalette.gtGrey.color)
                            .padding(.top, 24)
                            .padding(.bottom, 15)
                            .padding(.leading, leadingTrailingPadding)
                        
                        FeaturedLessonView(
                            viewModel: viewModel.featuredLessonViewModel,
                            width: geometry.size.width,
                            leadingPadding: leadingTrailingPadding,
                            lessonTappedClosure: { (lesson: LessonDomainModel) in
                            
                            viewModel.lessonTapped(lesson: lesson)
                        })
                        .padding(.bottom, 10)
                        
                        FavoriteToolsView(viewModel: viewModel.favoriteToolsViewModel, width: geometry.size.width, leadingPadding: leadingTrailingPadding)
                            .padding(.bottom, 23)
                    }

                } refreshHandler: {
                    viewModel.refreshData()
                }
            }
        }
        .onAppear {
            viewModel.pageViewed()
        }
        
        
        
        /*
        VStack(spacing: 0) {
            
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
                    
                    PullToRefreshScrollView(showsIndicators: true) {
                        
                        LazyVStack(alignment: .leading, spacing: 0) {
                            
                            Text(viewModel.pageTitle)
                                .font(FontLibrary.sfProTextRegular.font(size: 30))
                                .foregroundColor(ColorPalette.gtGrey.color)
                                .padding(.top, 24)
                                .padding(.bottom, 15)
                                .padding(.leading, leadingTrailingPadding)
                            
                            FeaturedLessonCardsView(viewModel: viewModel.featuredLessonCardsViewModel, width: width, leadingPadding: leadingTrailingPadding, lessonTappedClosure: { (lesson: LessonDomainModel) in
                                
                                viewModel.lessonTapped(lesson: lesson)
                            })
                            .padding(.bottom, 10)
                            
                            FavoriteToolsView(viewModel: viewModel.favoriteToolsViewModel, width: width, leadingPadding: leadingTrailingPadding)
                                .padding(.bottom, 23)
                        }
                        
                    } refreshHandler: {
                        
                        viewModel.refreshData()
                    }
                }
            }
        }
        .onAppear {
            viewModel.pageViewed()
        }
        */
        
        
        
        
        
    }
}

struct FavoritesView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        
        let viewModel = FavoritesViewModel(
            flowDelegate: MockFlowDelegate(),
            dataDownloader: appDiContainer.dataLayer.getInitialDataDownloader(),
            localizationServices: appDiContainer.dataLayer.getLocalizationServices(),
            analytics: appDiContainer.dataLayer.getAnalytics(),
            attachmentsRepository: appDiContainer.dataLayer.getAttachmentsRepository(),
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
        
        FavoritesView(viewModel: viewModel, leadingTrailingPadding: 20)
    }
}
