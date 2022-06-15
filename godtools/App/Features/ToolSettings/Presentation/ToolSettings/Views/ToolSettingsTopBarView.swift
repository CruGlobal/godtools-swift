//
//  ToolSettingsTopBarView.swift
//  ToolSettings
//
//  Created by Levi Eggert on 5/11/22.
//

import SwiftUI

struct ToolSettingsTopBarView: View {
        
    @ObservedObject var viewModel: ToolSettingsViewModel
    
    let primaryTextColor: Color
    let leadingInset: CGFloat
    let trailingInset: CGFloat
    
    var body: some View {
        HStack {
            Text(viewModel.title)
                .foregroundColor(primaryTextColor)
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
