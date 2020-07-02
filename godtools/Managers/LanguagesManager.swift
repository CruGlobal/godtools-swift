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
        return nil
    }
    
    func loadFromDisk(code: String) -> Language? {
        return nil
    }
    
    func loadFromDisk(locale: Locale) -> Language? {
            
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

        }
        
        return nil
    }
    
    func loadFromDisk() -> List<Language> {
        
        return List<Language>()
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

    }
    
    private func saveToDisk(_ languages: [LanguageResource]) {
        
    }
    
    private func purgeDeletedLanguages(foundLanguages: [Language]) {

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
    
    func isPrimaryLanguage(language: Language) -> Bool {
        return true//return language.remoteId == languageSettingsCache.primaryLanguageId.value
    }
    
    func isParallelLanguage(language: Language) -> Bool {
        return true//return language.remoteId == languageSettingsCache.parallelLanguageId.value
    }

    override func buildURL() -> URL? {
        let baseUrl: String = AppConfig().mobileContentApiBaseUrl
        let path: String = "/languages"
        return URL(string: baseUrl + path)
    }
}
