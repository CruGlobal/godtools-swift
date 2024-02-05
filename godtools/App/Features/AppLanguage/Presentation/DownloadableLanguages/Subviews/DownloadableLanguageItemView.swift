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
    
    @State private var animationDownloadProgress: Double?
    @State private var downloadProgressTarget: Double?
    @State private var timer: Timer?
    @State private var isVisible: Bool = false
    @State private var shouldConfirmDownloadRemoval: Bool = false
    
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
                
                didTapItem()
                
            } label: {
                
                LanguageDownloadIcon(languageDownloadStatus: downloadableLanguage.downloadStatus, animationDownloadProgress: animationDownloadProgress, shouldConfirmDownloadRemoval: shouldConfirmDownloadRemoval)
            }
        }
        .onChange(of: downloadableLanguage.downloadStatus, perform: { newDownloadStatus in
            
            switch newDownloadStatus {
            case .notDownloaded:
                self.downloadProgressTarget = nil
                self.animationDownloadProgress = nil
                self.shouldConfirmDownloadRemoval = false
                
            case .downloading(let progress):
                self.downloadProgressTarget = progress
                
                if animationDownloadProgress == nil {
                    animationDownloadProgress = 0.1
                }
            case .downloaded:
                self.downloadProgressTarget = 1
            }
            
            if timer == nil {
                startAnimationTimer()
            }
        })
        .animation(.default, value: downloadableLanguage.downloadStatus)
        .animation(.default, value: animationDownloadProgress)
        .animation(.default, value: shouldConfirmDownloadRemoval)
        .onDisappear {
            
            isVisible = false
            stopAnimationTimer()
        }
        .onAppear {
            
            isVisible = true
            continueDownloadProgressAnimationIfNeeded()
        }
        .onAppBackgrounded {
        
            stopAnimationTimer()
        }
        .onAppForegrounded {
            
            continueDownloadProgressAnimationIfNeeded()
        }
    }
    
    private func didTapItem() {
        
        switch downloadableLanguage.downloadStatus {
        case .downloaded:
            
            if shouldConfirmDownloadRemoval == false {
                shouldConfirmDownloadRemoval = true
                return
                
            } else {
                tappedClosure?()
            }
            
        default:
            
            tappedClosure?()
        }
    }
    
    private func startAnimationTimer() {
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { timer in
            guard let downloadProgress = self.animationDownloadProgress,
                  let progressTarget = self.downloadProgressTarget
            else { return }
            
            if downloadProgress < progressTarget {
                
                self.animationDownloadProgress? += 0.1
                
            } else if progressTarget >= 1 && downloadProgress >= 1 {
                
                self.stopAnimationTimer()
            }
        })
    }
    
    private func stopAnimationTimer() {
        guard timer != nil else { return }
        
        timer?.invalidate()
        timer = nil
    }
    
    private func continueDownloadProgressAnimationIfNeeded() {
        if shouldContinueDownloadProgressAnimation() {
            startAnimationTimer()
        }
    }
    
    private func shouldContinueDownloadProgressAnimation() -> Bool {
        guard isVisible,
              let animationDownloadProgress = animationDownloadProgress
        else {
            return false
        }
        
        return animationDownloadProgress < 1
    }
}
