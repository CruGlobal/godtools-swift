//
//  ToolItemInitialDownloadProgress.swift
//  godtools
//
//  Created by Levi Eggert on 4/12/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol ToolItemInitialDownloadProgress: NSObject {
    
    var resource: ResourceModel { get }
    var dataDownloader: InitialDataDownloader { get }
    var attachmentsDownloadProgress: ObservableValue<Double> { get }
    var translationDownloadProgress: ObservableValue<Double> { get }
    var downloadAttachmentsReceipt: DownloadAttachmentsReceipt? { get set }
    var downloadResourceTranslationsReceipt: DownloadTranslationsReceipt? { get set }
}

extension ToolItemInitialDownloadProgress {
    
    private func destroyDownloadAttachmentsReceipt() {
        if let receipt = downloadAttachmentsReceipt {
            receipt.progressObserver.removeObserver(self)
            receipt.completedSignal.removeObserver(self)
            downloadAttachmentsReceipt = nil
        }
    }
    
    private func destroyDownloadResourceTranslationsReceipt() {
        if let receipt = downloadResourceTranslationsReceipt {
            receipt.progressObserver.removeObserver(self)
            receipt.translationDownloadedSignal.removeObserver(self)
            receipt.completedSignal.removeObserver(self)
            downloadResourceTranslationsReceipt = nil
        }
    }
    
    private func observeDownloadAttachmentsReceipt(receipt: DownloadAttachmentsReceipt) {
        
        destroyDownloadAttachmentsReceipt()
        
        downloadAttachmentsReceipt = receipt
        
        receipt.progressObserver.addObserver(self) { [weak self] (progress: Double) in
            DispatchQueue.main.async { [weak self] in
                self?.attachmentsDownloadProgress.accept(value: progress)
            }
        }
        
        receipt.completedSignal.addObserver(self) { [weak self] in
            DispatchQueue.main.async { [weak self] in
                self?.destroyDownloadAttachmentsReceipt()
            }
        }
    }
    
    private func observeDownloadResourceTranslationsReceipt(receipt: DownloadTranslationsReceipt) {
        
        destroyDownloadResourceTranslationsReceipt()
        
        downloadResourceTranslationsReceipt = receipt
        
        receipt.progressObserver.addObserver(self) { [weak self] (progress: Double) in
            DispatchQueue.main.async { [weak self] in
                self?.translationDownloadProgress.accept(value: progress)
            }
        }
        
        receipt.completedSignal.addObserver(self) { [weak self] in
            DispatchQueue.main.async { [weak self] in
                self?.destroyDownloadResourceTranslationsReceipt()
            }
        }
    }
    
    func addDataDownloaderObservers() {
        
        dataDownloader.attachmentsDownload.addObserver(self) { [weak self] (receipt: DownloadAttachmentsReceipt?) in
            DispatchQueue.main.async { [weak self] in
                if let receipt = receipt {
                    self?.observeDownloadAttachmentsReceipt(receipt: receipt)
                }
            }
        }
        
        dataDownloader.latestTranslationsDownload.addObserver(self) { [weak self] (receipts: DownloadResourceTranslationsReceipts?) in
            DispatchQueue.main.async { [weak self] in
                if let receipts = receipts,
                   let resourceId = self?.resource.id,
                   let resourceTranslationsDownloadReceipt = receipts.getReceipt(resourceId: resourceId) {
                    self?.observeDownloadResourceTranslationsReceipt(receipt: resourceTranslationsDownloadReceipt)
                }
            }
        }
    }
    
    func removeDataDownloaderObservers() {
        
        dataDownloader.attachmentsDownload.removeObserver(self)
        destroyDownloadAttachmentsReceipt()
        dataDownloader.latestTranslationsDownload.removeObserver(self)
        destroyDownloadResourceTranslationsReceipt()
    }
}
