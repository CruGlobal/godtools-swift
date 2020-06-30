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

class LanguagesManager: GTDataManager {
            
    //private let languageSettingsCache: LanguageSettingsCacheType = LanguageSettingsUserDefaultsCache()
    
    let primaryLanguage: ObservableValue<Language?> = ObservableValue(value: nil)
    let parallelLanguage: ObservableValue<Language?> = ObservableValue(value: nil)
    
    static var _defaultLanguage: Language?
    static var defaultLanguage: Language? {
        get {
            if _defaultLanguage == nil {
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
                
        if let currentLocaleLanguage = loadFromDisk(locale: Locale.current) {
            return currentLocaleLanguage
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
    
    func loadFromDisk(locale: Locale) -> Language? {
        
        let separator: String = "-"
        var possibleLocaleIdCombinations: [String] = Array()
        
        if let languageCode = locale.languageCode, let scriptCode = locale.scriptCode, let regionCode = locale.regionCode {
            let code: String = [languageCode, scriptCode, regionCode].joined(separator: separator)
            possibleLocaleIdCombinations.append(code)
        }
        
        if let languageCode = locale.languageCode, let scriptCode = locale.scriptCode {
            let code: String = [languageCode, scriptCode].joined(separator: separator)
            possibleLocaleIdCombinations.append(code)
        }
        
        if let languageCode = locale.languageCode, let regionCode = locale.regionCode {
            let code: String = [languageCode, regionCode].joined(separator: separator)
            possibleLocaleIdCombinations.append(code)
        }
        
        if let languageCode = locale.languageCode {
            possibleLocaleIdCombinations.append(languageCode)
        }
        
        for id in possibleLocaleIdCombinations {
            
            let languages = realm.objects(Language.self).filter(NSPredicate(format: "code".appending(" = [c] %@"), id.lowercased()))
            
            if let language = languages.first {
                return language
            }
        }
                
        return nil
    }
    
    func loadPrimaryLanguageFromDisk() -> Language? {
        
        var language: Language?
        
//        if let id = languageSettingsCache.primaryLanguageId.value {
//            language = loadFromDisk(id: id)
//        }
        
        primaryLanguage.accept(value: language)
        
        return language
    }
    
    func loadParallelLanguageFromDisk(arrivingFromUniversalLink: Bool = false) -> Language? {
        
        // TOOD: Why is this needed? ~Levi
        if !arrivingFromUniversalLink {
            
            var language: Language?
            
//            if let id = languageSettingsCache.parallelLanguageId.value {
//                language = loadFromDisk(id: id)
//            }
            
            parallelLanguage.accept(value: language)
            
            return language
        }
        else {
            // TOOD: Why is this needed? ~Levi
            if GTSettings.shared.parallelLanguageCode == nil {
                return nil
            }
            if let parallelLanguageCode = loadFromDisk(code: GTSettings.shared.parallelLanguageCode!) {
                return parallelLanguageCode
            }
        }
        
        return nil
    }
    
    func loadFromDisk() -> List<Language> {
        let languagesUnfiltered = findAllEntities(Language.self)

        let languages = languagesUnfiltered.filter { (lang) -> Bool in
            return lang.translations.contains(where: { $0.isPublished })
        }
        
        let lSeq = languages.sorted(by: { return $0.localizedName() < $1.localizedName() })
        let ls = List<Language>()
        ls.append(objectsIn: lSeq)
        return ls
    }
    
    func loadFromRemote() -> Promise<List<Language>> {
                
        return issueGETRequest()
            .then { data -> Promise<List<Language>> in
                DispatchQueue.global(qos: .userInitiated).async {
                    // TODO: this should be using the jsonapi parser framework -DF
//                    let remoteLanguages = JSONResourceFactory.initializeArrayFrom(data: data, type: LanguageResource.self)
                    
                    // additional processing
                    let decoder = JSONDecoder()
                    
                    var remotes = [LanguageResource]()
                    if let langResource = try? decoder.decode(LangResource.self, from:data),
                        let items = langResource.data {
                        for item in items {
                            // skip langs without translations
                            if (item.relationships?.translations?.data?.count)! > 0 {
                                let lang = LanguageResource()
                                lang.id = item.id!
                                lang.code = item.attributes?.code! ?? ""
                                lang.name = item.attributes?.name
                                lang.direction = item.attributes?.direction! ?? ""
                                remotes.append(lang)
                            }
                        }
                    }

                    DispatchQueue.main.async {
                        self.saveToDisk(remotes)
                    }
                }
                
                return .value(self.loadFromDisk())
            }
            .ensure {

        }
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
            
                // update language
                if let cachedlanguage = findEntityByRemoteId(Language.self, remoteId: remoteLanguage.id) {
                    cachedlanguage.code = remoteLanguage.code
                    cachedlanguage.direction = remoteLanguage.direction
                    cachedlanguage.name = remoteLanguage.name
                    cachedLanguages.append(cachedlanguage)
                    realm.add(cachedlanguage, update: .all)
                }
                // add language
                else {
                    let newCachedLanguage = Language()
                    newCachedLanguage.remoteId = remoteLanguage.id
                    newCachedLanguage.code = remoteLanguage.code
                    newCachedLanguage.direction = remoteLanguage.direction  // IO: small bugfix
                    newCachedLanguage.name = remoteLanguage.name
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
    
    func updatePrimaryLanguage(language: Language) {
        
        // TODO: Look into what this is for. ~Levi
        LanguagesManager.defaultLanguage = language
        
        //languageSettingsCache.cachePrimaryLanguageId(language: language)
        
        primaryLanguage.accept(value: language)
    }
    
    func updateParallelLanguage(language: Language) {
        
        //languageSettingsCache.cacheParallelLanguageId(language: language)
        
        // TODO: What is this set for. ~Levi
        UserDefaults.standard.set((language.code), forKey: "kParallelLanguageCode")
        
        parallelLanguage.accept(value: language)
    }
    
    func deleteParallelLanguage() {
        //languageSettingsCache.deleteParallelLanguageId()
        
        // TODO: What is this set for. ~Levi
        UserDefaults.standard.set(nil, forKey: "kParallelLanguageCode")
        
        parallelLanguage.accept(value: nil)
    }
    
    func setInitialPrimaryLanguage(forceEnglish: Bool = false) {
        safelyWriteToRealm {
            if !forceEnglish {
                if let preferredLanguage = loadDevicePreferredLanguageFromDisk() {
                    updatePrimaryLanguage(language: preferredLanguage)
                    preferredLanguage.shouldDownload = true
                    return
                }
            }
            if let english = loadFromDisk(code: "en") {
                english.shouldDownload = true
                updatePrimaryLanguage(language: english)
            }
        }
    }
    
    func isPrimaryLanguage(language: Language) -> Bool {
        return true//return language.remoteId == languageSettingsCache.primaryLanguageId.value
    }
    
    func isParallelLanguage(language: Language) -> Bool {
        return true//return language.remoteId == languageSettingsCache.parallelLanguageId.value
    }

    func setPrimaryLanguageForInitialDeviceLanguageDownload() {
        if !UserDefaults.standard.bool(forKey: GTConstants.kDownloadDeviceLocaleKey) {
            setInitialPrimaryLanguage()
            UserDefaults.standard.set(true, forKey: GTConstants.kDownloadDeviceLocaleKey)
        }
    }
    
    override func buildURL() -> URL? {
        let baseUrl: String = AppConfig().mobileContentApiBaseUrl
        let path: String = "/languages"
        return URL(string: baseUrl + path)
    }
}
