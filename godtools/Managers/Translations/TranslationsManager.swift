//
//  TranslationsManager.swift
//  godtools
//
//  Created by Ryan Carlson on 4/28/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire

class TranslationsManager: GTDataManager {
    static let shared = TranslationsManager()
    
    
    func translationWasDownloaded(_ translation: Translation) {
        translation.isDownloaded = true
        saveToDisk()
    }
}
