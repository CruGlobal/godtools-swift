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
    
    @ObservedObject private var viewModel: DownloadableLanguageItemViewModel

    init(viewModel: DownloadableLanguageItemViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            HStack(alignment: .center, spacing: 0) {
                
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
                
                LanguageDownloadIcon(
                    state: viewModel.iconState
                )
            }
            .padding([.top], 10)
            
            SeparatorView()
                .padding([.top], 14)
        }
        .padding([.horizontal], 20)
        .animation(.default, value: viewModel.recycleState.downloadState)
        .animation(.default, value: viewModel.recycleState.isMarkedForRemoval)
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.languageTapped()
        }
    }
}

// MARK: - Preview

struct DownloadableLanguageItemView_Preview: PreviewProvider {
    
    static var previews: some View {
        
        let appDiContainer = AppDiContainer.createUITestsDiContainer()
        
        let viewModel = DownloadableLanguageItemViewModel(
            stepEmitter: PreviewFlowStepEmitter.emitter,
            downloadableLanguage: DownloadableLanguageListItemDomainModel(
                languageId: "0",
                languageNameInOwnLanguage: "English",
                languageNameInAppLanguage: "English",
                toolsAvailableText: "",
                downloadStatus: .notDownloaded
            ),
            downloadToolLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getDownloadToolLanguageUseCase(),
            removeDownloadedToolLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getRemoveDownloadedToolLanguageUseCase()
        )
        
        DownloadableLanguageItemView(
            viewModel: viewModel
        )
    }
}
