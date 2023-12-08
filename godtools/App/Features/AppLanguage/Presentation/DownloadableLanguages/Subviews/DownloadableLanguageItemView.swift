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
    
    private let downloadableLanguage: DownloadableLanguageListItemDomainModel
    private let tappedClosure: (() -> Void)?
    
    init(downloadableLanguage: DownloadableLanguageListItemDomainModel, tappedClosure: (() -> Void)?) {
        
        self.downloadableLanguage = downloadableLanguage
        self.tappedClosure = tappedClosure
    }
    
    var body: some View {
        
        HStack {
            
            VStack(alignment: .leading, spacing: 10) {
                
                HStack(spacing: 3) {
                    
                    Text("Own Language")
                        .font(FontLibrary.sfProTextRegular.font(size: 15))
                        .foregroundColor(ColorPalette.gtGrey.color)
                    
                    Text("App Language")
                        .font(FontLibrary.sfProTextRegular.font(size: 15))
                        .foregroundColor(DownloadableLanguageItemView.lightGrey)
                }
                
                Text("Tools available text")
                    .font(FontLibrary.sfProTextRegular.font(size: 12))
                    .foregroundColor(DownloadableLanguageItemView.lightGrey)
            }
            
            Spacer()
            
            HStack(alignment: .center, spacing: 8) {
                
                Text("106.3 MB")
                    .font(FontLibrary.sfProTextRegular.font(size: 12))
                    .foregroundColor(DownloadableLanguageItemView.lightGrey)
                
                Button {
                    
                    tappedClosure?()
                    
                } label: {
                    
                    LanguageDownloadIcon(languageDownloadStatus: downloadableLanguage.downloadStatus)
                }

            }
        }
        .animation(.default, value: downloadableLanguage.downloadStatus)
    }
}
