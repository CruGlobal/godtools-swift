//
//  ToolCategoriesView.swift
//  godtools
//
//  Created by Rachael Skeath on 5/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolCategoriesView: View {
    
    private let buttonSpacing: CGFloat = 11
    private let contentHorizontalInsets: CGFloat
    
    private let geometry: GeometryProxy
    @ObservedObject private var viewModel: ToolsViewModel
    
    init(viewModel: ToolsViewModel, geometry: GeometryProxy, contentHorizontalInsets: CGFloat) {
        
        self.viewModel = viewModel
        self.geometry = geometry
        self.contentHorizontalInsets = contentHorizontalInsets
    }
        
    var body: some View {
        
        VStack(alignment: .leading) {
            
            Text(viewModel.categoriesTitle)
                .font(FontLibrary.sfProTextRegular.font(size: 22))
                .foregroundColor(ColorPalette.gtGrey.color)
                .padding(.leading, contentHorizontalInsets)
                .padding(.top, 28)
            
            HStack(spacing: buttonSpacing) {
                let buttonWidth = (geometry.size.width - (contentHorizontalInsets*2) - buttonSpacing) / 2
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

struct ToolCategoriesView_Preview: PreviewProvider {
    
    static var previews: some View {
        
        GeometryReader { geo in
            
            ToolCategoriesView(
                viewModel: AllToolsView_Preview.getToolsViewModel(), geometry: geo,
                contentHorizontalInsets: 15
            )
        }
    }
}
