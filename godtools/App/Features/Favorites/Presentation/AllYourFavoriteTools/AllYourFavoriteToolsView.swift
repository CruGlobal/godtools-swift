//
//  AllYourFavoriteToolsView.swift
//  godtools
//
//  Created by Rachael Skeath on 6/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct AllYourFavoriteToolsView: View {
        
    private let contentHorizontalInsets: CGFloat
    private let toolCardSpacing: CGFloat
    
    @ObservedObject private var viewModel: AllYourFavoriteToolsViewModel
        
    init(viewModel: AllYourFavoriteToolsViewModel, contentHorizontalInsets: CGFloat = DashboardView.contentHorizontalInsets, toolCardSpacing: CGFloat = DashboardView.toolCardVerticalSpacing) {
        
        self.viewModel = viewModel
        self.contentHorizontalInsets = contentHorizontalInsets
        self.toolCardSpacing = toolCardSpacing
    }
    
    var body: some View {
        
        GeometryReader { geometry in
                    
            VStack(alignment: .leading, spacing: 0) {
                List {
                    Text(viewModel.sectionTitle)
                        .font(FontLibrary.sfProTextRegular.font(size: 22))
                        .foregroundColor(ColorPalette.gtGrey.color)
                        .listRowSeparator(.hidden)
                    
                    ForEach(viewModel.favoritedTools) { (tool: YourFavoritedToolDomainModel) in
                        ToolCardView(
                            viewModel: viewModel.getToolViewModel(tool: tool),
                            geometry: geometry,
                            layout: .landscape,
                            showsCategory: true,
                            navButtonTitleHorizontalPadding: YourFavoriteToolsView.toolCardNavButtonTitleHorizontalPadding,
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
                .listStyle(.plain)
            }
        }
        .navigationBarBackButtonHidden(true)
        .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
        .onAppear {
            viewModel.pageViewed()
        }
    }
}

// MARK: - Preview

struct AllYourFavoriteToolsView_Preview: PreviewProvider {
    
    static var previews: some View {
        
        let appDiContainer = AppDiContainer.createUITestsDiContainer()
        
        let viewModel = AllYourFavoriteToolsViewModel(
            flowDelegate: MockFlowDelegate(),
            viewAllYourFavoritedToolsUseCase: appDiContainer.feature.favorites.domainLayer.getViewAllYourFavoritedToolsUseCase(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getToolIsFavoritedUseCase: appDiContainer.feature.favorites.domainLayer.getToolIsFavoritedUseCase(),
            reorderFavoritedToolUseCase: appDiContainer.feature.favorites.domainLayer.getReorderFavoritedToolUseCase(),
            getToolBannerUseCase: appDiContainer.domainLayer.getToolBannerUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.domainLayer.getTrackScreenViewAnalyticsUseCase(),
            trackActionAnalyticsUseCase: appDiContainer.domainLayer.getTrackActionAnalyticsUseCase()
        )
        
        AllYourFavoriteToolsView(viewModel: viewModel)
    }
}
