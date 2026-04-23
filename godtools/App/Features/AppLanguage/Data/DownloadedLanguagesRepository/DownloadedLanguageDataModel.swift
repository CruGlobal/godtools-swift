//
//  DownloadedLanguageDataModel.swift
//  godtools
//
//  Created by Rachael Skeath on 12/13/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct DownloadedLanguageDataModel: Sendable {
    
    let id: String
    let createdAt: Date
    let languageId: String
    let downloadComplete: Bool
}
