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
    
    var delegate: LanguagesTableViewControllerDelegate?
    
    var languages = Languages()
    var namedLanguages = [NamedLanguage]()
    var filteredNamedLanguages = [NamedLanguage]()
    let languagesManager = LanguagesManager()
    let zipImporter = TranslationZipImporter()
    
    var isFiltering: Bool = false {
        didSet {
            changeDataSource()
        }
    }
    
    var searchTool: UISearchBar!
    var searchBarIsOnScreen = false
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
        addSearchButton()
        super.viewDidLoad()
        if let nvHt = self.navigationController?.navigationBar.frame.height {
            let statusHeight = UIApplication.shared.statusBarFrame.height
            navHeight = nvHt + statusHeight
        }
        
        registerCells()
        loadLanguages()
        configureScreenTitleAux()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
    
    override func searchButtonAction() {
        if !searchBarIsOnScreen {
            animateSearchOnScreen()
        } else {
            animateSearchOffScreen()
        }
        searchBarIsOnScreen = !searchBarIsOnScreen
    }
    
    func setUpSearchBar() {
        searchTool = UISearchBar(frame: CGRect(x: self.screenWidth, y: navHeight, width: screenWidth, height: screenHeight/12))
        searchTool.delegate = self
        searchTool.barTintColor = .gtBlue
        searchTool.isTranslucent = true
        searchTool.returnKeyType = .done
        view.addSubview(searchTool)
    }
    
    func animateSearchOnScreen() {
        UIView.animate(withDuration: 0.3) {
            self.blankView = UIView(frame: CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight/12))
            self.tableView.tableHeaderView = self.blankView
            self.searchTool.frame = CGRect(x: 0, y: self.navHeight, width: self.screenWidth, height: self.screenHeight/12)
            self.searchTool.becomeFirstResponder()
        }
    }
    
    func animateSearchOffScreen() {
        UIView.animate(withDuration: 0.25) {
            self.searchTool.frame = CGRect(x: self.screenWidth, y: self.navHeight, width: self.screenWidth, height: self.screenHeight/12)
            self.blankView = UIView(frame: CGRect(x: self.screenWidth, y: 0, width: self.screenWidth, height: self.screenHeight/12))
            self.tableView.tableHeaderView = UIView()
            self.searchTool.resignFirstResponder()
        }
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
    
    func changeDataSource() {

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

extension LanguagesTableViewController: UISearchBarDelegate {
    
    func searchBarIsEmpty() -> Bool {
        return searchTool.text?.isEmpty ?? true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            searchBar.becomeFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            filterContentForSearchText(searchText)
            isFiltering = true
            tableView.reloadData()
        } else {
            isFiltering = false
            tableView.reloadData()
        }
    }
    
    // Probably going to remove!!!
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        //tableView.reloadData()
//        searchBar.resignFirstResponder()
//        searchButtonAction()
        
    }
    
}
