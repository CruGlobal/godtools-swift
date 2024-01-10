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
    @State private var downloadProgressTarget: Double?
    @State private var timer: Timer?
    
    init(downloadableLanguage: DownloadableLanguageListItemDomainModel, tappedClosure: (() -> Void)?) {
        
        self.downloadableLanguage = downloadableLanguage
        self.tappedClosure = tappedClosure
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
            
            switch newValue {
            case .notDownloaded:
                self.downloadProgressTarget = nil
                self.downloadProgress = nil
                
            case .downloading(let progress):
                self.downloadProgressTarget = progress
                
                if downloadProgress == nil {
                    downloadProgress = 0.1
                }
            case .downloaded:
                self.downloadProgressTarget = 1
            }
            
            if timer == nil {
                startAnimationTimer()
            }
        })
        .animation(.default, value: downloadableLanguage.downloadStatus)
        .animation(.default, value: downloadProgress)
    }
    
    private func startAnimationTimer() {
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { timer in
            guard let downloadProgress = self.downloadProgress,
                  let progressTarget = self.downloadProgressTarget
            else { return }
            
            if downloadProgress < progressTarget {
                
                self.downloadProgress? += 0.1
                
            } else if progressTarget >= 1 && downloadProgress >= 1 {
                
                timer.invalidate()
                self.timer = nil
            }
        })
    }
}
