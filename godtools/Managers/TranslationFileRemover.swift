//
//  TranslationFileRemover.swift
//  godtools
//
//  Created by Ryan Carlson on 5/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation

class TranslationFileRemover: GTDataManager {
    
    func deleteUnusedPages() {
        for page in findAllEntities(ReferencedFile.self) {
            do {
                if page.translationsAsArray().filter({ $0.isDownloaded }).count == 0 {
                    print("removing file: \(resourcesPath)/\(page.filename!)")
                    try FileManager.default.removeItem(atPath: "\(resourcesPath)/\(page.filename!)")
                }
            } catch {
                
            }
        }
    }
}
