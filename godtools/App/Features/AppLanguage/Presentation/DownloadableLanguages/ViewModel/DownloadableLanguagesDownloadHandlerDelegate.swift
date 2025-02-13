//
//  DownloadableLanguagesDownloadHandlerDelegate.swift
//  godtools
//
//  Created by Rachael Skeath on 2/7/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

protocol DownloadableLanguagesDownloadHandlerDelegate: AnyObject {
    func downloadComplete(languageId: BCP47LanguageIdentifier)
    func downloadFailure(languageId: BCP47LanguageIdentifier, error: Error)
    func downloadProgressUpdate(languageId: BCP47LanguageIdentifier, progress: Double)
}
