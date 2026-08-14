//
//  LocalActivityCounterCache.swift
//  godtools
//
//  Created by Levi Eggert on 5/1/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftData
import RepositorySync

final class LocalActivityCounterCache: Sendable {
    
    let persistence: any Persistence<LocalActivityCountDataModel, LocalActivityCountDataModel>
    
    init(persistence: any Persistence<LocalActivityCountDataModel, LocalActivityCountDataModel>) {

        self.persistence = persistence
    }
    
    @available(iOS 17.4, *)
    private var swiftDatabase: SwiftDatabase? {
        return getSwiftPersistence()?.database
    }
    
    @available(iOS 17.4, *)
    private func getSwiftPersistence() -> SwiftRepositorySyncPersistence<LocalActivityCountDataModel, LocalActivityCountDataModel, SwiftLocalActivityCount>? {
        return persistence as? SwiftRepositorySyncPersistence<LocalActivityCountDataModel, LocalActivityCountDataModel, SwiftLocalActivityCount>
    }
    
    private func getRealmPersistence() -> RealmRepositorySyncPersistence<LocalActivityCountDataModel, LocalActivityCountDataModel, RealmLocalActivityCount>? {
        return persistence as? RealmRepositorySyncPersistence<LocalActivityCountDataModel, LocalActivityCountDataModel, RealmLocalActivityCount>
    }
}

extension LocalActivityCounterCache {
    
    func getCounter(id: String) throws -> LocalActivityCountDataModel? {
        return try persistence.getDataModel(id: id)
    }
    
    func getCounters() async throws -> [LocalActivityCountDataModel] {
        return try await persistence.getDataModels(getOption: .allObjects)
    }
    
    private func incrementLocalCount(localCount: Int) -> Int {
        
        let newCount: Int = localCount + 1
        
        if newCount <= 0 {
            return 1
        }
        
        return newCount
    }
    
    func incrementCounter(id: String) async throws -> LocalActivityCountDataModel {
        
        let counter: LocalActivityCountDataModel = try persistence.getDataModel(id: id) ?? LocalActivityCountDataModel(id: id, count: 0)
        
        let newCount: Int = incrementLocalCount(localCount: counter.count)
        
        let updatedCounter = counter.copy(count: newCount)
        
        try await persistence.writeObjects(externalObjects: [updatedCounter])
        
        return updatedCounter
    }
    
    func decrementCount(id: String, decrementBy: Int) async throws {
        
        let counter: LocalActivityCountDataModel? = try persistence.getDataModel(id: id)
        
        guard let counter = counter else {
            return
        }
        
        let decrementedCount: Int = counter.count - decrementBy
        
        let newCount: Int = decrementedCount < 0 ? 0 : decrementedCount
        
        let updatedCounter = counter.copy(count: newCount)
        
        try await persistence.writeObjects(externalObjects: [updatedCounter])
    }
}
