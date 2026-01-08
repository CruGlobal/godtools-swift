//
//  PersonalizedToolToggle.swift
//  godtools
//
//  Created by Rachael Skeath on 12/11/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import SwiftUI

struct PersonalizedToolToggle<ViewModel: PersonalizedToolToggleViewModelProtocol>: View {

    @ObservedObject var viewModel: ViewModel

    var body: some View {
        
        EqualWidthHStack(spacing: 0) {
            
            ForEach(viewModel.toggleItems.indices, id: \.self) { index in
                
                Button {
                    viewModel.selectedIndexForToggle = index
                } label: {
                    
                    Text(viewModel.toggleItems[index])
                        .font(FontLibrary.sfProTextRegular.font(size: 12))
                        .foregroundColor(viewModel.selectedIndexForToggle == index ? .white : ColorPalette.gtBlue.color)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(viewModel.selectedIndexForToggle == index ? ColorPalette.gtBlue.color : Color.clear)
                }
            }
        }
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(ColorPalette.gtBlue.color, lineWidth: 1)
        )
    }
}
