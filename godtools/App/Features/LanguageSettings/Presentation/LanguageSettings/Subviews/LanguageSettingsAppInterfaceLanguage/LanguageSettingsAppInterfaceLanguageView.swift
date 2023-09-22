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
    
    @ObservedObject private var viewModel: LanguageSettingsViewModel
                
    init(viewModel: LanguageSettingsViewModel, geometry: GeometryProxy) {
        
        self.viewModel = viewModel
        self.geometry = geometry
    }
    
    var body: some View {
        
        Text(viewModel.appInterfaceLanguageTitle)
            .font(FontLibrary.sfProTextRegular.font(size: 26))
            .foregroundColor(ColorPalette.gtGrey.color)
            .multilineTextAlignment(.leading)
        
        Text(viewModel.numberOfLanguagesAvailable)
            .font(FontLibrary.sfProTextRegular.font(size: 12))
            .foregroundColor(ColorPalette.gtGrey.color)
            .multilineTextAlignment(.leading)
        
        Text(viewModel.setLanguageYouWouldLikeAppDisplayedInLabel)
            .font(FontLibrary.sfProTextRegular.font(size: 14))
            .foregroundColor(ColorPalette.gtGrey.color)
            .multilineTextAlignment(.leading)
        
        AppInterfaceLanguageButtonView(
            title: viewModel.appInterfaceLanguageButtonTitle,
            width: geometry.size.width,
            height: 50
        )
    }
}
