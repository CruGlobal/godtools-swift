//
//  ToolCategoryButtonView.swift
//  godtools
//
//  Created by Rachael Skeath on 5/18/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolCategoryButtonView: View {
        
    @ObservedObject private var viewModel: ToolCategoryButtonViewModel
    
    init(viewModel: ToolCategoryButtonViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedCardBackgroundView()
                .frame(width: 160, height: 74)
            
            VStack {
                Spacer(minLength: 0)
                Spacer(minLength: 0)
                
                Text(viewModel.categoryText)
                    .foregroundColor(viewModel.greyOutText ? Color.gray : ColorPalette.gtGrey.color)
                    .font(FontLibrary.sfProTextBold.font(size: 18))
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding([.leading, .trailing], 20)
                
                Spacer(minLength: 0)
                Spacer(minLength: 0)
                Spacer(minLength: 0)
            }
        }
        .frame(width: 160, height: 74)
        .modifier(OptionalRoundedBorder(showBorder: $viewModel.showBorder, color: ColorPalette.gtBlue.color))
        
    }
}

struct ToolCategoryButtonView_Previews: PreviewProvider {
    static var previews: some View {
        
        let viewModel = ToolCategoryButtonViewModel(
            category: ToolCategoryDomainModel(type: .category(id: "1"), translatedName: "Conversation Starter"),
            selectedCategoryId: "1"
        )
        
        ToolCategoryButtonView(viewModel: viewModel)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
