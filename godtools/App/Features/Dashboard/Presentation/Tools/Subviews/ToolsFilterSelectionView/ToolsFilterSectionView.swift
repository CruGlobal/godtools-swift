//
//  ToolsFilterSectionView.swift
//  godtools
//
//  Created by Rachael Skeath on 9/11/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct ToolsFilterSectionView: View {
    
    private let contentHorizontalInsets: CGFloat
    private let width: CGFloat
    
    @ObservedObject private var viewModel: ToolsViewModel
    
    init(viewModel: ToolsViewModel, contentHorizontalInsets: CGFloat = DashboardView.contentHorizontalInsets, width: CGFloat) {
        
        self.viewModel = viewModel
        self.contentHorizontalInsets = contentHorizontalInsets
        self.width = width
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 8) {
            
            Text(viewModel.filterTitle)
                .font(FontLibrary.sfProTextRegular.font(size: 22))
                .foregroundColor(ColorPalette.gtGrey.color)
                .padding(.leading, contentHorizontalInsets)
            
            let buttonSpacing: CGFloat = 11
            
            HStack(spacing: buttonSpacing) {
                let buttonWidth = (width - (contentHorizontalInsets * 2) - buttonSpacing) / 2
                ToolFilterButtonView(
                    title: viewModel.categoryFilterButtonTitle,
                    width: buttonWidth,
                    tappedClosure: {
                        
                        viewModel.toolCategoryFilterTapped()
                    }
                )
                
                ToolFilterButtonView(
                    title: viewModel.languageFilterButtonTitle,
                    width: buttonWidth,
                    tappedClosure: {
                        
                        viewModel.toolLanguageFilterTapped()
                    }
                )
                
            }
            .padding([.leading, .trailing], contentHorizontalInsets)
            .padding(.bottom, 10) // NOTE: This is needed to prevent clipping filter button shadows.
        }
    }
}
