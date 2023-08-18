//
//  YourFavoriteToolsView.swift
//  godtools
//
//  Created by Rachael Skeath on 6/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct YourFavoriteToolsView: View {
        
    private let geometry: GeometryProxy
    private let contentHorizontalInsets: CGFloat
    private let toolCardSpacing: CGFloat
    
    @ObservedObject private var viewModel: FavoritesViewModel
        
    init(viewModel: FavoritesViewModel, geometry: GeometryProxy, contentHorizontalInsets: CGFloat, toolCardSpacing: CGFloat = DashboardView.toolCardVerticalSpacing) {
        
        self.viewModel = viewModel
        self.geometry = geometry
        self.contentHorizontalInsets = contentHorizontalInsets
        self.toolCardSpacing = toolCardSpacing
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
                        
            YourFavoriteToolsHeaderView(
                viewModel: viewModel,
                contentHorizontalInsets: contentHorizontalInsets
            )
            
            if viewModel.yourFavoriteTools.count > 0 {
                
                ScrollView(.horizontal, showsIndicators: false) {
                    
                    LazyHStack(alignment: .top, spacing: toolCardSpacing) {
                        
                        ForEach(viewModel.yourFavoriteTools) { (tool: ToolDomainModel) in
                            
                            ToolCardView(
                                viewModel: viewModel.getYourFavoriteToolViewModel(tool: tool),
                                geometry: geometry,
                                layout: .thumbnail,
                                favoriteTappedClosure: {
                                    
                                    viewModel.toolFavoriteTapped(tool: tool)
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
                        }
                    }
                    .padding([.leading, .trailing], contentHorizontalInsets)
                    .padding([.top, .bottom], 10) // NOTE: This is needed to prevent vertical clipping on ToolCardView shadows.  Not ideal, but a current solution.
                }
            }
            else {
                
                NoFavoriteToolsView(viewModel: viewModel)
                    .padding([.top], 12)
                    .padding([.leading, .trailing], contentHorizontalInsets)
            }
        }
    }
}

// MARK: - Preview

struct YourFavoriteToolsView_Preview: PreviewProvider {
    
    static var previews: some View {
        
        GeometryReader { geometry in
            
            YourFavoriteToolsView(
                viewModel: FavoritesView_Preview.getFavoritesViewModel(),
                geometry: geometry,
                contentHorizontalInsets: 20,
                toolCardSpacing: 15
            )
        }
    }
}
