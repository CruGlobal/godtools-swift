//
//  ParallelLanguageModal.swift
//  godtools
//
//  Created by Robert Eldredge on 12/10/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class ParallelLanguageModal: UIViewController {
    
    private let viewModel: ParallelLanguageModalViewModelType
    
    @IBOutlet weak private var languagesTableView: UITableView!
    
    required init(viewModel: ParallelLanguageModalViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(nibName: String(describing: ParallelLanguageModal.self), bundle: nil)
        
        modalPresentationStyle = .overCurrentContext
        transitioningDelegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        languagesTableView.delegate = self
        languagesTableView.dataSource = self
        
        setupLayout()
        setupBinding()
    }
    
    private func setupLayout() {
        
        view.backgroundColor = .clear
        
        languagesTableView.register(
            UINib(nibName: ChooseLanguageCell.nibName, bundle: nil),
            forCellReuseIdentifier: ChooseLanguageCell.reuseIdentifier
        )
        languagesTableView.rowHeight = 54
        languagesTableView.separatorStyle = .none
        languagesTableView.layer.cornerRadius = 6
    }
    
    private func setupBinding() {
        
        viewModel.numberOfLanguages.addObserver(self) { [weak self] (numberOfLanguages: Int) in
            self?.languagesTableView.reloadData()
        }
        
        viewModel.selectedLanguageIndex.addObserver(self) { [weak self] (index: Int?) in
            self?.languagesTableView.reloadData()
        }
    }
    
    @objc private func handleBackgroundTapped() {
        
        viewModel.backgroundTapped()
    }
    
    @objc private func handleSelectTapped() {
        
        viewModel.selectTapped()
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

// MARK: - UIViewControllerTransitioningDelegate

extension ParallelLanguageModal: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return FadeAnimationTransition(fade: .fadeIn)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return FadeAnimationTransition(fade: .fadeOut)
    }
}

// MARK: - TransparentModalCustomView

extension ParallelLanguageModal: TransparentModalCustomView {
    
    var modal: UIView {
        
        return self.view
    }
    
    func transparentModalDidLayout() {
        
    }
}

