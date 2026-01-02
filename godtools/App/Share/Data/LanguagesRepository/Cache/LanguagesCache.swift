//
//  LanguagesCache.swift
//  godtools
//
//  Created by Levi Eggert on 9/24/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RepositorySync
import Combine

class LanguagesCache {
        
    private let persistence: any Persistence<LanguageDataModel, LanguageCodable>
    
    init(persistence: any Persistence<LanguageDataModel, LanguageCodable>) {
                
        self.persistence = persistence
    }
    
    @available(iOS 17.4, *)
    var swiftDatabase: SwiftDatabase? {
        return getSwiftPersistence()?.database
    }
    
    @available(iOS 17.4, *)
    func getSwiftPersistence() -> SwiftRepositorySyncPersistence<LanguageDataModel, LanguageCodable, SwiftLanguage>? {
        return persistence as? SwiftRepositorySyncPersistence<LanguageDataModel, LanguageCodable, SwiftLanguage>
    }
    
    var realmDatabase: RealmDatabase? {
        return getRealmPersistence()?.database
    }
    
    func getRealmPersistence() -> RealmRepositorySyncPersistence<LanguageDataModel, LanguageCodable, RealmLanguage>? {
        return persistence as? RealmRepositorySyncPersistence<LanguageDataModel, LanguageCodable, RealmLanguage>
    }
}

// MARK: - Predicates

extension LanguagesCache {
    
    @available(iOS 17.4, *)
    private func getLanguageByCodePredicate(code: String) -> Predicate<SwiftLanguage> {
     
        let filter = #Predicate<SwiftLanguage> { object in
            object.code == code
        }
        
        return filter
    }
    
    private func getLanguageByCodeNSPredicate(code: String) -> NSPredicate {
        
        let filter = NSPredicate(format: "\(#keyPath(RealmLanguage.code)) == [c] %@", code.lowercased())
        
        return filter
    }
    
    @available(iOS 17.4, *)
    private func getLanguagesByCodesPredicate(codes: [String]) -> Predicate<SwiftLanguage> {
     
        let filter = #Predicate<SwiftLanguage> { object in
            codes.contains(object.code)
        }
        
        return filter
    }
    
    private func getLanguagesByCodesNSPredicate(codes: [String]) -> NSPredicate {
        
        let filter = NSPredicate(format: "\(#keyPath(RealmLanguage.code)) IN %@", codes)
        
        return filter
    }
}

// MARK: - Languages

extension LanguagesCache {
    
    func getCachedLanguage(code: BCP47LanguageIdentifier) throws -> LanguageDataModel? {
        
        if #available(iOS 17.4, *), let swiftPersistence = getSwiftPersistence() {
            
            let query = SwiftDatabaseQuery<SwiftLanguage>.filter(
                filter: getLanguageByCodePredicate(code: code)
            )
            
            let swiftLanguage: SwiftLanguage? = try swiftPersistence.database.openContextAndRead.objects(query: query).first
            
            if let swiftLanguage = swiftLanguage {
                return LanguageDataModel(interface: swiftLanguage)
            }
            else {
                return nil
            }
        }
        else if let realmPersistence = getRealmPersistence() {
            
            let query = RealmDatabaseQuery.filter(
                filter: getLanguageByCodeNSPredicate(code: code)
            )
            
            let realmLanguage: RealmLanguage? = try realmPersistence.database.openRealmAndRead.objects(query: query).first
            
            if let realmLanguage = realmLanguage {
                return LanguageDataModel(interface: realmLanguage)
            }
            else {
                return nil
            }
        }
        else {
            
            return nil
        }
    }
    
    func getCachedLanguages(codes: [BCP47LanguageIdentifier]) async throws -> [LanguageDataModel] {
        
        if #available(iOS 17.4, *), let swiftPersistence = getSwiftPersistence() {
                      
            let query = SwiftDatabaseQuery<SwiftLanguage>.filter(
                filter: getLanguagesByCodesPredicate(codes: codes)
            )
            
            return try await swiftPersistence.getDataModelsAsync(getOption: .allObjects, query: query)
        }
        else if let realmPersistence = getRealmPersistence() {
            
            let query = RealmDatabaseQuery.filter(
                filter: getLanguagesByCodesNSPredicate(codes: codes)
            )
            
            return try await realmPersistence.getDataModelsAsync(getOption:.allObjects, query: query)
        }
        else {
            
            return []
        }
    }
    
    @MainActor func getCachedLanguagesPublisher(codes: [BCP47LanguageIdentifier]) -> AnyPublisher<[LanguageDataModel], Error> {
       
        return Future { promise in
        
            Task {

                do {
                    promise(.success(try await self.getCachedLanguages(codes: codes)))
                }
                catch let error {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
