//
//  ToolScreenShareTutorialViewsCache.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftData
import RepositorySync

final class ToolScreenShareTutorialViewsCache {
    
    let persistence: any Persistence<ToolScreenShareTutorialViewDataModel, ToolScreenShareTutorialViewDataModel>
    
    init(persistence: any Persistence<ToolScreenShareTutorialViewDataModel, ToolScreenShareTutorialViewDataModel>) {
                
        self.persistence = persistence
    }
    
    @available(iOS 17.4, *)
    var swiftDatabase: SwiftDatabase? {
        return getSwiftPersistence()?.database
    }
    
    @available(iOS 17.4, *)
    func getSwiftPersistence() -> SwiftRepositorySyncPersistence<ToolScreenShareTutorialViewDataModel, ToolScreenShareTutorialViewDataModel, SwiftToolScreenTutorialShareView>? {
        return persistence as? SwiftRepositorySyncPersistence<ToolScreenShareTutorialViewDataModel, ToolScreenShareTutorialViewDataModel, SwiftToolScreenTutorialShareView>
    }
    
    var realmDatabase: RealmDatabase? {
        return getRealmPersistence()?.database
    }
    
    func getRealmPersistence() -> RealmRepositorySyncPersistence<ToolScreenShareTutorialViewDataModel, ToolScreenShareTutorialViewDataModel, RealmToolScreenShareTutorialView>? {
        return persistence as? RealmRepositorySyncPersistence<ToolScreenShareTutorialViewDataModel, ToolScreenShareTutorialViewDataModel, RealmToolScreenShareTutorialView>
    }
}
