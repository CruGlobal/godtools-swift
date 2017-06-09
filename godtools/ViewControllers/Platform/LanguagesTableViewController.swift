//
//  GTLanguagesTableViewController.swift
//  godtools
//
//  Created by Devserker on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit
import RealmSwift

protocol LanguagesTableViewControllerDelegate {
}

class LanguagesTableViewController: BaseViewController {
    
    static let languageCellIdentifier = "languageCell"
    
    var delegate: LanguagesTableViewControllerDelegate?
    
    var languages = Languages()
    let languagesManager = LanguagesManager()
    let zipImporter = TranslationZipImporter()
    
    var selectingForPrimary = true
    
    var screenTitleAux: String = "primary_language"
    
    override var screenTitle: String {
        get {
            return screenTitleAux.localized
        }
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        if !selectingForPrimary, languagesManager.loadParallelLanguageFromDisk() != nil {
            addClearButton()
        }

        super.viewDidLoad()
        
        registerCells()
        loadLanguages()
        configureScreenTitleAux()
    }
    
    // MARK: - Load data
    
    func loadLanguages() {
        languagesManager.selectingPrimaryLanguage = selectingForPrimary
        languages = languagesManager.loadFromDisk()

        if !selectingForPrimary {
            configureListForParallelChoice()
        }
        tableView.reloadData()
    }
    
    // MARK: - Helpers
    
    override func clearButtonAction() {
        GTSettings.shared.parallelLanguageId = nil
        tableView.reloadData()
    }

    private func configureScreenTitleAux() {
        if selectingForPrimary {
            self.screenTitleAux = "primary_language"
        } else {
            self.screenTitleAux = "parallel_language"
        }
    }
    
    private func configureListForParallelChoice() {
        // remove primary language from list of options for parallel
        if let primaryLanguage = languagesManager.loadPrimaryLanguageFromDisk() {
            if let index = languages.index(of: primaryLanguage) {
                languages.remove(objectAtIndex: index)
            }
        }
    }
    
    fileprivate func registerCells() {
        tableView.register(UINib(nibName: "LanguageTableViewCell", bundle: nil),
                           forCellReuseIdentifier: LanguagesTableViewController.languageCellIdentifier)
    }
}

extension LanguagesTableViewController: LanguageTableViewCellDelegate {
    func deleteButtonWasPressed(_ cell: LanguageTableViewCell) {
        languagesManager.recordLanguageShouldDelete(language: cell.language!)
    }
    
    func downloadButtonWasPressed(_ cell: LanguageTableViewCell) {
        languagesManager.recordLanguageShouldDownload(language: cell.language!)
        zipImporter.download(language: cell.language!)
    }
}
