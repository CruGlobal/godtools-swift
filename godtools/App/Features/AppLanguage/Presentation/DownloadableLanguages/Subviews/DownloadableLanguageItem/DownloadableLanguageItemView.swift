//
//  DownloadableLanguageItemView.swift
//  godtools
//
//  Created by Rachael Skeath on 12/5/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct DownloadableLanguageItemView: View {
    
    private static let lightGrey = Color.getColorWithRGB(red: 151, green: 151, blue: 151, opacity: 1)
    
    private let tappedClosure: (() -> Void)?
    
    @ObservedObject private var viewModel: DownloadableLanguageItemViewModel

    init(viewModel: DownloadableLanguageItemViewModel, tappedClosure: (() -> Void)? = nil) {
        
        self.viewModel = viewModel
        self.tappedClosure = tappedClosure
    }
    
    var body: some View {
        
        HStack {
            
            VStack(alignment: .leading, spacing: 10) {
                
                HStack(spacing: 10) {
                    
                    Text(viewModel.downloadableLanguage.languageNameInOwnLanguage)
                        .font(FontLibrary.sfProTextRegular.font(size: 15))
                        .foregroundColor(ColorPalette.gtGrey.color)
                    
                    Text(viewModel.downloadableLanguage.languageNameInAppLanguage)
                        .font(FontLibrary.sfProTextRegular.font(size: 15))
                        .foregroundColor(Self.lightGrey)
                }
                
                Text(viewModel.downloadableLanguage.toolsAvailableText)
                    .font(FontLibrary.sfProTextRegular.font(size: 12))
                    .foregroundColor(Self.lightGrey)
            }
            
            Spacer()
            
            Button {
                
                viewModel.languageTapped()
                
            } label: {
                
                LanguageDownloadIcon(
                    state: viewModel.iconState
                )
            }
        }
        .animation(.default, value: viewModel.downloadState)
        .animation(.default, value: viewModel.recycleState.isMarkedForRemoval)
    }
}
