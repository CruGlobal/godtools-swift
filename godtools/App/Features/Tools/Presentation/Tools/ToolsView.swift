//
//  ToolsView.swift
//  godtools
//
//  Created by Rachael Skeath on 4/6/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolsView: View {

    static let personalizedToggleTopPadding: CGFloat = (DashboardView.navHeight * -1) + (DashboardView.navHeight / 2) - (PersonalizedToolToggle.height / 2)
    
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

            VStack(alignment: .center, spacing: 0) {

                PersonalizedToolToggle(
                    selectedToggle: $viewModel.selectedToggle,
                    toggleOptions: viewModel.toggleOptions,
                )
                .padding([.top], Self.personalizedToggleTopPadding)

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

                        if viewModel.selectedToggle == .personalized {
                            PersonalizedToolFooterView(
                                title: viewModel.strings.personalizedToolExplanationTitle,
                                subtitle: viewModel.strings.personalizedToolExplanationSubtitle,
                                buttonTitle: viewModel.strings.changePersonalizedToolSettingsActionLabel,
                                buttonAction: {
                                    viewModel.localizationSettingsTapped()
                                }
                            )
                            .padding(.top, toolCardSpacing)
                        }
                    }
                    .padding([.bottom], 0)

                } refreshHandler: {

                    viewModel.pullToRefresh()
                }
                .opacity(viewModel.isLoadingAllTools ? 0 : 1)
                .animation(.easeOut, value: !viewModel.isLoadingAllTools)
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.75), value: viewModel.selectedToggle)
        }
        .onAppear {
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
            pullToRefreshToolsUseCase: appDiContainer.feature.tools.domainLayer.getPullToRefreshToolsUseCase(),
            getToolsStringsUseCase: appDiContainer.feature.tools.domainLayer.getToolsStringsUseCase(),
            getAllToolsUseCase: appDiContainer.feature.tools.domainLayer.getAllToolsUseCase(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getLocalizationSettingsUseCase: appDiContainer.feature.personalizedTools.domainLayer.getGetLocalizationSettingsUseCase(),
            favoritingToolMessageCache: appDiContainer.dataLayer.getFavoritingToolMessageCache(),
            getSpotlightToolsUseCase: appDiContainer.feature.spotlightTools.domainLayer.getSpotlightToolsUseCase(),
            getUserToolFiltersUseCase: appDiContainer.feature.toolsFilter.domainLayer.getUserToolFiltersUseCase(),
            getToolIsFavoritedUseCase: appDiContainer.feature.favorites.domainLayer.getToolIsFavoritedUseCase(),
            toggleToolFavoritedUseCase: appDiContainer.feature.favorites.domainLayer.getToggleToolFavoritedUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.domainLayer.getTrackScreenViewAnalyticsUseCase(),
            trackActionAnalyticsUseCase: appDiContainer.domainLayer.getTrackActionAnalyticsUseCase(),
            getToolBannerUseCase: appDiContainer.domainLayer.getToolBannerUseCase()
        )
        
        return viewModel
    }
    
    static var previews: some View {
        
        ToolsView(viewModel: AllToolsView_Preview.getToolsViewModel())
    }
}
