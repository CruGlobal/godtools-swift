//
//  ToolCategoriesView.swift
//  godtools
//
//  Created by Rachael Skeath on 5/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolCategoriesView: View {
    
    // MARK: - Properties
    
    var viewModel: ToolCategoriesViewModel
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text("Categories")
                .font(FontLibrary.sfProTextRegular.font(size: 22))
            
            ScrollView {
                
                TwoRowHGrid(itemCount: viewModel.buttonViewModels.count, spacing: 15) { buttonIndex in
                    
                    let buttonViewModel = viewModel.buttonViewModels[buttonIndex]
                    ToolCategoryButtonView(viewModel: buttonViewModel)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Preview

struct ToolCategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        ToolCategoriesView(viewModel: ToolCategoriesViewModel())
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
