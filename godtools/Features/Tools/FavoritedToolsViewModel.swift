//
//  FavoritedToolsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class FavoritedToolsViewModel: FavoritedToolsViewModelType {
    
    private let realm: Realm
    private let analytics: AnalyticsContainer
    
    private weak var flowDelegate: FlowDelegate?
    
    let tools: ObservableValue<[DownloadedResource]> = ObservableValue(value: [])
    
    required init(flowDelegate: FlowDelegate, realm: Realm, analytics: AnalyticsContainer) {
        
        self.flowDelegate = flowDelegate
        self.realm = realm
        self.analytics = analytics
        
        // TODO: Would like to remove notifications and handle data reloading through services. ~Levi
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleReloadToolsNotification),
            name: .downloadPrimaryTranslationCompleteNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleReloadToolsNotification),
            name: .reloadHomeListNotification,
            object: nil
        )
        
        reloadTools()
    }
    
    deinit {
                
        NotificationCenter.default.removeObserver(
            self,
            name: .downloadPrimaryTranslationCompleteNotification,
            object: nil
        )
        
        NotificationCenter.default.removeObserver(
            self,
            name: .reloadHomeListNotification,
            object: nil
        )
    }
    
    @objc func handleReloadToolsNotification() {
        print("\n HANDLE RELOAD TOOLS NOTIFICATION")
        reloadTools()
    }
    
    private func reloadTools() {
                
        let predicate: NSPredicate = NSPredicate(format: "shouldDownload = true")

        let allResources: Results<DownloadedResource> = realm.objects(DownloadedResource.self)
        let filteredResources: Results<DownloadedResource> = allResources.filter(predicate)
        let sortedResources: [DownloadedResource] = Array(filteredResources.sorted(byKeyPath: "sortOrder"))
            
        if sortedResources.isEmpty {
            tools.accept(value: [])
        }
        else {
            tools.accept(value: sortedResources)
        }
    }
    
    func pageViewed() {
        
        analytics.pageViewedAnalytics.trackPageView(screenName: "Home", siteSection: "", siteSubSection: "")
    }
    
    func favoriteTapped(resource: DownloadedResource) {
        
    }
    
    func unfavoriteTapped(resource: DownloadedResource) {
        
    }
    
    func toolTapped(resource: DownloadedResource) {
        flowDelegate?.navigate(step: .toolTappedFromFavoritedTools(resource: resource))
    }
    
    func toolDetailsTapped(resource: DownloadedResource) {
        flowDelegate?.navigate(step: .toolDetailsTappedFromFavoritedTools(resource: resource))
    }
}
