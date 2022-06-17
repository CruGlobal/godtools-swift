//
//  ToolDetailsPrimaryButtonsView.swift
//  godtools
//
//  Created by Levi Eggert on 6/9/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolDetailsPrimaryButtonsView: View {
    
    private let primaryButtonHeight: CGFloat = 55
    private let primaryButtonCornerRadius: CGFloat = 8
    
    @ObservedObject var viewModel: ToolDetailsViewModel
       
    let primaryButtonWidth: CGFloat
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 12) {
            
            Button(action: {
                viewModel.openToolTapped()
            }) {
                Text(viewModel.openToolButtonTitle)
                    .foregroundColor(Color.white)
            }
            .frame(width: primaryButtonWidth, height: primaryButtonHeight, alignment: .center)
            .background(ColorPalette.gtBlue.color)
            .cornerRadius(primaryButtonCornerRadius)
            
            if !viewModel.hidesLearnToShareToolButton {
                
                Button(action: {
                    viewModel.learnToShareToolTapped()
                }) {
                    Text(viewModel.learnToShareToolButtonTitle)
                        .foregroundColor(Color.white)
                }
                .frame(width: primaryButtonWidth, height: primaryButtonHeight, alignment: .center)
                .background(ColorPalette.gtBlue.color)
                .cornerRadius(primaryButtonCornerRadius)
            }
            
            ToolDetailsToggleFavoriteButton(
                viewModel: viewModel,
                width: primaryButtonWidth,
                height: primaryButtonHeight,
                cornerRadius: primaryButtonCornerRadius
            )
        }
    }
}
