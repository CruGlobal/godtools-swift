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
        ZStack(alignment: .topLeading) {
            RoundedCardBackgroundView()
            
            Text(viewModel.category)
                .foregroundColor(viewModel.greyOutText ? .gray : .black)
                .font(FontLibrary.sfProTextBold.font(size: 18))
                .fixedSize(horizontal: false, vertical: true)
                .padding([.leading, .trailing], 20)
                .padding([.top, .bottom], 15)
        }
        .frame(width: 160, height: 74)
        .modifier(OptionalRoundedBorder(showBorder: $viewModel.showBorder, color: ColorPalette.gtBlue.color))
        
    }
}

struct ToolCategoryButtonView_Previews: PreviewProvider {
    static var previews: some View {
        let conversationStarterCategory = "Conversation Starter"
        let trainingCategory = "Training"
        let christianGrowth = "Christian Growth"
        
        ToolCategoryButtonView(viewModel: ToolCategoryButtonViewModel(category: christianGrowth, selectedCategory: trainingCategory))
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
