//
//  LanguageSettings+TableDelegate.swift
//  godtools
//
//  Created by Ryan Carlson on 6/7/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

extension LanguagesTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var language: Language
        if isFiltering {
            let namedLanguage = filteredNamedLanguages[indexPath.row]
            language = namedLanguage.language
        } else  {
            language = languages[indexPath.row]
        }
        languagesManager.setSelectedLanguage(language)
        languagesManager.recordLanguageShouldDownload(language: language)
        navigationController?.handleLanguageSwitch()
        zipImporter.download(language: language)
        self.refreshCellState(tableView: tableView, indexPath: indexPath, language: language)
        baseDelegate?.goBack()
    }
    
    private func refreshCellState(tableView: UITableView, indexPath: IndexPath, language: Language) {
        let cell = tableView.cellForRow(at: indexPath) as! LanguageTableViewCell
        cell.language = language
        tableView.reloadData()
    }
}
