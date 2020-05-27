//
//  AllToolsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class AllToolsViewModel: AllToolsViewModelType {
    
    private let realm: Realm
    private let analytics: AnalyticsContainer
    
    let tools: ObservableValue<[DownloadedResource]> = ObservableValue(value: [])
    let message: ObservableValue<String> = ObservableValue(value: "")
    
    required init(realm: Realm, analytics: AnalyticsContainer) {
        
        self.realm = realm
        self.analytics = analytics
        
        reloadTools()
    }
    
    private func reloadTools() {
        
        let predicate: NSPredicate = NSPredicate(format: "shouldDownload = false")

        let allResources: Results<DownloadedResource> = realm.objects(DownloadedResource.self)
        let filteredResources: Results<DownloadedResource> = allResources.filter(predicate)
        let resources: [DownloadedResource] = Array(filteredResources)
                
        if resources.isEmpty {
            message.accept(value: NSLocalizedString("You have downloaded all available tools.", comment: ""))
            tools.accept(value: [])
        }
        else {
            tools.accept(value: resources)
        }
    }
    
    func pageViewed() {
        
        analytics.pageViewedAnalytics.trackPageView(screenName: "Find Tools", siteSection: "tools", siteSubSection: "")
    }
}
