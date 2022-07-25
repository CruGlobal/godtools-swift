//
//  DownloadToolViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/14/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class DownloadToolViewModel: NSObject, DownloadToolViewModelType {
    
    private let didCloseClosure: (() -> Void)
    private let downloadProgressNumberFormatter: NumberFormatter = NumberFormatter()
    private let downloadProgressIntervalRatePerSecond: TimeInterval = 60
    
    private var didCompleteDownloadClosure: (() -> Void)?
    private var downloadProgressTimer: Timer?
    private var downloadProgressTimerIntervalCount: TimeInterval = 0
    private var didStartToolDownload: Bool = false
    private var didCompleteToolDownload: Bool = false
    
    let message: ObservableValue<String> = ObservableValue(value: "")
    let isLoading: ObservableValue<Bool> = ObservableValue(value: false)
    let downloadProgress: ObservableValue<Double> = ObservableValue(value: 0)
    let progressValue: ObservableValue<String> = ObservableValue(value: "")
    
    required init(downloadMessage: String, didCloseClosure: @escaping (() -> Void)) {
        
        self.didCloseClosure = didCloseClosure
        
        super.init()
        
        setDownloadProgress(progress: 0)

        message.accept(value: downloadMessage)
    }
    
    deinit {

        stopDownload()
    }
    
    func pageDidAppear() {
        
        startToolDownload()
    }
    
    func closeTapped() {
        
        stopDownload()
        
        didCloseClosure()
    }
    
    func completeDownloadProgress(didCompleteDownload: @escaping (() -> Void)) {
        didCompleteDownloadClosure = didCompleteDownload
        didCompleteToolDownload = true
    }
    
    private func startToolDownload() {
        
        guard !didStartToolDownload else {
            return
        }
        
        didStartToolDownload = true
        
        startDownloadProgressTimer()
    }
    
    private func stopDownload() {
        
        stopDownloadProgressTimer()
    }
        
    // MARK: - Download Progress
    
    private var downloadProgressInterval: TimeInterval {
        return 1 / downloadProgressIntervalRatePerSecond
    }
    
    private func startDownloadProgressTimer() {
        
        guard downloadProgressTimer == nil else {
            return
        }
        
        downloadProgressTimer = Timer.scheduledTimer(
            timeInterval: downloadProgressInterval,
            target: self,
            selector: #selector(handleDownloadProgressTimerInterval),
            userInfo: nil,
            repeats: true
        )
    }
    
    private func stopDownloadProgressTimer() {
        downloadProgressTimer?.invalidate()
        downloadProgressTimer = nil
    }
    
    @objc private func handleDownloadProgressTimerInterval() {
               
        downloadProgressTimerIntervalCount += 1
        
        let slowDownloadProgress: Double = downloadProgressInterval / 10
        let fastDownloadProgress: Double = downloadProgressInterval / 1
                
        let currentDownloadProgress: Double = downloadProgress.value
        let downloadProgressSpeed: Double = didCompleteToolDownload ? fastDownloadProgress : slowDownloadProgress
        
        var newDownloadProgress: Double = (currentDownloadProgress + downloadProgressSpeed) * 100
        
        if newDownloadProgress > 99 && !didCompleteToolDownload {
            newDownloadProgress = 99
        }
        else if newDownloadProgress >= 99 && didCompleteToolDownload {
            newDownloadProgress = 100
        }
        
        setDownloadProgress(progress: newDownloadProgress / 100)
        
        if didCompleteToolDownload && newDownloadProgress == 100 {
            stopDownload()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.didCompleteDownloadClosure?()
            }
        }
    }
    
    private func setDownloadProgress(progress: Double) {
        
        downloadProgressNumberFormatter.alwaysShowsDecimalSeparator = false
        downloadProgressNumberFormatter.numberStyle = .none
        
        downloadProgress.accept(value: progress)
        
        let formattedProgress: String = downloadProgressNumberFormatter.string(from: NSNumber(value: progress * 100)) ?? "0"
        progressValue.accept(value: formattedProgress + "%")
    }
}
