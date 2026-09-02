//
//  FavoritesView.swift
//  godtools
//
//  Created by Rachael Skeath on 6/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct FavoritesView: View {
        
    private let contentHorizontalInsets: CGFloat
    
    @ObservedObject private var viewModel: FavoritesViewModel
    
    init(viewModel: FavoritesViewModel, contentHorizontalInsets: CGFloat = DashboardView.contentHorizontalInsets) {
        
        self.viewModel = viewModel
        self.contentHorizontalInsets = contentHorizontalInsets
    }
    
    var body: some View {
        
        GeometryReader { geometry in
                  
            AccessibilityScreenElementView(screenAccessibility: .dashboardFavorites)
            
            VStack(alignment: .leading, spacing: 0) {
                
                if viewModel.showsOpenTutorialBanner {
                    
                    OpenTutorialBannerView(
                        viewModel: viewModel,
                        closeTappedClosure: {
                            
                            viewModel.closeOpenTutorialBannerTapped()
                        },
                        openTutorialTappedClosure: {
                            
                            viewModel.openTutorialBannerTapped()
                        }
                    )
                }
                
                
                
                
                List {
                    
                    YourFavoriteToolsHeaderView(
                        viewModel: viewModel,
                        contentHorizontalInsets: contentHorizontalInsets
                    )
                    
                    if viewModel.favoritedTools.count > 0 {
                        
                        ForEach(viewModel.favoritedTools) { (tool: YourFavoritedToolDomainModel) in
                            ToolCardView(
                                viewModel: viewModel.getToolViewModel(tool: tool),
                                geometry: geometry,
                                layout: .landscape,
                                showsCategory: true,
                                favoriteTappedClosure: {
                                    
                                    viewModel.unfavoriteToolTapped(tool: tool)
                                },
                                toolDetailsTappedClosure: {
                                    
                                    viewModel.toolDetailsTapped(tool: tool)
                                },
                                openToolTappedClosure: {
                                    
                                    viewModel.openToolTapped(tool: tool)
                                },
                                toolTappedClosure: {
                                    
                                    viewModel.toolTapped(tool: tool)
                                }
                            )
                            .buttonStyle(.plain)
                            .listRowSeparator(.hidden)
                        }
                        .onMove { from, to in
                            viewModel.toolMoved(fromOffsets: from, toOffset: to)
                        }
                    }
                    else {
                        
                        NoFavoriteToolsView(viewModel: viewModel)
                            .padding([.top], 12)
                            .padding([.leading, .trailing], contentHorizontalInsets)
                            .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    viewModel.pullToRefresh()
                }
            }
        }//end GeometryReader
        .onAppear {
            
            viewModel.pageViewed()
        }
    }
}

// MARK: - Preview

struct FavoritesView_Preview: PreviewProvider {
    
    static func getFavoritesViewModel() -> FavoritesViewModel {
        
        let appDiContainer = AppDiContainer.createUITestsDiContainer()
        
        let viewModel = FavoritesViewModel(
            stepEmitter: PreviewFlowStepEmitter.emitter,
            resourcesRepository: appDiContainer.core.dataLayer.getResourcesRepository(),
            getFavoritesStringsUseCase: appDiContainer.feature.favorites.domainLayer.getFavoritesStringsUseCase(),
            getYourFavoritedToolsUseCase: appDiContainer.feature.favorites.domainLayer.getYourFavoritedToolsUseCase(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getToolIsFavoritedUseCase: appDiContainer.feature.favorites.domainLayer.getToolIsFavoritedUseCase(),
            reorderFavoritedToolUseCase: appDiContainer.feature.favorites.domainLayer.getReorderFavoritedToolUseCase(),
            getToolBannerUseCase: appDiContainer.core.domainLayer.getToolBannerUseCase(),
            imageCache: appDiContainer.core.dataLayer.getSharedImageCache(),
            disableOptInOnboardingBannerUseCase: appDiContainer.feature.tools.domainLayer.getDisableOptInOnboardingBannerUseCase(),
            getFeaturedLessonsUseCase: appDiContainer.feature.featuredLessons.domainLayer.getFeaturedLessonsUseCase(),
            getOptInOnboardingBannerEnabledUseCase: appDiContainer.feature.tools.domainLayer.getOptInOnboardingBannerEnabledUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.core.domainLayer.getTrackScreenViewAnalyticsUseCase(),
            trackActionAnalyticsUseCase: appDiContainer.core.domainLayer.getTrackActionAnalyticsUseCase()
        )
        
        return viewModel
    }
    
    static var previews: some View {
        
        FavoritesView(
            viewModel: FavoritesView_Preview.getFavoritesViewModel(),
            contentHorizontalInsets: 20
        )
    }
}
