//
//  ToolFilterSelectionRowView.swift
//  godtools
//
//  Created by Rachael Skeath on 8/30/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct ToolFilterSelectionRowView: View {
    
    private static let lightGrey = Color.getColorWithRGB(red: 151, green: 151, blue: 151, opacity: 1)
    
    @ObservedObject private var viewModel: ToolFilterSelectionRowViewModel
    
    init(viewModel: ToolFilterSelectionRowViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            
            HStack(spacing: 9.5) {
                
                Text(viewModel.title)
                    .font(FontLibrary.sfProTextRegular.font(size: 15))
                    .foregroundColor(ColorPalette.gtGrey.color)
                
                if let subtitle = viewModel.subtitle {
                    
                    Text(subtitle)
                        .font(FontLibrary.sfProTextRegular.font(size: 15))
                        .foregroundColor(ToolFilterSelectionRowView.lightGrey)
                }
            }
            
            Text(viewModel.toolsAvailableText)
                .font(FontLibrary.sfProTextRegular.font(size: 12))
                .foregroundColor(ToolFilterSelectionRowView.lightGrey)
        }
        .padding(.vertical, 7)
    }
}
