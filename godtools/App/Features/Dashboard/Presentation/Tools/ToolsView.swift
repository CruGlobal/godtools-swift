//
//  ToolsView.swift
//  godtools
//
//  Created by Rachael Skeath on 4/6/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolsView: View {
        
    private let contentHorizontalInsets: CGFloat
    private let toolCardSpacing: CGFloat = 15
        
    @ObservedObject private var viewModel: ToolsViewModel
    
    init(viewModel: ToolsViewModel, contentHorizontalInsets: CGFloat = DashboardView.contentHorizontalInsets) {
        
        self.viewModel = viewModel
        self.contentHorizontalInsets = contentHorizontalInsets
    }
    
    var body: some View {
        
        GeometryReader { geometry in
              
            AccessibilityScreenElementView(screenAccessibility: .dashboardTools)
            
            if viewModel.isLoadingAllTools {
                CenteredCircularProgressView(
                    progressColor: ColorPalette.gtGrey.color
                )
            }
            
            VStack(alignment: .leading, spacing: 0) {
                
                if viewModel.showsFavoritingToolBanner {
                    
                    FavoritingToolBannerView(
                        viewModel: viewModel
                    )
                    .transition(.move(edge: .top))
                }
                
                PullToRefreshScrollView(showsIndicators: true) {
                    
                    VStack(alignment: .leading, spacing: 0) {
                        
                        ToolSpotlightView(
                            viewModel: viewModel,
                            geometry: geometry,
                            contentHorizontalInsets: contentHorizontalInsets
                        )
                        .padding([.top], 24)
                                    
                        SeparatorView()
                            .padding([.top], 15)
                            .padding([.bottom], 11)
                            .padding([.leading, .trailing], contentHorizontalInsets)
                        
                        ToolsFilterSectionView(viewModel: viewModel, contentHorizontalInsets: contentHorizontalInsets, width: geometry.size.width)
                            .padding([.bottom], 18)
                        
                        LazyVStack(alignment: .center, spacing: toolCardSpacing) {
                            
                            ForEach(viewModel.allTools) { (tool: ToolDomainModel) in
                                                                
                                ToolCardView(
                                    viewModel: viewModel.getToolViewModel(tool: tool),
                                    geometry: geometry,
                                    layout: .landscape,
                                    showsCategory: true,
                                    favoriteTappedClosure: {
                                        
                                        viewModel.toolFavoriteTapped(tool: tool)
                                    },
                                    toolDetailsTappedClosure: nil,
                                    openToolTappedClosure: nil,
                                    toolTappedClosure: {
                                        
                                        viewModel.toolTapped(tool: tool)
                                    }
                                )
                            }
                        }
                    }
                    .padding([.bottom], DashboardView.scrollViewBottomSpacingToTabBar)
                    
                } refreshHandler: {
                    
                    viewModel.pullToRefresh()
                }
                .opacity(viewModel.isLoadingAllTools ? 0 : 1)
                .animation(.easeOut, value: !viewModel.isLoadingAllTools)
            }
        }
        .onAppear {
            
            viewModel.pageViewed()
        }
    }
}

// MARK: - Preview

struct AllToolsView_Preview: PreviewProvider {
    
    static func getToolsViewModel() -> ToolsViewModel {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        
        let viewModel = ToolsViewModel(
            flowDelegate: MockFlowDelegate(),
            resourcesRepository: appDiContainer.dataLayer.getResourcesRepository(),
            favoritingToolMessageCache: appDiContainer.dataLayer.getFavoritingToolMessageCache(),
            getAllToolsUseCase: appDiContainer.domainLayer.getAllToolsUseCase(),
            getLanguageAvailabilityUseCase: appDiContainer.domainLayer.getLanguageAvailabilityUseCase(),
            getSpotlightToolsUseCase: appDiContainer.domainLayer.getSpotlightToolsUseCase(),
            getToolFilterCategoriesUseCase: appDiContainer.feature.toolsFilter.domainLayer.getToolFilterCategoriesUseCase(),
            getToolFilterLanguagesUseCase: appDiContainer.feature.toolsFilter.domainLayer.getToolFilterLanguagesUseCase(),
            getUserFiltersUseCase: appDiContainer.feature.toolsFilter.domainLayer.getUserFiltersUseCase(),
            getToolIsFavoritedUseCase: appDiContainer.domainLayer.getToolIsFavoritedUseCase(),
            toggleToolFavoritedUseCase: appDiContainer.domainLayer.getToggleToolFavoritedUseCase(),
            getInterfaceStringInAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getInterfaceStringInAppLanguageUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.domainLayer.getTrackScreenViewAnalyticsUseCase(),
            trackActionAnalyticsUseCase: appDiContainer.domainLayer.getTrackActionAnalyticsUseCase(),
            attachmentsRepository: appDiContainer.dataLayer.getAttachmentsRepository()
        )
        
        return viewModel
    }
    
    static var previews: some View {
        
        ToolsView(viewModel: AllToolsView_Preview.getToolsViewModel())
    }
}
