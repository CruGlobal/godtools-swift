//
//  ToolDownloaderDataModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/13/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct ToolDownloaderDataModel {
    
    let attachments: [AttachmentModel]
    let progress: Double
    let translations: [TranslationModel]
}
