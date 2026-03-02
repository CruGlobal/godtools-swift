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
    
    @State private var contentSize: CGSize = CGSize(width: 100, height: 100)
                
    init(viewModel: LanguageSettingsViewModel, geometry: GeometryProxy, contentHorizontalInsets: CGFloat) {
        
        self.viewModel = viewModel
        self.geometry = geometry
        self.contentHorizontalInsets = contentHorizontalInsets
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
         
            Text(viewModel.strings.toolLanguagesAvailableOfflineTitle)
                .font(FontLibrary.sfProTextRegular.font(size: 26))
                .foregroundColor(ColorPalette.gtGrey.color)
                .multilineTextAlignment(.leading)
            
            Text(viewModel.strings.downloadToolsForOfflineMessage)
                .font(FontLibrary.sfProTextRegular.font(size: 15))
                .foregroundColor(ColorPalette.gtGrey.color)
                .multilineTextAlignment(.leading)
                .padding([.top], 12)
            
            SeparatorView()
                .padding([.top], 11)
            
            VStack(alignment: .leading, spacing: 0) {
                
                ScrollView(.vertical, showsIndicators: true) {
                    
                    LazyVStack(alignment: .leading, spacing: 0) {
                        
                        ForEach(viewModel.downloadedLanguages) { downloadedLanguage in
                            
                            ToolLanguageAvailableOfflineLanguageView(downloadedLanguage: downloadedLanguage)
                        }
                    }
                    .background(
                        GeometryReader { geo -> Color in
                            DispatchQueue.main.async {
                                contentSize = geo.size
                            }
                            return Color.clear
                        }
                    )
                }
                .frame(maxHeight: contentSize.height)
                
                FixedVerticalSpacer(height: 25)
                
                GTBlueButton(
                    title: viewModel.strings.editDownloadedLanguagesButtonTitle,
                    font: FontLibrary.sfProTextRegular.font(size: 14),
                    width: geometry.size.width - (contentHorizontalInsets * 2),
                    height: 50,
                    accessibility: .editDownloadedLanguages,
                    action: {
                        
                        viewModel.editDownloadedLanguagesTapped()
                    }
                )
            }
            
        }
        .padding([.leading, .trailing], contentHorizontalInsets)
    }
}
