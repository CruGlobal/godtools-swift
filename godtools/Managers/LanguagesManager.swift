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
import MagicalRecord

class LanguagesManager: GTDataManager {
    static let shared = LanguagesManager()
    
    let path = "/languages"
    
    var languages = [Language]()
    var selectingPrimaryLanguage = true
    
    override init() {
        super.init()
        serializer.registerResource(LanguageResource.self)
    }
    
    func loadFromDisk(id: String) -> Language {
        let language = Language.mr_findFirst(byAttribute: "remoteId", withValue: id)!
        language.localizedName = NSLocale.current.localizedString(forLanguageCode: language.code!)
        
        return language
    }
    
    func loadPrimaryLanguageFromDisk() -> Language? {
        if GTSettings.shared.primaryLanguageId == nil {
            return nil
        }
        
        return loadFromDisk(id: GTSettings.shared.primaryLanguageId!)
    }
    
    func loadFromDisk() -> [Language] {
        languages = Language.mr_findAll() as! [Language]
        
        for language in languages {
            language.localizedName = NSLocale.current.localizedString(forLanguageCode: language.code!)
        }
        
        languages = languages.sorted { (language1, language2) -> Bool in
            return language1.localizedName!.compare(language2.localizedName!).rawValue < 0
        }
        
        return languages
    }
    
    func loadFromRemote() -> Promise<[Language]> {
        showNetworkingIndicator()
        
        return issueGETRequest()
            .then { data -> Promise<[Language]> in
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
        language.shouldDownload = true
        saveToDisk()
    }
    
    func recordLanguageShouldDelete(language: Language) {
        language.shouldDownload = false
        saveToDisk()
    }
    
    private func saveToDisk(_ languages: [LanguageResource]) {
        MagicalRecord.save(blockAndWait: { (context) in
            for remoteLanguage in languages {
                let cachedlanguage = Language.mr_findFirstOrCreate(byAttribute: "remoteId", withValue: remoteLanguage.id!, in: context)
                cachedlanguage.code = remoteLanguage.code
            }
        })
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
        } else {
            GTSettings.shared.parallelLanguageId = id
        }
    }
    
    override func buildURLString() -> String {
        return "\(GTConstants.kApiBase)\(path)"
    }
}

extension LanguagesManager: LanguageTableViewCellDelegate {
    func deleteButtonWasPressed(_ cell: LanguageTableViewCell) {
        self.recordLanguageShouldDelete(language: cell.language!)
    }
    
    func downloadButtonWasPressed(_ cell: LanguageTableViewCell) {
        self.recordLanguageShouldDownload(language: cell.language!)
    }
}

extension LanguagesManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let language = languages[indexPath.row]
        self.setSelectedLanguageId(language.remoteId!)
        self.recordLanguageShouldDownload(language: language)
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
