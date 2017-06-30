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
    }
    
    private func initializeInitialResources() {
        DownloadedResourceManager().loadInitialContentFromDisk()
    }
}
