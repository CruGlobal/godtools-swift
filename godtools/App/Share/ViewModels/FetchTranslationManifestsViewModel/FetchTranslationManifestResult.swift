//
//  FetchTranslationManifestResult.swift
//  godtools
//
//  Created by Levi Eggert on 6/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

enum FetchTranslationManifestResult {
    
    case failedToGetInitialResourcesFromCache
    case fetchedTranslationsFromCache(primaryLanguage: LanguageModel, primaryTranslation: TranslationModel, primaryTranslationManifest: TranslationManifestData?, parallelLanguage: LanguageModel?, parallelTranslation: TranslationModel?, parallelTranslationManifest: TranslationManifestData?)
}
