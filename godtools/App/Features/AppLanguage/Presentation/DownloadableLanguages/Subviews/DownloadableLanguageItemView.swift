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
    
    @State private var downloadProgress: Double?
    @State private var timer: Timer?
    
    private var downloadProgressTarget: Double? {
        
        switch downloadableLanguage.downloadStatus {
        case .downloading(let progress):
            return progress
            
        default:
            return nil
        }
    }
    
    init(downloadableLanguage: DownloadableLanguageListItemDomainModel, tappedClosure: (() -> Void)?) {
        
        self.downloadableLanguage = downloadableLanguage
        self.tappedClosure = tappedClosure
        
        switch downloadableLanguage.downloadStatus {
        case .downloading:
            self.downloadProgress = 0.1
            
        default:
            self.downloadProgress = nil
        }
    }
    
    var body: some View {
        
        HStack {
            
            VStack(alignment: .leading, spacing: 10) {
                
                HStack(spacing: 10) {
                    
                    Text(downloadableLanguage.languageNameInOwnLanguage)
                        .font(FontLibrary.sfProTextRegular.font(size: 15))
                        .foregroundColor(ColorPalette.gtGrey.color)
                    
                    Text(downloadableLanguage.languageNameInAppLanguage)
                        .font(FontLibrary.sfProTextRegular.font(size: 15))
                        .foregroundColor(DownloadableLanguageItemView.lightGrey)
                }
                
                Text(downloadableLanguage.toolsAvailableText)
                    .font(FontLibrary.sfProTextRegular.font(size: 12))
                    .foregroundColor(DownloadableLanguageItemView.lightGrey)
            }
            
            Spacer()
            
            Button {
                
                tappedClosure?()
                
            } label: {
                
                LanguageDownloadIcon(languageDownloadStatus: downloadableLanguage.downloadStatus, downloadProgress: downloadProgress)
            }
        }
        .onChange(of: downloadableLanguage.downloadStatus, perform: { newValue in
            
            guard let updatedProgress = downloadProgressTarget else { return }
            guard timer == nil else { return }
            guard let downloadProgress = downloadProgress else { return }
            
            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                
                if downloadProgress < updatedProgress {
                    
                    self.downloadProgress? += 0.1
                    
                } else if updatedProgress >= 1 {
                    
                    timer.invalidate()
                    self.timer = nil
                }
            }
        })
        .animation(.default, value: downloadableLanguage.downloadStatus)
        .animation(.default, value: downloadProgress)
    }
}
