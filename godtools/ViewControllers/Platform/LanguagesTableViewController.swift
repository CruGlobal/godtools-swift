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
        self.registerCells()
        
        self.loadFromDisk()
    }
    
    // MARK: - Load data
    
    func loadFromDisk() {
        languages = languagesManager.loadFromDisk()

        self.tableView.reloadData()
    }
    
    // MARK: - Helpers
    
    func selectingPrimaryLanguage(_ primary:Bool) {
        if primary {
            self.screenTitleAux = "primary_language"
        } else {
            self.screenTitleAux = "parallel_language"
        }
        
        languagesManager.selectingPrimaryLanguage = primary
    }

    fileprivate func registerCells() {
        self.tableView.register(UINib(nibName: "LanguageTableViewCell", bundle: nil),
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
