//
//  LanguagesManager.swift
//  godtools
//
//  Created by Ryan Carlson on 4/18/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import PromiseKit
import Spine
import RealmSwift

class LanguagesManager: GTDataManager {
    
    let path = "languages"
    
    var selectingPrimaryLanguage = true
    
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
    
    override init() {
        super.init()
        serializer.registerResource(LanguageResource.self)
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
        else if arrivingFromUniversalLink {
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
        return Languages(languages.sorted(by: { return $0.localizedName() < $1.localizedName() }))
    }
    
    func loadFromRemote() -> Promise<Languages> {
        showNetworkingIndicator()
        
        return issueGETRequest()
            .then { data -> Promise<Languages> in
                do {
                    let remoteLanguages = try self.serializer.deserializeData(data).data as! [LanguageResource]
                    
                    self.saveToDisk(remoteLanguages)
                } catch {
                    return Promise(error: error)
                }
                return Promise(value:self.loadFromDisk())
        }
            .always {
                self.hideNetworkIndicator()
        }
    }
    
    func loadInitialContentFromDisk() {
        let languagesPath = URL(fileURLWithPath:Bundle.main.path(forResource: "languages", ofType: "json")!)
        let languagesData = try! Data(contentsOf: languagesPath)
        let languagesDeserialized = try! serializer.deserializeData(languagesData).data as! [LanguageResource]
        
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
                if let cachedlanguage = findEntityByRemoteId(Language.self, remoteId: remoteLanguage.id!) {
                    cachedlanguage.code = remoteLanguage.code!
                    
                    if let direction = remoteLanguage.direction {
                        cachedlanguage.direction = direction
                    }
                    
                    cachedLanguages.append(cachedlanguage)
                    continue
                }
                
                let newCachedLanguage = Language()
                newCachedLanguage.remoteId = remoteLanguage.id!
                newCachedLanguage.code = remoteLanguage.code!
                cachedLanguages.append(newCachedLanguage)
                realm.add(newCachedLanguage)
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
