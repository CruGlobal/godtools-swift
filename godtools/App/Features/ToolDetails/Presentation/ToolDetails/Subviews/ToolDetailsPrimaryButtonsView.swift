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
    
    @ObservedObject private var viewModel: ToolDetailsViewModel
       
    let primaryButtonWidth: CGFloat
    
    init(viewModel: ToolDetailsViewModel, primaryButtonWidth: CGFloat) {
        
        self.viewModel = viewModel
        self.primaryButtonWidth = primaryButtonWidth
    }
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 12) {
            
            GTBlueButton(
                title: viewModel.strings.openToolActionTitle,
                fontSize: 17,
                width: primaryButtonWidth,
                height: primaryButtonHeight,
                cornerRadius: primaryButtonCornerRadius
            ){
                viewModel.openToolTapped()
            }
            
            if viewModel.showsLearnToShareToolButton {
                
                GTBlueButton(
                    title: viewModel.strings.learnToShareThisToolActionTitle,
                    fontSize: 17,
                    width: primaryButtonWidth,
                    height: primaryButtonHeight,
                    cornerRadius: primaryButtonCornerRadius,
                    accessibility: .learnToShare,
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
