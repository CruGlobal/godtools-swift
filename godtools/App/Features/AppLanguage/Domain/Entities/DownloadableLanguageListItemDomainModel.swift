//
//  DownloadableLanguageListItemDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 12/8/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct DownloadableLanguageListItemDomainModel {
    
    let languageId: String
    let downloadStatus: LanguageDownloadStatusDomainModel
}

extension DownloadableLanguageListItemDomainModel: Identifiable {
    var id: String {
        return languageId
    }
}
