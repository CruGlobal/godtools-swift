//
//  DownloadableLanguageItemView.swift
//  godtools
//
//  Created by Rachael Skeath on 12/5/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

enum LanguageDownloadStatus: Equatable {
    case notDownloaded
    case downloading(progress: Double)
    case downloaded
}

struct DownloadableLanguageItemView: View {
    
    private static let lightGrey = Color.getColorWithRGB(red: 151, green: 151, blue: 151, opacity: 1)
    
    @State private var languageDownloadStatus: LanguageDownloadStatus
    private let tappedClosure: (() -> Void)?
    
    init(languageDownloadStatus: LanguageDownloadStatus, tappedClosure: (() -> Void)?) {
        self.languageDownloadStatus = languageDownloadStatus
        self.tappedClosure = tappedClosure
    }
    
    func toggle() {
        switch languageDownloadStatus {
        case .notDownloaded:
            languageDownloadStatus = .downloading(progress: 0)
            
            var progress: Double = 0
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                progress += 0.05

                languageDownloadStatus = .downloading(progress: progress)
                
                if progress >= 1 {
                    timer.invalidate()
                    languageDownloadStatus = .downloaded
                }
            }
            
        case .downloading:
            languageDownloadStatus = .downloaded
            
        case .downloaded:
            languageDownloadStatus = .notDownloaded
        }
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
                    toggle()
                    
                } label: {
                    
                    LanguageDownloadIcon(languageDownloadStatus: $languageDownloadStatus)
                }

            }
        }
        .animation(.default, value: languageDownloadStatus)
    }
}
