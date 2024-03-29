//
//  ToolDetailsTitleHeaderView.swift
//  godtools
//
//  Created by Levi Eggert on 6/9/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolDetailsTitleHeaderView: View {
    
    @ObservedObject private var viewModel: ToolDetailsViewModel
    
    init(viewModel: ToolDetailsViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            Text(viewModel.name)
                .foregroundColor(ColorPalette.gtGrey.color)
                .font(FontLibrary.sfProDisplayLight.font(size: 28))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(viewModel.totalViews)
                .foregroundColor(ColorPalette.gtGrey.color)
                .font(FontLibrary.sfProTextRegular.font(size: 16))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(EdgeInsets(top: 18, leading: 0, bottom: 0, trailing: 0))
        }
    }
}
