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
    @State private var footerHeight: CGFloat = 0
    @State private var showFooter: Bool = true
    
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

            ZStack(alignment: .bottom) {

                VStack(alignment: .center, spacing: 0) {

                    PersonalizedToolToggle(selectedToggle: $viewModel.selectedToggle, toggleOptions: viewModel.toggleOptions)
                        .padding(.top, 5)

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

                                ForEach(viewModel.allTools) { (tool: ToolListItemDomainModel) in

                                    ToolCardView(
                                        viewModel: viewModel.getToolItemViewModel(tool: tool),
                                        geometry: geometry,
                                        layout: .landscape,
                                        showsCategory: true,
                                        navButtonTitleHorizontalPadding: nil,
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
                        .padding([.bottom], (viewModel.selectedToggle == .personalized ? footerHeight : 0) + DashboardView.scrollViewBottomSpacingToTabBar)

                    } refreshHandler: {

                        viewModel.pullToRefresh()
                    }
                    .opacity(viewModel.isLoadingAllTools ? 0 : 1)
                    .animation(.easeOut, value: !viewModel.isLoadingAllTools)
                    .animation(.spring(response: 0.5, dampingFraction: 0.75), value: viewModel.selectedToggle)
                }

                PersonalizedToolFooterView(
                    title: viewModel.strings.personalizedToolFooterTitle,
                    subtitle: viewModel.strings.personalizedToolFooterSubtitle,
                    buttonTitle: viewModel.strings.personalizedToolFooterButtonTitle,
                    onHeightChanged: { height in
                        footerHeight = height
                    },
                    buttonAction: {
                        viewModel.localizationSettingsTapped()
                    }
                )
                .offset(y: showFooter ? 0 : footerHeight)
                .animation(.spring(response: 0.5, dampingFraction: 0.75), value: showFooter)
            }
        }
        .onChange(of: viewModel.selectedToggle) { newSelection in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                showFooter = newSelection == .personalized
            }
        }
        .onAppear {
            showFooter = viewModel.selectedToggle == .personalized
            viewModel.pageViewed()
        }
    }
}

// MARK: - Preview

struct AllToolsView_Preview: PreviewProvider {
    
    static func getToolsViewModel() -> ToolsViewModel {
        
        let appDiContainer = AppDiContainer.createUITestsDiContainer()
        
        let viewModel = ToolsViewModel(
            flowDelegate: MockFlowDelegate(),
            resourcesRepository: appDiContainer.dataLayer.getResourcesRepository(),
            viewToolsUseCase: appDiContainer.feature.dashboard.domainLayer.getViewToolsUseCase(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            favoritingToolMessageCache: appDiContainer.dataLayer.getFavoritingToolMessageCache(),
            getSpotlightToolsUseCase: appDiContainer.feature.spotlightTools.domainLayer.getSpotlightToolsUseCase(),
            getUserToolFiltersUseCase: appDiContainer.feature.toolsFilter.domainLayer.getUserToolFiltersUseCase(),
            getToolIsFavoritedUseCase: appDiContainer.feature.favorites.domainLayer.getToolIsFavoritedUseCase(),
            toggleToolFavoritedUseCase: appDiContainer.feature.favorites.domainLayer.getToggleFavoritedToolUseCase(),
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
