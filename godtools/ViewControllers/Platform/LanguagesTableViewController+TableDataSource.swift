//
//  LanguagesTableViewController+TableDataSource.swift
//  godtools
//
//  Created by Ryan Carlson on 6/7/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

extension LanguagesTableViewController: UITableViewDataSource {
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var language: Language
        if isFiltering {
            let namedLanguage = filteredNamedLanguages[indexPath.row]
            language = namedLanguage.language
        } else  {
            language = languages[indexPath.row]
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: LanguagesTableViewController.languageCellIdentifier) as! LanguageTableViewCell
        
        cell.cellDelegate = self
        cell.language = language
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        var language: Language
        if isFiltering {
            let namedLanguage = filteredNamedLanguages[indexPath.row]
            language = namedLanguage.language
        } else  {
            language = languages[indexPath.row]
        }
        let selected = language.remoteId == languagesManager.selectedLanguageId()
        
        if selected {
            cell.setSelected(selected, animated: true)
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFiltering {
           return filteredNamedLanguages.count
        } else  {
            return languages.count
        }
        
    }
}
