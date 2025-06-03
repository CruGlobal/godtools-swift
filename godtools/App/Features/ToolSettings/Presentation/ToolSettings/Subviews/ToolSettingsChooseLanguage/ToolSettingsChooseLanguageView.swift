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
        
    init(viewModel: ToolSettingsViewModel) {
        
        self.viewModel = viewModel
    }
        
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            VStack(alignment: .leading, spacing: 4) {
                
                Text(viewModel.chooseLanguageTitle)
                    .foregroundColor(ColorPalette.gtGrey.color)
                    .font(FontLibrary.sfProTextRegular.font(size: 19))
                
                Text(viewModel.chooseLanguageToggleMessage)
                    .foregroundColor(ColorPalette.gtGrey.color)
                    .font(FontLibrary.sfProTextRegular.font(size: 14))
            }
            .padding([.bottom], 20)
                        
            HStack(alignment: .top, spacing: 0) {
                
                ToolSettingsLanguageDropDownView(title: viewModel.primaryLanguageTitle)
                    .onTapGesture {
                        viewModel.primaryLanguageTapped()
                    }
                
                Button {
                    viewModel.swapLanguageTapped()
                } label: {
                    ImageCatalog.toolSettingsSwapLanguage.image
                }
                .frame(minWidth: 44, maxHeight: .infinity)
                
                ToolSettingsLanguageDropDownView(title: viewModel.parallelLanguageTitle)
                    .onTapGesture {
                        viewModel.parallelLanguageTapped()
                    }
            }
            .background(Color(.sRGB, red: 245 / 256, green: 245 / 256, blue: 245 / 256, opacity: 1))
            .cornerRadius(6)
            .frame(height: languageDropDownHeight)
        }
    }
}

