//
//  DownloadableLanguageListItemDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 12/8/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct DownloadableLanguageListItemDomainModel: Equatable {
    
    let languageId: String
    let languageCode: BCP47LanguageIdentifier
    let languageNameInOwnLanguage: String
    let languageNameInAppLanguage: String
    let toolsAvailableText: String
    let downloadStatus: LanguageDownloadStatusDomainModel
}

extension DownloadableLanguageListItemDomainModel {
    
    func mapUpdatedDownloadStatus(downloadStatus: LanguageDownloadStatusDomainModel) -> DownloadableLanguageListItemDomainModel {
        
        return DownloadableLanguageListItemDomainModel(
            languageId: languageId,
            languageCode: languageCode,
            languageNameInOwnLanguage: languageNameInOwnLanguage,
            languageNameInAppLanguage: languageNameInAppLanguage,
            toolsAvailableText: toolsAvailableText,
            downloadStatus: downloadStatus
        )
    }
}

extension DownloadableLanguageListItemDomainModel: Identifiable {
    var id: String {
        return languageId
    }
    
    var isDownloaded: Bool {
        
        switch downloadStatus {
        case .downloaded:
            return true
        default:
            return false
        }
    }
        
    func wasDownloadedBefore(date: Date) -> Bool {
        guard let downloadedAt = downloadStatus.downloadedAt else { return false }
        
        return downloadedAt < date
    }
}

extension DownloadableLanguageListItemDomainModel: StringSearchable {
    
    var searchableStrings: [String] {
        return [
            languageNameInAppLanguage,
            languageNameInOwnLanguage
        ]
    }
}
