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
            
            Text(viewModel.categoryText)
                .foregroundColor(viewModel.greyOutText ? Color.gray : ColorPalette.gtGrey.color)
                .font(FontLibrary.sfProTextBold.font(size: 18))
                .lineLimit(2)
                .minimumScaleFactor(0.5)
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
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        let category = ToolCategoryDomainModel(id: "1", translatedName: "Conversation Starter")
        let viewModel = ToolCategoryButtonViewModel(
            category: category,
            selectedCategoryId: "1",
            localizationServices: appDiContainer.localizationServices)
        
        ToolCategoryButtonView(viewModel: viewModel)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
