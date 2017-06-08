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
    
    var languages = List<Language>()
    let languagesManager = LanguagesManager()
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
        super.viewDidLoad()
        
        registerCells()
        loadLanguages()
    }
    
    // MARK: - Load data
    
    func loadLanguages() {
        languages = languagesManager.loadFromDisk()

        tableView.reloadData()
    }
    
    // MARK: - Helpers
    
    func selectingPrimaryLanguage(_ primary:Bool) {
        if primary {
            screenTitleAux = "primary_language"
        } else {
            screenTitleAux = "parallel_language"
        }
        
        languagesManager.selectingPrimaryLanguage = primary
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
        TranslationZipImporter.shared.download(language: cell.language!)
    }
}
