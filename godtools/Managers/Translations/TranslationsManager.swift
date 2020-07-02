//
//  TranslationsManager.swift
//  godtools
//
//  Created by Ryan Carlson on 4/28/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class TranslationsManager: GTDataManager {
    
    func translationWasDownloaded(_ translation: Translation) {

    }
    
    func translationsNeedingDownloaded() -> List<Translation> {
        
        return List<Translation>()
    }
    
    func purgeTranslationsOlderThan(_ latest: Translation) {
        
    }
    
    func loadTranslation(resourceCode: String, languageCode: String, published: Bool) -> Translation? {
        
        return nil
    }
}
