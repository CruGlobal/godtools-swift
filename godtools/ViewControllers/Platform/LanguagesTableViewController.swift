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

struct NamedLanguage {
    let language : Language
    let name : String
}

class LanguagesTableViewController: BaseViewController {
    
    static let languageCellIdentifier = "languageCell"
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    var searchBarHeight: CGFloat {
        get {
            return screenHeight/12
        }
    }
    
    var delegate: LanguagesTableViewControllerDelegate?
    
    var languages = Languages()
    var namedLanguages = [NamedLanguage]()
    var filteredNamedLanguages = [NamedLanguage]()
    let languagesManager = LanguagesManager()
    let zipImporter = TranslationZipImporter()
    
    var isFiltering: Bool = false

    var searchTool = UISearchBar()
    var navHeight: CGFloat = 0.0
    var blankView = UIView()
    
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
        addTapToDismissKeyboard()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupSearchBarYValue()
        setUpSearchBar()
    }
    
    // MARK: - Load data
    
    func loadLanguages() {
        languagesManager.selectingPrimaryLanguage = selectingForPrimary
        languages = languagesManager.loadFromDisk()
        for language in languages {
            let name = language.localizedName()
            namedLanguages.append(NamedLanguage(language: language, name: name))
        }

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
            if !isFiltering {
                if let index = languages.index(of: primaryLanguage) {
                    languages.remove(objectAtIndex: index)
                }
            }
        }
    }
    
    fileprivate func registerCells() {
        tableView.register(UINib(nibName: "LanguageTableViewCell", bundle: nil),
                           forCellReuseIdentifier: LanguagesTableViewController.languageCellIdentifier)
    }
    
    // MARK: - Analytics
    
    override func screenName() -> String {
        return "Select Language"
    }
    
    override func siteSection() -> String {
        return "menu"
    }
    
    override func siteSubSection() -> String {
        return "language settings"
    }
    
    // MARK: - Private instance methods
    
    func filterContentForSearchText(_ searchText: String) {
        filteredNamedLanguages = namedLanguages.filter { $0.name.lowercased().contains(searchText.lowercased())  }
        if let primaryLanguage = languagesManager.loadPrimaryLanguageFromDisk() {
            filteredNamedLanguages = filteredNamedLanguages.filter { !$0.name.lowercased().contains(primaryLanguage.localizedName().lowercased()) }
        }
    }

}

extension LanguagesTableViewController: LanguageTableViewCellDelegate {
    func downloadButtonWasPressed(_ cell: LanguageTableViewCell) {
        guard let language = cell.language else {
            return
        }
        
        languagesManager.setSelectedLanguage(language)
        languagesManager.recordLanguageShouldDownload(language: language)

        zipImporter.download(language: language)
        
        navigationController?.popViewController(animated: true)
    }
}
