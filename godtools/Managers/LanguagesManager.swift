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
    static let shared = LanguagesManager()
    
    let path = "languages"
    
    var languages = Languages()
    var selectingPrimaryLanguage = true
    
    override init() {
        super.init()
        serializer.registerResource(LanguageResource.self)
    }
    
    func loadFromDisk(id: String) -> Language? {
        return findEntityByRemoteId(Language.self, remoteId: id)
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
        languages = findAllEntities(Language.self, sortedByKeyPath: "localizedName")
        return languages
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
    
    fileprivate func selectedLanguageId() -> String? {
        if selectingPrimaryLanguage {
            return GTSettings.shared.primaryLanguageId
        } else {
            return GTSettings.shared.parallelLanguageId
        }
    }
    
    fileprivate func setSelectedLanguageId(_ id: String) {
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

extension LanguagesManager: LanguageTableViewCellDelegate {
    func deleteButtonWasPressed(_ cell: LanguageTableViewCell) {
        self.recordLanguageShouldDelete(language: cell.language!)
    }
    
    func downloadButtonWasPressed(_ cell: LanguageTableViewCell) {
        self.recordLanguageShouldDownload(language: cell.language!)
        TranslationZipImporter.shared.download(language: cell.language!)
    }
}

extension LanguagesManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let language = languages[indexPath.row]
        self.setSelectedLanguageId(language.remoteId)
        self.recordLanguageShouldDownload(language: language)
        TranslationZipImporter.shared.download(language: language)
        self.refreshCellState(tableView: tableView, indexPath: indexPath)
    }
    
    private func refreshCellState(tableView: UITableView, indexPath: IndexPath) {
        let cell = self.tableView(tableView, cellForRowAt: indexPath) as! LanguageTableViewCell
        cell.language = self.languages[indexPath.section]
        tableView.reloadData()
    }
}

extension LanguagesManager: UITableViewDataSource {
    
    static let languageCellIdentifier = "languageCell"
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let language = languages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: LanguagesManager.languageCellIdentifier) as! LanguageTableViewCell
        
        cell.cellDelegate = self
        cell.language = language
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let language = languages[indexPath.row]
        let selected = language.remoteId == self.selectedLanguageId()
        
        if selected {
            cell.setSelected(selected, animated: true)
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }
}
