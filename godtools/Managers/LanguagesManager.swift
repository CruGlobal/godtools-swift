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
    
    override init() {
        super.init()
        serializer.registerResource(LanguageResource.self)
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
        
        return loadFromDisk(id: GTSettings.shared.primaryLanguageId!)
    }
    
    func loadParallelLanguageFromDisk() -> Language? {
        if GTSettings.shared.parallelLanguageId == nil {
            return nil
        }
        
        return loadFromDisk(id: GTSettings.shared.parallelLanguageId!)
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
    
    func recordLanguageShouldDelete(language: Language) {
        safelyWriteToRealm {
            language.shouldDownload = false
            for translation in language.translations {
                translation.isDownloaded = false
            }
            TranslationFileRemover().deleteUnusedPages()
        }
    }

    private func saveToDisk(_ languages: [LanguageResource]) {
        safelyWriteToRealm {
            for remoteLanguage in languages {
                if let cachedlanguage = findEntityByRemoteId(Language.self, remoteId: remoteLanguage.id!) {
                    cachedlanguage.code = remoteLanguage.code!
                    return
                }
                
                let newCachedLanguage = Language()
                newCachedLanguage.remoteId = remoteLanguage.id!
                newCachedLanguage.code = remoteLanguage.code!
                realm.add(newCachedLanguage)
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
    
    func setSelectedLanguageId(_ id: String) {
        if selectingPrimaryLanguage {
            GTSettings.shared.primaryLanguageId = id
            if id == GTSettings.shared.parallelLanguageId {
                GTSettings.shared.parallelLanguageId = nil
            }

        } else {
            GTSettings.shared.parallelLanguageId = id
        }
    }
    
    override func buildURL() -> URL? {
        return Config.shared().baseUrl?
                              .appendingPathComponent(self.path)
    }
}
