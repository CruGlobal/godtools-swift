//
//  AppDelegate+UniversalLinks.swift
//  godtools
//
//  Created by Ryan Carlson on 7/14/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation


extension AppDelegate {
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if userActivity.activityType != NSUserActivityTypeBrowsingWeb {
            return false
        }
        
        guard let url = userActivity.webpageURL else {
            return false
        }
        
        guard let language = parseLangaugeFrom(url) else {
            return false
        }
        
        guard let resource = parseResourceFrom(url) else {
            return false
        }
        
        let pageNumber = parsePageNumberFrom(url)
        
//        self.flowController
        return true
    }
    
    private func parseLangaugeFrom(_ url: URL) -> Language? {
        let pathParts = url.pathComponents
        
        if pathParts.count < 1 {
            return nil
        }
        
        let languagesManager = LanguagesManager()
        return languagesManager.loadFromDisk(code: pathParts[0])
    }
    
    private func parseResourceFrom(_ url: URL) -> DownloadedResource? {
        let pathParts = url.pathComponents
        
        if pathParts.count < 2 {
            return nil
        }
        
        let resourcesManager = DownloadedResourceManager()
        return resourcesManager.loadFromDisk(code: pathParts[1])
    }
    
    private func parsePageNumberFrom(_ url: URL) -> Int {
        let pathParts = url.pathComponents
        
        if pathParts.count < 3 {
            return 0
        }
        
        return Int(pathParts[2]) ?? 0
    }
}
