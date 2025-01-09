//
//  LanguageDownloadIconState.swift
//  godtools
//
//  Created by Rachael Skeath on 1/7/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

enum LanguageDownloadIconState {
    case notDownloaded
    case downloading(progress: Double)
    case downloaded
    case remove
}
