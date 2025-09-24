//
//  LanguagesRepository.swift
//  godtools
//
//  Created by Levi Eggert on 5/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine
import RealmSwift
import RequestOperation
import SwiftData

class LanguagesRepository: RepositorySync<LanguageDataModel, MobileContentLanguagesApi> {
    
    private let api: MobileContentLanguagesApi
    private let realmPersistence: RealmRepositorySyncPersistence<LanguageDataModel, LanguageCodable, RealmLanguage>
    
    init(api: MobileContentLanguagesApi, realmDatabase: RealmDatabase) {
        
        self.api = api
        
        let realmPersistence = RealmRepositorySyncPersistence<LanguageDataModel, LanguageCodable, RealmLanguage>(
            realmDatabase: realmDatabase,
            dataModelMapping: RealmLanguageDataModelMapping()
        )
        
        self.realmPersistence = realmPersistence
        
        super.init(
            externalDataFetch: api,
            persistence: realmPersistence
        )
    }

    // MARK: - Example using SwiftDatabase for iOS 17 and up. ~Levi
    /*
    private let api: MobileContentLanguagesApi
    private let swiftDataPersistence: (any RepositorySyncPersistence)?
    private let realmPersistence: (any RepositorySyncPersistence)?
    
    init(api: MobileContentLanguagesApi, realmDatabase: RealmDatabase) {
        
        self.api = api
        
        let persistence: any RepositorySyncPersistence<LanguageDataModel, LanguageCodable>
        
        if #available(iOS 17, *) {
            
            persistence = SwiftRepositorySyncPersistence(
                swiftDatabase: SharedSwiftDatabase.shared.swiftDatabase,
                dataModelMapping: SwiftLanguageDataModelMapping()
            )
            
            swiftDataPersistence = persistence
            realmPersistence = nil
        }
        else {
            
            persistence = RealmRepositorySyncPersistence(
                realmDatabase: realmDatabase,
                dataModelMapping: RealmLanguageDataModelMapping()
            )
            
            swiftDataPersistence = nil
            realmPersistence = persistence
        }
        
        super.init(
            externalDataFetch: api,
            persistence: persistence
        )
    }
    
    @available(iOS 17, *)
    private func getSwiftDataPersistence() -> SwiftRepositorySyncPersistence<LanguageDataModel, LanguageCodable, SwiftLanguage>? {
        return swiftDataPersistence as? SwiftRepositorySyncPersistence<LanguageDataModel, LanguageCodable, SwiftLanguage>
    }
    
    private func getRealmPersistence() -> RealmRepositorySyncPersistence<LanguageDataModel, LanguageCodable, RealmLanguage>? {
        return realmPersistence as? RealmRepositorySyncPersistence<LanguageDataModel, LanguageCodable, RealmLanguage>
    }
    
    func getCachedLanguage(code: BCP47LanguageIdentifier) -> LanguageDataModel? {
        
        if #available(iOS 17, *) {
            
            guard let swiftDataPersistence = getSwiftDataPersistence() else {
                return nil
            }
            
            let filter = #Predicate<SwiftLanguage> { object in
                object.code.localizedStandardContains(code)
            }
                    
            return swiftDataPersistence.getObjects(query: SwiftDatabaseQuery.filter(filter: filter)).first
        }
        else {
            
            guard let realmPersistence = getRealmPersistence() else {
                return nil
            }
            
            let filter = NSPredicate(format: "\(#keyPath(RealmLanguage.code)) == [c] %@", code.lowercased())
            
            return realmPersistence.getObjects(query: RealmDatabaseQuery.filter(filter: filter)).first
        }
    }*/
    
    func getCachedLanguage(code: BCP47LanguageIdentifier) -> LanguageDataModel? {
        
        let filter = NSPredicate(format: "\(#keyPath(RealmLanguage.code)) == [c] %@", code.lowercased())
        
        return realmPersistence.getObjects(query: RealmDatabaseQuery.filter(filter: filter)).first
    }
    
    func getCachedLanguages(languageCodes: [String]) -> [LanguageDataModel] {
        return languageCodes.compactMap({ getCachedLanguage(code: $0) })
    }
    
    func syncLanguagesFromRemote(requestPriority: RequestPriority) -> AnyPublisher<RepositorySyncResponse<LanguageDataModel>, Never> {
        
        return api.getObjectsPublisher(
            requestPriority: requestPriority
        )
        .flatMap { (getObectsResponse: RepositorySyncResponse<LanguageCodable>) in
            
            let response: RepositorySyncResponse<LanguageDataModel> = super.storeExternalObjectsToPersistence(
                externalObjects: getObectsResponse.objects,
                deleteObjectsNotFoundInExternalObjects: true
            )
            
            return Just(response)
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
    
    func syncLanguagesFromJsonFileCache() -> AnyPublisher<RepositorySyncResponse<LanguageDataModel>, Never> {
        
        return LanguagesJsonFileCache(
            jsonServices: JsonServices()
        )
        .getLanguages()
        .publisher
        .flatMap { (languages: [LanguageCodable]) -> AnyPublisher<RepositorySyncResponse<LanguageDataModel>, Never> in
            
            let response: RepositorySyncResponse<LanguageDataModel> = super.storeExternalObjectsToPersistence(
                externalObjects: languages,
                deleteObjectsNotFoundInExternalObjects: false
            )
                    
            return Just(response)
                .eraseToAnyPublisher()
        }
        .catch { (error: Error) in
            
            let response = RepositorySyncResponse<LanguageDataModel>(
                objects: [],
                errors: [error]
            )
            
            return Just(response)
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}
