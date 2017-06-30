//
//  FirstLaunchInitializer.swift
//  godtools
//
//  Created by Ryan Carlson on 5/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import CoreData

class FirstLaunchInitializer: GTDataManager {
    
    func initializeAppState() {
        initializeInitialLanguages()
        initializeInitialResources()
    }
    
    private func initializeInitialLanguages() {
        LanguagesManager().loadInitialContentFromDisk()
        let englishLanguage = findEntity(Language.self, byAttribute: "code", withValue: "en")
        
        safelyWriteToRealm {
            englishLanguage?.shouldDownload = true
        }
    }
    
    private func initializeInitialResources() {
        DownloadedResourceManager().loadInitialContentFromDisk()
        setResourceShouldDownload(resourceCodes: ["kgp","sat","4sl"])
    }
    
    private func setResourceShouldDownload(resourceCodes: [String]) {
        safelyWriteToRealm {
            for resourceCode in resourceCodes {
                let resource = findEntity(DownloadedResource.self, byAttribute: "code", withValue: resourceCode)
                resource?.shouldDownload = true
            }
        }
    }
}
