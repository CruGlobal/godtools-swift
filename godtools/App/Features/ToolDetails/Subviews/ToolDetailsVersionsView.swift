//
//  ToolDetailsVersionsView.swift
//  godtools
//
//  Created by Levi Eggert on 6/9/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolDetailsVersionsView: View {
        
    @ObservedObject var viewModel: ToolDetailsViewModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            Text(viewModel.versionsMessage)
                .foregroundColor(ColorPalette.gtGrey.color)
                .font(FontLibrary.sfProTextRegular.font(size: 16))
                .multilineTextAlignment(.center)
                .padding(EdgeInsets(top: 0, leading: 30, bottom: 10, trailing: 30))
            
            ForEach(viewModel.toolVersions) { toolVersion in
                                
                ToolDetailsVersionsCardView(
                    viewModel: viewModel.getToolVersionCardViewModel(toolVersion: toolVersion)
                )
                .onTapGesture {
                    viewModel.toolVersionTapped(toolVersion: toolVersion)
                }
            }
        }
    }
}
