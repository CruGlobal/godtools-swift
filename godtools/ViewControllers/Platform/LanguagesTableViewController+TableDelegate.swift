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
        languagesManager.setSelectedLanguageId(language.remoteId)
        languagesManager.recordLanguageShouldDownload(language: language)
        TranslationZipImporter.shared.download(language: language)
        self.refreshCellState(tableView: tableView, indexPath: indexPath)
    }
    
    private func refreshCellState(tableView: UITableView, indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! LanguageTableViewCell
        cell.language = languages[indexPath.section]
        tableView.reloadData()
    }
}
