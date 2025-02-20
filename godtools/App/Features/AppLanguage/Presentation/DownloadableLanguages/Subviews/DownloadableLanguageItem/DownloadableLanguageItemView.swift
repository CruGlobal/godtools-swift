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
    private static let removeMarkedForRemovalAfterSeconds: TimeInterval = 3
    
    private let removeMarkedForRemovalTimer: SwiftUITimer = SwiftUITimer(intervalSeconds: Self.removeMarkedForRemovalAfterSeconds, repeats: false)
    private let downloadableLanguage: DownloadableLanguageListItemDomainModel
    private let tappedClosure: (() -> Void)?
    private let removeTapped: (() -> Void)?
    
    @State private var animationDownloadProgress: Double?
    @State private var downloadProgressTarget: Double?
    @State private var progressAnimationTimer: Timer?
    @State private var isVisible: Bool = false
    @State private var isMarkedForRemoval: Bool = false
    
    private var isAnimatingDownload: Bool {
        guard let animationDownloadProgress = animationDownloadProgress else {
            return false
        }
        
        return animationDownloadProgress < 1
    }
    
    init(downloadableLanguage: DownloadableLanguageListItemDomainModel, tappedClosure: (() -> Void)?, removeTapped: (() -> Void)?) {
        
        self.downloadableLanguage = downloadableLanguage
        self.tappedClosure = tappedClosure
        self.removeTapped = removeTapped
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
                
                LanguageDownloadIcon(state: getLanguageDownloadIconState())
            }
        }
        .onChange(of: downloadableLanguage.downloadStatus, perform: { newDownloadStatus in
            
            switch newDownloadStatus {
            case .notDownloaded:
                self.downloadProgressTarget = nil
                self.animationDownloadProgress = nil
                setIsMarkedForRemoval(isMarkedForRemoval: false)
                
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
        .onReceive(removeMarkedForRemovalTimer.publisher) { _ in
            self.setIsMarkedForRemoval(isMarkedForRemoval: false)
        }
        .animation(.default, value: downloadableLanguage.downloadStatus)
        .animation(.default, value: animationDownloadProgress)
        .animation(.default, value: isMarkedForRemoval)
        .onDisappear {
            
            isVisible = false
            stopProgressAnimationTimer()
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
    
    private func getLanguageDownloadIconState() -> LanguageDownloadIconState {
        
        switch downloadableLanguage.downloadStatus {
        case .notDownloaded:
            return .notDownloaded
            
        case .downloading(let progress):
            
            if let downloadProgress = animationDownloadProgress ?? progress {
                
                return .downloading(progress: downloadProgress)
            } else {
                return .notDownloaded
            }
            
        case .downloaded:
            
            if isMarkedForRemoval {
                return .remove
                
            } else if shouldFinishDownloadAnimation(), let animationDownloadProgress = animationDownloadProgress {
                
                return .downloading(progress: animationDownloadProgress)
                
            } else {
                return .downloaded
            }
        }
    }

    private func shouldFinishDownloadAnimation() -> Bool {
        guard let animationDownloadProgress = animationDownloadProgress else {
            return false
        }

        return animationDownloadProgress <= 1
    }
    
    private func didTapItem() {
        
        switch downloadableLanguage.downloadStatus {
        
        case .downloaded ( _):
            
            if isAnimatingDownload {
                return
            }
            
            if isMarkedForRemoval {
                setIsMarkedForRemoval(isMarkedForRemoval: false)
                removeTapped?()
            }
            else {
                setIsMarkedForRemoval(isMarkedForRemoval: true)
            }
    
        case .downloading( _):
            break
            
        case .notDownloaded:
            break
        }
        
        tappedClosure?()
    }
    
    private func setIsMarkedForRemoval(isMarkedForRemoval: Bool) {
                
        if isMarkedForRemoval {
            
            self.isMarkedForRemoval = true
            removeMarkedForRemovalTimer.start()
        }
        else {
            
            self.isMarkedForRemoval = false
            removeMarkedForRemovalTimer.stop()
        }
    }
    
    private func startProgressAnimationTimer() {
        
        progressAnimationTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { timer in
            
            guard let downloadProgress = self.animationDownloadProgress, let progressTarget = self.downloadProgressTarget else {
                
                return
            }
            
            if downloadProgress < progressTarget {
                
                self.animationDownloadProgress? += 0.1
                
            } else if progressTarget >= 1 && downloadProgress >= 1 {
                
                self.stopProgressAnimationTimer()
            }
        })
    }
    
    private func stopProgressAnimationTimer() {
        
        guard progressAnimationTimer != nil else {
            return
        }
        
        progressAnimationTimer?.invalidate()
        progressAnimationTimer = nil
    }
    
    private func continueDownloadProgressAnimationIfNeeded() {
        if shouldContinueDownloadProgressAnimation() {
            startProgressAnimationTimer()
        }
    }
    
    private func shouldContinueDownloadProgressAnimation() -> Bool {
        
        guard isVisible, let animationDownloadProgress = animationDownloadProgress else {
            return false
        }
        
        return animationDownloadProgress < 1
    }
}
