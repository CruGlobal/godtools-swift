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
            
            GTButton(
                style: .blue,
                title: viewModel.strings.openToolActionTitle,
                fontSize: 17,
                width: primaryButtonWidth,
                height: primaryButtonHeight,
                cornerRadius: primaryButtonCornerRadius,
                tapped: {
                    viewModel.openToolTapped()
                }
            )
            
            if viewModel.showsLearnToShareToolButton {
                
                GTButton(
                    style: .blue,
                    title: viewModel.strings.learnToShareThisToolActionTitle,
                    fontSize: 17,
                    width: primaryButtonWidth,
                    height: primaryButtonHeight,
                    cornerRadius: primaryButtonCornerRadius,
                    accessibility: .learnToShare,
                    tapped: {
                        viewModel.learnToShareToolTapped()
                    }
                )
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
