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
    
    @ObservedObject var viewModel: ToolCategoriesViewModel
    let leadingPadding: CGFloat
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text(viewModel.categoryTitleText)
                .font(FontLibrary.sfProTextRegular.font(size: 22))
                .foregroundColor(ColorPalette.gtGrey.color)
                .padding(.leading, leadingPadding)
                .padding(.top, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                TwoRowHGrid(itemCount: viewModel.buttonViewModels.count, spacing: 15) { buttonIndex in
                    
                    if let buttonViewModel = viewModel.buttonViewModels[safe: buttonIndex] {
                        
                        ToolCategoryButtonView(viewModel: buttonViewModel)
                            .onTapGesture {
                                viewModel.categoryTapped(with: buttonViewModel)
                            }
                        
                    } else {
                        Spacer()
                    }
                }
                .padding([.leading, .trailing], leadingPadding)
                .padding([.top, .bottom], 8)
                .frame(height: 179) // TODO: - this is necessary to fix a layout issue on iOS 13.4.  Can be removed when we stop supporting 13.
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Preview

struct ToolCategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        
        let viewModel = ToolCategoriesViewModel(
            localizationServices: appDiContainer.dataLayer.getLocalizationServices(),
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            getToolCategoriesUseCase: appDiContainer.domainLayer.getToolCategoriesUseCase(),
            delegate: nil
        )
        
        ToolCategoriesView(viewModel: viewModel, leadingPadding: 20)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
