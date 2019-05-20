//
//  LanguagesManager.swift
//  godtools
//
//  Created by Ryan Carlson on 4/18/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit
import Alamofire
import PromiseKit
import RealmSwift


/* Languages sample
  "data": [
        {
            "id": "12",
            "type": "language",
            "attributes": {
                "code": "ar",
                "name": "Arabic",
                "direction": "rtl"
            },
            "relationships": {
                "translations": {
                    "data": [
                        {
                            "id": "113",
                            "type": "translation"
                        }
                    ]
                },
                "custom-pages": {
                    "data": []
                }
            }
        },
 ...
 */

struct LangResource: Decodable {
    var data: [LangResourceItem]?
}
struct LangResourceItem: Decodable {
    var id: String?
    var type: String?
    var attributes: LangResourceAttributes?
    var relationships: LangResourceRelationships?
}
struct LangResourceAttributes: Decodable {
    var code: String?
    var name: String?
    var direction: String?
}
struct LangResourceRelationships: Decodable {
    var translations: LangResourceTranslations?
}
struct LangResourceTranslations: Decodable {
    var data: [ [String: String] ]?
}





class LanguagesManager: GTDataManager {
    
    let path = "languages"
    
    var selectingPrimaryLanguage = true
    
    static var _defaultLanguage: Language?
    static var defaultLanguage: Language? {
        get {
            if _defaultLanguage == nil || _defaultLanguage?.isInvalidated == true {
                let languagesManager = LanguagesManager()
                _defaultLanguage = languagesManager.loadPrimaryLanguageFromDisk()
            }
            UserDefaults.standard.set(( _defaultLanguage?.code ?? "en"), forKey: "kPrimaryLanguageCode")
            return _defaultLanguage
        }
        set {
            _defaultLanguage = newValue
            UserDefaults.standard.set(( _defaultLanguage?.code ?? "en"), forKey: "kPrimaryLanguageCode")
        }
    }
    
    func loadDevicePreferredLanguageFromDisk() -> Language? {
        if let preferredLanguageCode = Locale.preferredLanguages.first {
            if let preferredLanguage = loadFromDisk(code: preferredLanguageCode) {
                return preferredLanguage
            }
        }
        
        if let localeCode = Locale.current.languageCode {
            return loadFromDisk(code: localeCode)
        }

        return nil
    }
    
    func loadNonEnglishPreferredLanguageFromDisk() -> Language? {
        let devicePreferredLanguage = loadDevicePreferredLanguageFromDisk()
        
        if devicePreferredLanguage?.code == "en" {
            return nil
        }

        return devicePreferredLanguage
    }
    
    func loadFromDisk(id: String) -> Language? {
        return findEntityByRemoteId(Language.self, remoteId: id)
    }
    
    func loadFromDisk(code: String) -> Language? {
        return findEntity(Language.self, byAttribute: "code", withValue: code)
    }
    
    func loadPrimaryLanguageFromDisk() -> Language? {
        if GTSettings.shared.primaryLanguageId == nil {
            return nil
        }
        let primaryLanguage = loadFromDisk(id: GTSettings.shared.primaryLanguageId!)
        return primaryLanguage
    }
    
    func loadParallelLanguageFromDisk(arrivingFromUniversalLink: Bool = false) -> Language? {
        if !arrivingFromUniversalLink {
            if GTSettings.shared.parallelLanguageId == nil {
                return nil
            }
            
            if let parallelLanguage = loadFromDisk(id: GTSettings.shared.parallelLanguageId!) {
                return parallelLanguage
            }
        }
        else {
            if GTSettings.shared.parallelLanguageCode == nil {
                return nil
            }
            if let parallelLanguageCode = loadFromDisk(code: GTSettings.shared.parallelLanguageCode!) {
                return parallelLanguageCode
            }
        }
        
        return nil
    }
    
    func loadFromDisk() -> Languages {
        
        let languages = findAllEntities(Language.self)

//        let languages = languagesUnfiltered.filter { (lang) -> Bool in
//            return lang.translations.contains(where: { $0.isPublished })
//        }
//
        let lSeq = languages.sorted(by: { return $0.localizedName() < $1.localizedName() })
        let ls = Languages()
        ls.append(objectsIn: lSeq)
        return ls
//        return Languages(languages.sorted(by: { return $0.localizedName() < $1.localizedName() }))
    }
    
    func loadFromRemote() -> Promise<Languages> {
        showNetworkingIndicator()
        
        return issueGETRequest()
            .then { data -> Promise<Languages> in
                DispatchQueue.global(qos: .userInitiated).async {
                    // TODO: this should be using the jsonapi parser framework -DF

                    // ... skip languages that have no translations
                    let decoder = JSONDecoder()
                    
                    var remotes = [LanguageResource]()
                    if let langResource = try? decoder.decode(LangResource.self, from:data),
                        let items = langResource.data {
                        for item in items {
                            // skip langs without translations
                            if (item.relationships?.translations?.data?.count)! > 0 {
                                let lang = LanguageResource()
                
                                guard   let id = item.id,
                                        let code = item.attributes?.code,
                                        let direction = item.attributes?.direction!
                                else { continue }
                                
                                lang.id = id
                                lang.code = code
                                lang.direction = direction
                                remotes.append(lang)
                            }
                        }
                    }

                    DispatchQueue.main.async {
                        self.saveToDisk(remotes)
                    }
                }
                
                return Promise(value:self.loadFromDisk())
            }
            .always {
                self.hideNetworkIndicator()
        }
    }
    
    func loadInitialContentFromDisk() {
        guard let path = Bundle.main.path(forResource: "languages", ofType: "json") else { return }
        let languagesURL = URL(fileURLWithPath:path)
        guard let languagesData = try? Data(contentsOf: languagesURL) else { return }
        let languagesDeserialized = JSONResourceFactory.initializeArrayFrom(data: languagesData, type: LanguageResource.self)
        
        saveToDisk(languagesDeserialized)
    }
    
    func recordLanguageShouldDownload(language: Language) {
        safelyWriteToRealm {
            language.shouldDownload = true
        }
    }
    
    private func saveToDisk(_ languages: [LanguageResource]) {

        safelyWriteToRealm {
            var cachedLanguages = [Language]()
            for remoteLanguage in languages {
            
                // update language if it exists
                if let cachedlanguage = findEntityByRemoteId(Language.self, remoteId: remoteLanguage.id) {
                    cachedlanguage.code = remoteLanguage.code
                    cachedlanguage.direction = remoteLanguage.direction
                    cachedLanguages.append(cachedlanguage)
                    realm.add(cachedlanguage, update: true)
                }
                // add language if it doesn't
                else {
                    let newCachedLanguage = Language()
                    newCachedLanguage.remoteId = remoteLanguage.id
                    newCachedLanguage.code = remoteLanguage.code
                    newCachedLanguage.direction = remoteLanguage.direction  // IO: small bugfix
                    cachedLanguages.append(newCachedLanguage)
                    realm.add(newCachedLanguage)
                }
            }
            purgeDeletedLanguages(foundLanguages: cachedLanguages)
        }
    }
    
    private func purgeDeletedLanguages(foundLanguages: [Language]) {
        let allLanguages = findAllEntities(Language.self)
        
        if foundLanguages.count == allLanguages.count {
            return
        }
        
        for language in allLanguages {
            if !foundLanguages.contains(where: { return $0.remoteId == language.remoteId }) {
                realm.delete(language)
            }
        }
    }
    
    func selectedLanguageId() -> String? {
        if selectingPrimaryLanguage {
            return GTSettings.shared.primaryLanguageId
        } else {
            return GTSettings.shared.parallelLanguageId
        }
    }
    
    func setSelectedLanguage(_ language: Language) {
        if selectingPrimaryLanguage {
            LanguagesManager.defaultLanguage = language
            GTSettings.shared.primaryLanguageId = language.remoteId
            if language.remoteId == GTSettings.shared.parallelLanguageId {
                GTSettings.shared.parallelLanguageId = nil
            }

        } else {
            GTSettings.shared.parallelLanguageId = language.remoteId
            UserDefaults.standard.set((language.code), forKey: "kParallelLanguageCode")
        }
    }
    
    func setInitialPrimaryLanguage(forceEnglish: Bool = false) {
        safelyWriteToRealm {
            if !forceEnglish {
                if let preferredLanguage = loadDevicePreferredLanguageFromDisk() {
                    GTSettings.shared.primaryLanguageId = preferredLanguage.remoteId
                    preferredLanguage.shouldDownload = true
                    return
                }
            }
            if let english = loadFromDisk(code: "en") {
                english.shouldDownload = true
                GTSettings.shared.primaryLanguageId = english.remoteId
            }
        }
    }

    func setPrimaryLanguageForInitialDeviceLanguageDownload() {
        if !UserDefaults.standard.bool(forKey: GTConstants.kDownloadDeviceLocaleKey) {
            setInitialPrimaryLanguage()
            UserDefaults.standard.set(true, forKey: GTConstants.kDownloadDeviceLocaleKey)
        }
    }
    
    override func buildURL() -> URL? {
        return Config.shared().baseUrl?
                              .appendingPathComponent(self.path)
    }
}
