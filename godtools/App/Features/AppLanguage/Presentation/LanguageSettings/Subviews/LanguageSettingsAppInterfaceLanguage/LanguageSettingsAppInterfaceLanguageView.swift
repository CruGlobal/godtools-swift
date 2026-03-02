//
//  LanguageSettingsAppInterfaceLanguageView.swift
//  godtools
//
//  Created by Levi Eggert on 9/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct LanguageSettingsAppInterfaceLanguageView: View {
    
    private let geometry: GeometryProxy
    private let contentHorizontalInsets: CGFloat
    
    @ObservedObject private var viewModel: LanguageSettingsViewModel
                
    init(viewModel: LanguageSettingsViewModel, geometry: GeometryProxy, contentHorizontalInsets: CGFloat) {
        
        self.viewModel = viewModel
        self.geometry = geometry
        self.contentHorizontalInsets = contentHorizontalInsets
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
         
            Text(viewModel.strings.appInterfaceLanguageTitle)
                .font(FontLibrary.sfProTextRegular.font(size: 26))
                .foregroundColor(ColorPalette.gtGrey.color)
                .multilineTextAlignment(.leading)
            
            Text(viewModel.strings.numberOfAppLanguagesAvailable)
                .font(FontLibrary.sfProTextRegular.font(size: 13))
                .foregroundColor(ColorPalette.gtGrey.color)
                .multilineTextAlignment(.leading)
                .padding([.top], 5)
            
            Text(viewModel.strings.setAppLanguageMessage)
                .font(FontLibrary.sfProTextRegular.font(size: 15))
                .foregroundColor(ColorPalette.gtGrey.color)
                .multilineTextAlignment(.leading)
                .padding([.top], 6)
            
            AppInterfaceLanguageButtonView(
                title: viewModel.strings.chooseAppLanguageButtonTitle,
                width: geometry.size.width - (contentHorizontalInsets * 2),
                height: 50,
                tappedClosure: {
                    
                    viewModel.chooseAppLanguageTapped()
                }
            )
            .padding([.top], 14)
        }
        .padding([.leading, .trailing], contentHorizontalInsets)
    }
}
