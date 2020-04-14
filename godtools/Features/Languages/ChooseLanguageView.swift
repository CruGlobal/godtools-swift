//
//  ChooseLanguageView.swift
//  godtools
//
//  Created by Levi Eggert on 4/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ChooseLanguageView: UIViewController {
        
    private let viewModel: ChooseLanguageViewModelType
            
    private var deleteLanguageButton: UIBarButtonItem!
            
    @IBOutlet weak private var searchBar: UISearchBar!
    @IBOutlet weak private var languagesTableView: UITableView!
    
    required init(viewModel: ChooseLanguageViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: "ChooseLanguageView", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    override func viewDidLoad() {
        print("view didload: \(type(of: self))")
        super.viewDidLoad()
        
        deleteLanguageButton = addBarButtonItem(
            to: .right,
            title: viewModel.deleteLanguageButtonTitle,
            color: .white,
            target: self, action: #selector(handleDeleteLanguage(barButtonItem:))
        )
        
        setupLayout()
        setupBinding()
                
        addDefaultNavBackItem()
        
        searchBar.delegate = self
        languagesTableView.delegate = self
        languagesTableView.dataSource = self
    }
    
    private func setupLayout() {
        
        // searchBar
        searchBar.barTintColor = .gtGreyLight
        searchBar.searchTextField.backgroundColor = .white
        searchBar.isTranslucent = true
        searchBar.returnKeyType = .done
        searchBar.inputAccessoryView = toolBarViewForKeyboard()
        
        // languagesTableView
        languagesTableView.register(
            UINib(nibName: ChooseLanguageCell.nibName, bundle: nil),
            forCellReuseIdentifier: ChooseLanguageCell.reuseIdentifier
        )
    }
    
    private func setupBinding() {
        
        viewModel.navTitle.addObserver(self) { [weak self] (navTitle: String) in
            self?.title = navTitle
        }
        
        viewModel.hidesDeleteLanguageButton.addObserver(self) { [weak self] (hidden: Bool) in
            if let deleteLanguageButton = self?.deleteLanguageButton {
                let barPosition: ButtonItemPosition = .right
                if hidden {
                    self?.removeBarButtonItem(item: deleteLanguageButton, barPosition: barPosition)
                }
                else {
                    self?.addBarButtonItem(item: deleteLanguageButton, barPosition: barPosition)
                }
            }
        }
        
        viewModel.languages.addObserver(self) { [weak self] (languages: [Language]) in
            self?.languagesTableView.reloadData()
        }
        
        viewModel.selectedLanguage.addObserver(self) { [weak self] (selectedLanguage: Language?) in
            self?.languagesTableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.pageViewed()
    }
    
    @objc func handleDeleteLanguage(barButtonItem: UIBarButtonItem) {
        viewModel.deleteLanguageTapped()
    }
}

// MARK: - UISearchBarDelegate

extension ChooseLanguageView: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.becomeFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchLanguageTextInputChanged(text: searchText)
    }
    
    fileprivate func toolBarViewForKeyboard() -> UIToolbar {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 30))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let dismissButton = UIBarButtonItem(title: "dismiss".localized, style: .plain, target: self, action: #selector(hideKeyboard))
        toolbar.setItems([flexSpace, dismissButton], animated: false)
        toolbar.sizeToFit()
        return toolbar
    }
    
    @objc func hideKeyboard() {
        searchBar.resignFirstResponder()
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension ChooseLanguageView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.languages.value.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let language: Language = viewModel.languages.value[indexPath.row]
        
        viewModel.languageTapped(language: language)
        
        searchBar.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: ChooseLanguageCell = languagesTableView.dequeueReusableCell(
        withIdentifier: ChooseLanguageCell.reuseIdentifier,
        for: indexPath) as! ChooseLanguageCell
        
        let language: Language = viewModel.languages.value[indexPath.row]
               
        let cellViewModel = ChooseLanguageCellViewModel(
            language: language,
            selectedLanguage: viewModel.selectedLanguage.value
        )
        
        cell.configure(viewModel: cellViewModel)
                
        cell.selectionStyle = .none
        
        return cell
    }
}

extension ChooseLanguageView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == languagesTableView {
            searchBar.resignFirstResponder()
        }
    }
}
