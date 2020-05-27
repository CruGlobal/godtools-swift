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
    
    let tools: ObservableValue<[DownloadedResource]> = ObservableValue(value: [])
    
    required init(realm: Realm) {
        
        self.realm = realm
        
        reloadTools()
    }
    
    private func reloadTools() {
        
        let predicate: NSPredicate = NSPredicate(format: "shouldDownload = false")

        let allResources: Results<DownloadedResource> = realm.objects(DownloadedResource.self)
        let filteredResources: Results<DownloadedResource> = allResources.filter(predicate)
        let resources: [DownloadedResource] = Array(filteredResources)
                
        tools.accept(value: resources)
    }
    
    func pageViewed() {
        
    }
}
