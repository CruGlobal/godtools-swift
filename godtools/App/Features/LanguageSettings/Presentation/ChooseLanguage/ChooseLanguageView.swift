//
//  ChooseLanguageView.swift
//  godtools
//
//  Created by Levi Eggert on 4/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ChooseLanguageView: UIViewController {
        
    private let viewModel: ChooseLanguageViewModel
            
    private var deleteLanguageButton: UIBarButtonItem!
            
    @IBOutlet weak private var searchBar: UISearchBar!
    @IBOutlet weak private var languagesTableView: UITableView!
    
    required init(viewModel: ChooseLanguageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: ChooseLanguageView.self), bundle: nil)
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
            style: .plain,
            color: .white,
            target: self, action: #selector(handleDeleteLanguage(barButtonItem:))
        )
        
        setupLayout()
        setupBinding()
                        
        searchBar.delegate = self
        languagesTableView.delegate = self
        languagesTableView.dataSource = self
    }
    
    private func setupLayout() {
        
        // searchBar
        searchBar.barTintColor = UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1.0)
        if #available(iOS 13, *) {
            searchBar.searchTextField.backgroundColor = .white
        }
        
        searchBar.isTranslucent = true
        searchBar.returnKeyType = .done
        searchBar.inputAccessoryView = toolBarViewForKeyboard()
        
        // languagesTableView
        languagesTableView.register(
            UINib(nibName: ChooseLanguageCell.nibName, bundle: nil),
            forCellReuseIdentifier: ChooseLanguageCell.reuseIdentifier
        )
        languagesTableView.rowHeight = 54
        languagesTableView.separatorStyle = .none
    }
    
    private func setupBinding() {
        
        viewModel.navTitle.addObserver(self) { [weak self] (navTitle: String) in
            self?.title = navTitle
        }
        
        viewModel.hidesDeleteLanguageButton.addObserver(self) { [weak self] (hidden: Bool) in
            if let deleteLanguageButton = self?.deleteLanguageButton {
                let barPosition: BarButtonItemBarPosition = .right
                if hidden {
                    self?.removeBarButtonItem(item: deleteLanguageButton)
                }
                else {
                    self?.addBarButtonItem(item: deleteLanguageButton, barPosition: barPosition)
                }
            }
        }
        
        viewModel.numberOfLanguages.addObserver(self) { [weak self] (numberOfLanguages: Int) in
            self?.languagesTableView.reloadData()
        }
        
        viewModel.selectedLanguageIndex.addObserver(self) { [weak self] (index: Int?) in
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
        let dismissButton = UIBarButtonItem(title: viewModel.closeKeyboardTitle, style: .plain, target: self, action: #selector(hideKeyboard))
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
        return viewModel.numberOfLanguages.value
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        viewModel.languageTapped(index: indexPath.row)
        
        searchBar.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: ChooseLanguageCell = languagesTableView.dequeueReusableCell(
        withIdentifier: ChooseLanguageCell.reuseIdentifier,
        for: indexPath) as! ChooseLanguageCell
        
        let cellViewModel: ChooseLanguageCellViewModel = viewModel.willDisplayLanguage(index: indexPath.row)
        
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
