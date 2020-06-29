//
//  TranslationFileRemover.swift
//  godtools
//
//  Created by Ryan Carlson on 5/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import Crashlytics

class TranslationFileRemover: GTDataManager {
    
    func deleteUnusedPages() {
        for page in findAllEntities(ReferencedFile.self) {
            do {
                if (page.translations.filter({ $0.isDownloaded }) as [Translation]).count == 0 {
                    try FileManager.default.removeItem(atPath: "\(resourcesPath)/\(page.filename)")
                    realm.delete(page)
                }
            } catch {
                Crashlytics().recordError(error, withAdditionalUserInfo: ["customMessage": "Error deleting file \(page.filename) no longer referenced by any translations"])
            }
        }
    }
}
