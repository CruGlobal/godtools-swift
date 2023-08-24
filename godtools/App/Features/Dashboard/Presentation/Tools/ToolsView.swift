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
                        
                        filterSection(width: geometry.size.width)
            
                        SeparatorView()
                            .padding([.top], 15)
                            .padding([.bottom], 25)
                            .padding([.leading, .trailing], contentHorizontalInsets)
                        
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
    
    @ViewBuilder func filterSection(width: CGFloat) -> some View {
        
        VStack(alignment: .leading, spacing: 8) {
            
            Text(viewModel.filterTitle)
                .font(FontLibrary.sfProTextRegular.font(size: 22))
                .foregroundColor(ColorPalette.gtGrey.color)
                .padding(.leading, contentHorizontalInsets)
                .padding(.top, 28)
            
            let buttonSpacing: CGFloat = 11
            
            HStack(spacing: buttonSpacing) {
                let buttonWidth = (width - (contentHorizontalInsets*2) - buttonSpacing) / 2
                ToolFilterButtonView(
                    viewModel: viewModel.getCategoryButtonViewModel(index: 0),
                    width: buttonWidth,
                    tappedClosure: {
                        
                        viewModel.categoryTapped(index: 0)
                    }
                )
                
                ToolFilterButtonView(
                    viewModel: viewModel.getCategoryButtonViewModel(index: 1),
                    width: buttonWidth,
                    tappedClosure: {
                        
                        viewModel.categoryTapped(index: 1)
                    }
                )
                
            }
            .padding([.leading, .trailing], contentHorizontalInsets)
            .padding([.top, .bottom], 10) // NOTE: This is needed to prevent clipping category button shadows.
        }
    }
}

// MARK: - Preview

struct AllToolsView_Preview: PreviewProvider {
    
    static func getToolsViewModel() -> ToolsViewModel {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        
        let viewModel = ToolsViewModel(
            flowDelegate: MockFlowDelegate(),
            dataDownloader: appDiContainer.dataLayer.getInitialDataDownloader(),
            localizationServices: appDiContainer.dataLayer.getLocalizationServices(),
            favoritingToolMessageCache: appDiContainer.dataLayer.getFavoritingToolMessageCache(),
            getAllToolsUseCase: appDiContainer.domainLayer.getAllToolsUseCase(),
            getLanguageAvailabilityUseCase: appDiContainer.domainLayer.getLanguageAvailabilityUseCase(),
            getSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getSettingsParallelLanguageUseCase(),
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            getSpotlightToolsUseCase: appDiContainer.domainLayer.getSpotlightToolsUseCase(),
            getToolCategoriesUseCase: appDiContainer.domainLayer.getToolCategoriesUseCase(),
            getToolIsFavoritedUseCase: appDiContainer.domainLayer.getToolIsFavoritedUseCase(),
            toggleToolFavoritedUseCase: appDiContainer.domainLayer.getToggleToolFavoritedUseCase(),
            attachmentsRepository: appDiContainer.dataLayer.getAttachmentsRepository(),
            analytics: appDiContainer.dataLayer.getAnalytics()
        )
        
        return viewModel
    }
    
    static var previews: some View {
        
        ToolsView(viewModel: AllToolsView_Preview.getToolsViewModel())
    }
}
