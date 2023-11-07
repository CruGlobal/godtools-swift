//
//  DownloadToolProgressInterfaceStringsDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct DownloadToolProgressInterfaceStringsDomainModel {
    
    let downloadMessage: String
    
    init(toolIsFavorited: Bool?, downloadingToolMessage: String, favoriteThisToolForOfflineUseMessage: String) {
        
        if let toolIsFavorited = toolIsFavorited {
            downloadMessage = toolIsFavorited ? downloadingToolMessage : favoriteThisToolForOfflineUseMessage
        }
        else {
            downloadMessage = downloadingToolMessage
        }
    }
}
