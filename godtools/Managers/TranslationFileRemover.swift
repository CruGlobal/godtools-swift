//
//  TranslationFileRemover.swift
//  godtools
//
//  Created by Ryan Carlson on 5/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation

class TranslationFileRemover: GTDataManager {
    
    func handleDelete(resource: DownloadedResource) {
        
    }
    
    func handleDelete(language: Language) {
        
    }
    
    func deleteUnusedPages() {
        for page in findAllEntities(PageFile.self) {
            if page.resource!.translationsAsArray().filter({ $0.isDownloaded }).count == 0 {
                //delete page
            }
        }
    }
}
