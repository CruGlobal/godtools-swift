//
//  ToolSettingsChooseLanguageView.swift
//  godtools
//
//  Created by Levi Eggert on 5/10/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolSettingsChooseLanguageView: View {
    
    private let languageDropDownHeight: CGFloat = 52
    
    @ObservedObject private var viewModel: ToolSettingsViewModel
    
    let geometryProxy: GeometryProxy
    let leadingInset: CGFloat
    let trailingInset: CGFloat
    
    init(viewModel: ToolSettingsViewModel, geometryProxy: GeometryProxy, leadingInset: CGFloat, trailingInset: CGFloat) {
        
        self.viewModel = viewModel
        self.geometryProxy = geometryProxy
        self.leadingInset = leadingInset
        self.trailingInset = trailingInset
    }
        
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack (alignment: .leading, spacing: 4) {
                Text(viewModel.chooseLanguageTitle)
                    .foregroundColor(ColorPalette.gtGrey.color)
                    .font(FontLibrary.sfProTextRegular.font(size: 19))
                Text(viewModel.chooseLanguageToggleMessage)
                    .frame(maxWidth: geometryProxy.size.width * 0.65, alignment: .leading)
                    .foregroundColor(ColorPalette.gtGrey.color)
                    .font(FontLibrary.sfProTextRegular.font(size: 14))
            }
            .padding(EdgeInsets(top: 0, leading: leadingInset, bottom: 0, trailing: 0))
            Rectangle()
                .frame(width: geometryProxy.size.width, height: 20, alignment: .leading)
                .foregroundColor(.clear)
            HStack(alignment: .top, spacing: 0) {
                ToolSettingsLanguageDropDownView(title: viewModel.primaryLanguageTitle)
                    .onTapGesture {
                        viewModel.primaryLanguageTapped()
                    }
                Button {
                    viewModel.swapLanguageTapped()
                } label: {
                    Image(ImageCatalog.toolSettingsSwapLanguage.name)
                }
                .frame(minWidth: 44, maxHeight: .infinity)
                ToolSettingsLanguageDropDownView(title: viewModel.parallelLanguageTitle)
                    .onTapGesture {
                        viewModel.parallelLanguageTapped()
                    }
            }
            .background(Color(.sRGB, red: 245 / 256, green: 245 / 256, blue: 245 / 256, opacity: 1))
            .cornerRadius(6)
            .frame(
                minWidth: nil,
                idealWidth: nil,
                maxWidth: .infinity,
                minHeight: languageDropDownHeight,
                idealHeight: nil,
                maxHeight: languageDropDownHeight,
                alignment: .leading
            )
            .padding(EdgeInsets(top: 0, leading: leadingInset, bottom: 0, trailing: trailingInset))
        }
    }
}
