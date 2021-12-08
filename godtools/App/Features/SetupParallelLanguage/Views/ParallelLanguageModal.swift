//
//  ParallelLanguageModal.swift
//  godtools
//
//  Created by Robert Eldredge on 12/6/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class ParallelLanguageModal: UIView, NibBased {
    
    private let viewModel: ParallelLanguageModalViewModelType
        
    @IBOutlet weak private var languagesTableView: UITableView!
    
    required init(viewModel: ParallelLanguageModalViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(frame: UIScreen.main.bounds)
        
        loadNib()
        setupLayout()
        setupBinding()
        
        languagesTableView.delegate = self
        languagesTableView.dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
        print("x deinit: \(type(of: self))")
    }
    
    private func setupLayout() {
        
        languagesTableView.register(
            UINib(nibName: ChooseLanguageCell.nibName, bundle: nil),
            forCellReuseIdentifier: ChooseLanguageCell.reuseIdentifier
        )
        languagesTableView.rowHeight = 54
        languagesTableView.separatorStyle = .none
    }
    
    private func setupBinding() {
        
        viewModel.numberOfLanguages.addObserver(self) { [weak self] (numberOfLanguages: Int) in
            self?.languagesTableView.reloadData()
        }
        
        viewModel.selectedLanguageIndex.addObserver(self) { [weak self] (index: Int?) in
            self?.languagesTableView.reloadData()
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension ParallelLanguageModal: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfLanguages.value
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        viewModel.languageTapped(index: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: ChooseLanguageCell = languagesTableView.dequeueReusableCell(
        withIdentifier: ChooseLanguageCell.reuseIdentifier,
        for: indexPath) as! ChooseLanguageCell
        
        let cellViewModel: ChooseLanguageCellViewModel = viewModel.languageWillAppear(index: indexPath.row)
        
        cell.configure(viewModel: cellViewModel)
                
        cell.selectionStyle = .none
        
        return cell
    }
}

// MARK: - TransparentModalCustomView

extension ParallelLanguageModal: TransparentModalCustomView {
    
    var view: UIView {
        return self
    }
    
    func transparentModalDidLayout() {
        
    }
}
