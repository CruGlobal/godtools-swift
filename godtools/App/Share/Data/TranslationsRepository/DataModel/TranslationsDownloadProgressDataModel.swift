//
//  TranslationsDownloadProgressDataModel.swift
//  godtools
//
//  Created by Levi Eggert on 12/18/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct TranslationsDownloadProgressDataModel: Sendable {
    
    let progress: Double
    let numberOfTranslationsToDownload: Int
    let currentNumberOfTranslationsDownloaded: Int
}
