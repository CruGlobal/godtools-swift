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
    
    private let toolsManager: ToolsManager
    private let realm: Realm
    private let analytics: AnalyticsContainer
    
    private weak var flowDelegate: FlowDelegate?
    
    let tools: ObservableValue<[DownloadedResource]> = ObservableValue(value: [])
    let message: ObservableValue<String> = ObservableValue(value: "")
    
    required init(flowDelegate: FlowDelegate, toolsManager: ToolsManager, realm: Realm, analytics: AnalyticsContainer) {
        
        self.flowDelegate = flowDelegate
        self.toolsManager = toolsManager
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
        
        let predicate: NSPredicate = NSPredicate(format: "shouldDownload = false")

        let allResources: Results<DownloadedResource> = realm.objects(DownloadedResource.self)
        let filteredResources: Results<DownloadedResource> = allResources.filter(predicate)
        let resources: [DownloadedResource] = Array(filteredResources)
                
        if resources.isEmpty {
            message.accept(value: NSLocalizedString("You have downloaded all available tools.", comment: ""))
            tools.accept(value: [])
        }
        else {
            message.accept(value: "")
            tools.accept(value: resources)
        }
    }
    
    func pageViewed() {
        
        analytics.pageViewedAnalytics.trackPageView(screenName: "Find Tools", siteSection: "tools", siteSubSection: "")
    }
    
    func favoriteTapped(resource: DownloadedResource) {
        print("Favorite Tapped")
        
        // TODO: Would like to refactor this out and use service with OperationQueue which will report progress and completion of a downloaded resource without the use of NotificationCenter. ~Levi
        DownloadedResourceManager().download(resource)
    }
    
    func unfavoriteTapped(resource: DownloadedResource) {
        print("Unfavorite Tapped")
    }
    
    func toolTapped(resource: DownloadedResource) {
        flowDelegate?.navigate(step: .toolTappedFromAllTools(resource: resource))
    }
    
    func toolDetailsTapped(resource: DownloadedResource) {
        flowDelegate?.navigate(step: .toolDetailsTappedFromAllTools(resource: resource))
    }
}
