//
//  ToolLanguagesAvailableOfflineView.swift
//  godtools
//
//  Created by Levi Eggert on 11/30/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct ToolLanguagesAvailableOfflineView: View {
    
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
         
            Text(viewModel.toolLanguagesAvailableOfflineTitle)
                .font(FontLibrary.sfProTextRegular.font(size: 26))
                .foregroundColor(ColorPalette.gtGrey.color)
                .multilineTextAlignment(.leading)
            
            Text(viewModel.downloadToolsForOfflineMessage)
                .font(FontLibrary.sfProTextRegular.font(size: 15))
                .foregroundColor(ColorPalette.gtGrey.color)
                .multilineTextAlignment(.leading)
                .padding([.top], 12)
            
            SeparatorView()
                .padding([.top], 11)
            
            ScrollView(.vertical, showsIndicators: true) {
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    ForEach(viewModel.downloadedLanguages) { downloadedLanguage in
                        
                        ToolLanguageAvailableOfflineLanguageView(downloadedLanguage: downloadedLanguage)
                    }
                }
            }
            
            GTBlueButton(
                title: viewModel.editDownloadedLanguagesButtonTitle,
                font: FontLibrary.sfProTextRegular.font(size: 14),
                width: geometry.size.width - (contentHorizontalInsets * 2),
                height: 50,
                action: {
                    
                    viewModel.editDownloadedLanguagesTapped()
                }
            )
            .padding([.top], 25)
        }
        .padding([.leading, .trailing], contentHorizontalInsets)
    }
}
