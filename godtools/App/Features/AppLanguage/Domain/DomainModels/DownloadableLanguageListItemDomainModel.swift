//
//  DownloadableLanguageListItemDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 12/8/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct DownloadableLanguageListItemDomainModel: Sendable {
    
    let languageId: String
    let languageNamePair: TranslatedLanguageNamePairDomainModel
    let toolsAvailableText: String
    let downloadStatus: LanguageDownloadStatusDomainModel
    
    var isDownloaded: Bool {
        
        switch downloadStatus {
        case .downloaded:
            return true
        default:
            return false
        }
    }
        
    func wasDownloadedBefore(date: Date) -> Bool {
        
        guard let downloadedAt = downloadStatus.downloadedAt else {
            return false
        }
        
        return downloadedAt < date
    }
}

extension DownloadableLanguageListItemDomainModel: Identifiable {
    var id: String {
        return languageId
    }
}

extension DownloadableLanguageListItemDomainModel: StringSearchable {
    
    var searchableStrings: [String] {
        return [
            languageNamePair.nameInAppLanguage,
            languageNamePair.nameInOwnLanguage
        ]
    }
}

extension DownloadableLanguageListItemDomainModel: Equatable {
    static func == (this: DownloadableLanguageListItemDomainModel, that: DownloadableLanguageListItemDomainModel) -> Bool {
        return this.languageId == that.languageId
    }
}
