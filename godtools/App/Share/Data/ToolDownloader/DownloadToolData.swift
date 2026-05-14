//
//  DownloadToolData.swift
//  godtools
//
//  Created by Levi Eggert on 2/13/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct DownloadToolData: Sendable {
    
    let toolId: String
    let languages: [BCP47LanguageIdentifier]
}
