//
//  ParallelLanguageListView.swift
//  godtools
//
//  Created by Robert Eldredge on 12/10/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class ParallelLanguageListView: UIViewController {
    
    private let viewModel: ParallelLanguageListViewModelType
    
    @IBOutlet weak private var languagesTableView: UITableView!
    
    required init(viewModel: ParallelLanguageListViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(nibName: String(describing: ParallelLanguageListView.self), bundle: nil)
        
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
        
        view.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        view.layer.shadowOffset = CGSize(width: 2, height: 2)
        view.layer.shadowOpacity =  0.25
        view.layer.shadowRadius = 4
        view.layer.masksToBounds = false
    }
    
    private func setupBinding() {
        
        viewModel.numberOfLanguages.addObserver(self) { [weak self] (numberOfLanguages: Int) in
            self?.languagesTableView.reloadData()
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension ParallelLanguageListView: UITableViewDelegate, UITableViewDataSource {
    
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

extension ParallelLanguageListView: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return FadeAnimationTransition(fade: .fadeIn)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return FadeAnimationTransition(fade: .fadeOut)
    }
}

// MARK: - TransparentModalCustomView

extension ParallelLanguageListView: TransparentModalCustomView {
    
    var modal: UIView {
        
        return self.view
    }
    
    var modalInsets: UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func transparentModalDidLayout() {
        
    }
}

