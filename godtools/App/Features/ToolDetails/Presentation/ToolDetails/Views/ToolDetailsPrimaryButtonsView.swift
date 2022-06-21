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
            
            GTBlueButton(
                title: viewModel.openToolButtonTitle,
                fontSize: 17,
                width: primaryButtonWidth,
                height: primaryButtonHeight,
                cornerRadius: primaryButtonCornerRadius
            ){
                viewModel.openToolTapped()
            }
            
            if !viewModel.hidesLearnToShareToolButton {
                
                GTBlueButton(
                    title: viewModel.learnToShareToolButtonTitle,
                    fontSize: 17,
                    width: primaryButtonWidth,
                    height: primaryButtonHeight,
                    cornerRadius: primaryButtonCornerRadius
                ) {
                    viewModel.learnToShareToolTapped()
                }
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
