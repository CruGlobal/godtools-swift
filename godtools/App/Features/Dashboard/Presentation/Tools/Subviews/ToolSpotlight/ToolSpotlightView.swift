//
//  ToolSpotlightView.swift
//  godtools
//
//  Created by Rachael Skeath on 5/10/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolSpotlightView: View {
        
    private let geometry: GeometryProxy
    private let contentHorizontalInsets: CGFloat
    
    @ObservedObject private var viewModel: ToolsViewModel
    
    init(viewModel: ToolsViewModel, geometry: GeometryProxy, contentHorizontalInsets: CGFloat) {
        
        self.viewModel = viewModel
        self.geometry = geometry
        self.contentHorizontalInsets = contentHorizontalInsets
    }
        
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            Text(viewModel.toolSpotlightTitle)
                .font(FontLibrary.sfProTextRegular.font(size: 22))
                .foregroundColor(ColorPalette.gtGrey.color)
                .padding([.leading, .trailing], contentHorizontalInsets)
                        
            Text(viewModel.toolSpotlightSubtitle)
                .font(FontLibrary.sfProTextRegular.font(size: 14))
                .foregroundColor(ColorPalette.gtGrey.color)
                .padding([.top], 3)
                .padding([.leading, .trailing], contentHorizontalInsets)
            
            FixedVerticalSpacer(height: 3)
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                // NOTE: We need HStack here instead of LazyHStack because our card heights have dynamic heights to them and this allows the HStack to wrap the tallest card.
                HStack(alignment: .top, spacing: 15) {
                    
                    ForEach(viewModel.spotlightTools) { (spotlightTool: ToolDomainModel) in
                        
                        ToolCardView(
                            viewModel: viewModel.getToolViewModel(tool: spotlightTool),
                            geometry: geometry,
                            layout: .thumbnail,
                            favoriteTappedClosure: {
                                
                                viewModel.spotlightToolFavorited(spotlightTool: spotlightTool)
                            },
                            toolDetailsTappedClosure: nil,
                            openToolTappedClosure: nil,
                            toolTappedClosure: {
                                
                                viewModel.spotlightToolTapped(spotlightTool: spotlightTool)
                            }
                        )
                    }
                }
                .padding([.leading, .trailing], contentHorizontalInsets)
            }
            .padding([.top], 10)
        }
    }
}

// MARK: - Preview

struct ToolSpotlightView_Preview: PreviewProvider {
    
    static var previews: some View {
        
        GeometryReader { geometry in
            
            ToolSpotlightView(
                viewModel: AllToolsView_Preview.getToolsViewModel(),
                geometry: geometry,
                contentHorizontalInsets: 15
            )
        }
    }
}
