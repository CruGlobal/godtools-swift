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

                        if viewModel.selectedToggle == .personalized, let personalizedToolsUnavailable = viewModel.personalizedTools.unavailableStrings {

                            PersonalizationUnavailableView(
                                title: personalizedToolsUnavailable.title,
                                message: personalizedToolsUnavailable.message,
                                changeSettingsButtonTitle: viewModel.strings.changePersonalizedToolSettingsActionLabel,
                                goToAllLessonsButtonTitle: viewModel.strings.viewAllTools,
                                geometry: geometry,
                                heightMultiplier: 0.45,
                                changeSettingsAction: {
                                    viewModel.localizationSettingsTapped()
                                },
                                goToAllLessonsAction: {
                                    viewModel.goToAllToolsTapped()
                                }
                            )
                        }
                        else if !viewModel.toolsList.isEmpty {
                            
                            LazyVStack(alignment: .center, spacing: toolCardSpacing) {
                                ForEach(viewModel.toolsList) { (tool: ToolListItemDomainModel) in

                                    ToolCardView(
                                        viewModel: viewModel.getToolItemViewModel(tool: tool),
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
                        
                        if viewModel.selectedToggle == .personalized && viewModel.personalizedTools.unavailableStrings == nil {
                            
                            PersonalizedToolFooterView(
                                geometry: geometry,
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
            stepEmitter: PreviewFlowStepEmitter.emitter,
            pullToRefreshToolsUseCase: appDiContainer.feature.tools.domainLayer.getPullToRefreshToolsUseCase(),
            getToolsStringsUseCase: appDiContainer.feature.tools.domainLayer.getToolsStringsUseCase(),
            getAllToolsUseCase: appDiContainer.feature.tools.domainLayer.getAllToolsUseCase(),
            getPersonalizedToolsUseCase: appDiContainer.feature.personalizedTools.domainLayer.getPersonalizedToolsUseCase(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getLocalizationSettingsUseCase: appDiContainer.feature.personalizedTools.domainLayer.getLocalizationSettingsUseCase(),
            favoritingToolMessageCache: appDiContainer.core.dataLayer.getFavoritingToolMessageCache(),
            getSpotlightToolsUseCase: appDiContainer.feature.spotlightTools.domainLayer.getSpotlightToolsUseCase(),
            getUserToolFilterCategoryUseCase: appDiContainer.feature.toolsFilter.domainLayer.getUserToolFilterCategoryUseCase(),
            getUserToolFilterLanguageUseCase: appDiContainer.feature.toolsFilter.domainLayer.getUserToolFilterLanguageUseCase(),
            getToolIsFavoritedUseCase: appDiContainer.feature.favorites.domainLayer.getToolIsFavoritedUseCase(),
            toggleToolFavoritedUseCase: appDiContainer.feature.favorites.domainLayer.getToggleToolFavoritedUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.core.domainLayer.getTrackScreenViewAnalyticsUseCase(),
            trackActionAnalyticsUseCase: appDiContainer.core.domainLayer.getTrackActionAnalyticsUseCase(),
            getToolBannerUseCase: appDiContainer.core.domainLayer.getToolBannerUseCase(),
            inMemoryDataCache: appDiContainer.core.dataLayer.getSharedInMemoryDataCache()
        )
        
        return viewModel
    }
    
    static var previews: some View {
        
        ToolsView(viewModel: AllToolsView_Preview.getToolsViewModel())
    }
}
