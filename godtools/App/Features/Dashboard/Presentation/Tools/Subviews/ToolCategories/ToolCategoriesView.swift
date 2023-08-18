//
//  ToolCategoriesView.swift
//  godtools
//
//  Created by Rachael Skeath on 5/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolCategoriesView: View {
    
    private let contentHorizontalInsets: CGFloat
    
    @ObservedObject private var viewModel: ToolsViewModel
    
    init(viewModel: ToolsViewModel, contentHorizontalInsets: CGFloat) {
        
        self.viewModel = viewModel
        self.contentHorizontalInsets = contentHorizontalInsets
    }
        
    var body: some View {
        
        VStack(alignment: .leading) {
            
            Text(viewModel.categoriesTitle)
                .font(FontLibrary.sfProTextRegular.font(size: 22))
                .foregroundColor(ColorPalette.gtGrey.color)
                .padding(.leading, contentHorizontalInsets)
                .padding(.top, 28)
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                TwoRowHStack(itemCount: viewModel.categories.count, spacing: 15) { (index: Int) in
                    
                    ToolCategoryButtonView(
                        viewModel: viewModel.getCategoryButtonViewModel(index: index),
                        indexPosition: index,
                        selectedIndex: $viewModel.selectedCategoryIndex,
                        tappedClosure: {
                            
                            viewModel.categoryTapped(index: index)
                        }
                    )
                }
                .padding([.leading, .trailing], contentHorizontalInsets)
                .padding([.top, .bottom], 10) // NOTE: This is needed to prevent clipping category button shadows.
            }
        }
    }
}

// MARK: - Preview

struct ToolCategoriesView_Preview: PreviewProvider {
    
    static var previews: some View {
        
        ToolCategoriesView(
            viewModel: AllToolsView_Preview.getToolsViewModel(),
            contentHorizontalInsets: 15
        )
    }
}
