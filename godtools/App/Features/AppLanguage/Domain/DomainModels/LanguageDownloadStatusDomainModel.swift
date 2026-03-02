//
//  LanguageDownloadStatusDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 12/8/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

enum LanguageDownloadStatusDomainModel: Sendable, Equatable {
    
    case notDownloaded
    case downloaded(date: Date)
}

extension LanguageDownloadStatusDomainModel {
    
    var downloadedAt: Date? {
        
        switch self {
        case .downloaded(let date):
            return date
            
        default:
            return nil
        }
    }
}
