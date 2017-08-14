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
        let language = languages[indexPath.row]
        languagesManager.setSelectedLanguage(language)
        languagesManager.recordLanguageShouldDownload(language: language)
        zipImporter.download(language: language)
        self.refreshCellState(tableView: tableView, indexPath: indexPath)
        baseDelegate?.goBack()
    }
    
    private func refreshCellState(tableView: UITableView, indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! LanguageTableViewCell
        cell.language = languages[indexPath.section]
        tableView.reloadData()
    }
}
