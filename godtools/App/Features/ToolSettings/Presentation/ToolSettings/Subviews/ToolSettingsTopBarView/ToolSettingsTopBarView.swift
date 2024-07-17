//
//  ToolSettingsTopBarView.swift
//  godtools
//
//  Created by Levi Eggert on 5/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolSettingsTopBarView: View {
        
    @ObservedObject private var viewModel: ToolSettingsViewModel
    
    let leadingInset: CGFloat
    let trailingInset: CGFloat
    
    init(viewModel: ToolSettingsViewModel, leadingInset: CGFloat, trailingInset: CGFloat) {
        
        self.viewModel = viewModel
        self.leadingInset = leadingInset
        self.trailingInset = trailingInset
    }
    
    var body: some View {
        HStack {
            Text(viewModel.title)
                .foregroundColor(ColorPalette.gtGrey.color)
                .font(FontLibrary.sfProTextRegular.font(size: 23))
            Spacer()
            Button {
                viewModel.closeTapped()
            } label: {
                Image(ImageCatalog.navClose.name)
            }
            .frame(minWidth: 44, minHeight: 44)
        }
        .padding(EdgeInsets(top: 0, leading: leadingInset, bottom: 0, trailing: trailingInset))
        .frame(height: 50)
    }
}
