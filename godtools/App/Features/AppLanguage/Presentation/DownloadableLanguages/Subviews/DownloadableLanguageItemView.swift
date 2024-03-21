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
    @State private var progressAnimationTimer: Timer?
    @State private var removeDownloadTimer: Timer?
    @State private var isVisible: Bool = false
    @State private var shouldConfirmDownloadRemoval: Bool = false
    
    private var isAnimatingDownload: Bool {
        guard let animationDownloadProgress = animationDownloadProgress else {
            return false
        }
        
        return animationDownloadProgress < 1
    }
    
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
            
            if progressAnimationTimer == nil {
                startProgressAnimationTimer()
            }
        })
        .animation(.default, value: downloadableLanguage.downloadStatus)
        .animation(.default, value: animationDownloadProgress)
        .animation(.default, value: shouldConfirmDownloadRemoval)
        .onDisappear {
            
            isVisible = false
            stopProgressAnimationTimer()
            cancelDownloadRemovalConfirmation()
        }
        .onAppear {
            
            isVisible = true
            continueDownloadProgressAnimationIfNeeded()
        }
        .onAppBackgrounded {
        
            stopProgressAnimationTimer()
        }
        .onAppForegrounded {
            
            continueDownloadProgressAnimationIfNeeded()
        }
    }
    
    private func didTapItem() {
        
        switch downloadableLanguage.downloadStatus {
        case .downloaded:
            
            if isAnimatingDownload {
                return
                
            } else if shouldConfirmDownloadRemoval == false {
                
                shouldConfirmDownloadRemoval = true
                startRemoveDownloadTimer()
                
                return
                
            } else {
                stopRemoveDownloadTimer()
                tappedClosure?()
            }
            
        default:
            
            tappedClosure?()
        }
    }
    
    private func startRemoveDownloadTimer() {
        
        removeDownloadTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false, block: { timer in
            
            self.cancelDownloadRemovalConfirmation()
        })
    }
    
    private func cancelDownloadRemovalConfirmation() {
        
        shouldConfirmDownloadRemoval = false
        stopRemoveDownloadTimer()
    }
    
    private func stopRemoveDownloadTimer() {
        
        removeDownloadTimer?.invalidate()
        removeDownloadTimer = nil
    }
    
    private func startProgressAnimationTimer() {
        
        progressAnimationTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { timer in
            guard let downloadProgress = self.animationDownloadProgress,
                  let progressTarget = self.downloadProgressTarget
            else { return }
            
            if downloadProgress < progressTarget {
                
                self.animationDownloadProgress? += 0.1
                
            } else if progressTarget >= 1 && downloadProgress >= 1 {
                
                self.stopProgressAnimationTimer()
            }
        })
    }
    
    private func stopProgressAnimationTimer() {
        guard progressAnimationTimer != nil else { return }
        
        progressAnimationTimer?.invalidate()
        progressAnimationTimer = nil
    }
    
    private func continueDownloadProgressAnimationIfNeeded() {
        if shouldContinueDownloadProgressAnimation() {
            startProgressAnimationTimer()
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
