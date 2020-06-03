//
//  ResourcesRealmCache.swift
//  godtools
//
//  Created by Levi Eggert on 5/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class ResourcesRealmCache: ResourcesRealmCacheType {
    
    private let mainThreadRealm: Realm
    
    required init(mainThreadRealm: Realm) {
        
        self.mainThreadRealm = mainThreadRealm
    }
    
    func cacheResources(resources: ResourcesJson, complete: @escaping ((_ error: ResourcesRealmCacheError?) -> Void)) {
                
        DispatchQueue.global().async { [weak self] in
                        
            var realmObjectsToCache: [Object] = Array()
            var realmLanguagesDictionary: [String: RealmLanguage] = Dictionary()
            var realmResourcesDictionary: [String: RealmResource] = Dictionary()
            
            let jsonServices = JsonServices()
            
            // Decode languages jaon array
            
            let decodedLanguagesResult: Result<RealmLanguagesData?, Error> = jsonServices.decodeObject(data: resources.languagesJson)
            
            switch decodedLanguagesResult {
            case .success(let realmLanguagesObject):
                if let languages = realmLanguagesObject?.data {
                    for language in languages {
                        realmObjectsToCache.append(language)
                        realmLanguagesDictionary[language.id] = language
                    }
                }
            case .failure(let error):
                complete(.failedToDecodeLanguages(error: error))
                return
            }
            
            // Decode resources json array
            
            let resourcesJsonObjectResult: Result<Any?, Error> = jsonServices.getJsonObject(data: resources.resourcesPlusLatestTranslationsAndAttachmentsJson, options: [])
            let resourcesJsonObject: [String: Any]
            
            switch resourcesJsonObjectResult {
                
            case .success(let object):
                resourcesJsonObject = object as? [String: Any] ?? Dictionary()
            case .failure(let error):
                complete(.failedToDecodeResources(error: error))
                return
            }
            
            let resourcesJsonArray: [[String: Any]] = resourcesJsonObject["data"] as? [[String: Any]] ?? Array()
            let latestTranslationsAndAttachmentsJsonArray: [[String: Any]] = resourcesJsonObject["included"] as? [[String: Any]] ?? Array()
            
            for resourceJson in resourcesJsonArray {
                
                let resourceDataResult: Result<Data?, Error> = jsonServices.getJsonData(json: resourceJson)
                var resourceData: Data?
                
                switch resourceDataResult {
                case .success(let data):
                    resourceData = data
                case .failure(let error):
                    complete(.failedToDecodeResources(error: error))
                    return
                }
                
                let realmResourceResult: Result<RealmResource?, Error> = jsonServices.decodeObject(data: resourceData)
                switch realmResourceResult {
                case .success(let realmResource):
                    if let realmResource = realmResource {
                        realmObjectsToCache.append(realmResource)
                        realmResourcesDictionary[realmResource.id] = realmResource
                    }
                case .failure(let error):
                    complete(.failedToDecodeResources(error: error))
                    return
                }
            }
            
            // Decode latest translations and attachments
            
            for latestObjectJson in latestTranslationsAndAttachmentsJsonArray {
                
                let latestType: String? = latestObjectJson["type"] as? String
                                
                let resourceDataObject: [String: Any]? = ((latestObjectJson["relationships"] as? [String: Any])?["resource"] as? [String: Any])?["data"] as? [String: Any]
                let relationshipResourceId: String? = resourceDataObject?["id"] as? String
                
                let languageDataObject: [String: Any]? = ((latestObjectJson["relationships"] as? [String: Any])?["language"] as? [String: Any])?["data"] as? [String: Any]
                let relationshipLanguageId: String? = languageDataObject?["id"] as? String

                if latestType == "translation" {
                    
                    let translationDataResult: Result<Data?, Error> = jsonServices.getJsonData(json: latestObjectJson)
                    var translationData: Data?
                    
                    switch translationDataResult {
                    case .success(let data):
                        translationData = data
                    case .failure(let error):
                        complete(.failedToDecodeTranslations(error: error))
                        return
                    }
                    
                    let realmTranslationResult: Result<RealmTranslation?, Error> = jsonServices.decodeObject(data: translationData)
                    switch realmTranslationResult {
                    case .success(let realmTranslation):
                        if let realmTranslation = realmTranslation {
                            if let relationshipResourceId = relationshipResourceId {
                                realmTranslation.resource = realmResourcesDictionary[relationshipResourceId]
                            }
                            if let relationshipLanguageId = relationshipLanguageId {
                                realmTranslation.language = realmLanguagesDictionary[relationshipLanguageId]
                            }
                            realmObjectsToCache.append(realmTranslation)
                        }
                    case .failure(let error):
                        complete(.failedToDecodeTranslations(error: error))
                        return
                    }
                }
                else if latestType == "attachment" {
                    
                    let attachmentDataResult: Result<Data?, Error> = jsonServices.getJsonData(json: latestObjectJson)
                    var attachmentData: Data?
                    
                    switch attachmentDataResult {
                    case .success(let data):
                        attachmentData = data
                    case .failure(let error):
                        complete(.failedToDecodeAttachments(error: error))
                        return
                    }
                    
                    let realmAttachmentResult: Result<RealmAttachment?, Error> = jsonServices.decodeObject(data: attachmentData)
                    switch realmAttachmentResult {
                    case .success(let realmAttachment):
                        if let realmAttachment = realmAttachment {
                            if let relationshipResourceId = relationshipResourceId {
                                realmAttachment.resource = realmResourcesDictionary[relationshipResourceId]
                            }
                            realmObjectsToCache.append(realmAttachment)
                        }
                    case .failure(let error):
                        complete(.failedToDecodeAttachments(error: error))
                        return
                    }
                }
            }
            
            DispatchQueue.main.async { [weak self] in
                                
                if let realm = self?.mainThreadRealm {
                    
                    do {
                        try realm.write {
                            realm.add(realmObjectsToCache, update: .modified)
                        }
                        
                        complete(nil)
                    }
                    catch let error {
                        complete(.failedToCacheToRealm(error: error))
                    }
                }
            }
        }
    }
}
