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
    let languageNameInOwnLanguage: String
    let languageNameInAppLanguage: String
    let toolsAvailableText: String
    let downloadStatus: LanguageDownloadStatusDomainModel
}

extension DownloadableLanguageListItemDomainModel {
    
    func mapUpdatedDownloadStatus(downloadStatus: LanguageDownloadStatusDomainModel) -> DownloadableLanguageListItemDomainModel {
        
        return DownloadableLanguageListItemDomainModel(
            languageId: languageId,
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
}
