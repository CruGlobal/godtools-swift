//
//  ToolCategoryButtonView.swift
//  godtools
//
//  Created by Rachael Skeath on 5/18/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolCategoryButtonView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: ToolCategoryButtonViewModel
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            RoundedCardBackgroundView()
            
            Text(viewModel.category)
                .foregroundColor(viewModel.greyOutText ? .gray : .black)
                .font(FontLibrary.sfProTextBold.font(size: 18))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: 160, height: 74)
        .modifier(OptionalRoundedBorder(showBorder: $viewModel.showBorder, color: ColorPalette.gtBlue.color))
        
    }
}

struct ToolCategoryButtonView_Previews: PreviewProvider {
    static var previews: some View {
        let conversationStarterCategory = "Conversation Starter"
        let trainingCategory = "Training"
        
        ToolCategoryButtonView(viewModel: ToolCategoryButtonViewModel(category: conversationStarterCategory, selectedCategory: trainingCategory))
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
