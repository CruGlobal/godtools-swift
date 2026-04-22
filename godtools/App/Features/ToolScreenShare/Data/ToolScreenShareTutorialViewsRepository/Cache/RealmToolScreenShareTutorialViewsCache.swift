//
//  RealmToolScreenShareTutorialViewsCache.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine
import RealmSwift

final class RealmToolScreenShareTutorialViewsCache {
    
    private let realmDatabase: LegacyRealmDatabase
    
    init(realmDatabase: LegacyRealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func getToolScreenShareView(id: String) -> ToolScreenShareTutorialViewDataModel? {
        
        let realm: Realm = realmDatabase.openRealm()
        
        guard let realmToolScreenShareView = realm.object(ofType: RealmToolScreenShareTutorialView.self, forPrimaryKey: id) else {
            return nil
        }
        
        return realmToolScreenShareView.toModel()
    }
    
    func setToolScreenShareNumberOfViews(id: String, numberOfViews: Int) -> Error? {
        
        let realm: Realm = realmDatabase.openRealm()
        
        let toolScreenShareView = RealmToolScreenShareTutorialView()
        
        toolScreenShareView.id = id
        toolScreenShareView.numberOfViews = numberOfViews
        
        do {
            
            try realm.write {
                realm.add(toolScreenShareView, update: .all)
            }
            
            return nil
        }
        catch let error {
            return error
        }
    }
}
