//
//  HomeViewController.swift
//  godtools
//
//  Created by Devserker on 4/20/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

protocol HomeViewControllerDelegate {
    mutating func moveToUpdateLanguageSettings()
    mutating func moveToAddNewTool()
    mutating func moveToToolDetail(resource: DownloadedResource)
    mutating func moveToTract(resource: DownloadedResource)
}

class HomeViewController: BaseViewController {
    
    var delegate: HomeViewControllerDelegate?
    
    let toolsManager = ToolsManager.shared
    
    @IBOutlet weak var emptyStateView: UIView!
    @IBOutlet weak var normalStateView: UIView!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = toolsManager
            tableView.dataSource = toolsManager
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.displayWorkingView()
        self.registerCells()
        self.setupStyle()
        self.defineObservers()
        
        if LanguagesManager.shared.loadPrimaryLanguageFromDisk() == nil {
            self.displayOnboarding()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        toolsManager.delegate = self
        
        reloadView()
    }
    
    // Notifications
    
    func defineObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(presentLanguageSettings),
                                               name: .presentLanguageSettingsNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadView),
                                               name: .initialAppStateCleanupCompleted,
                                               object: nil)
    }
    
    @objc private func presentLanguageSettings() {
        self.delegate?.moveToUpdateLanguageSettings()
    }
    
    @objc private func reloadView() {
        toolsManager.loadResourceList()
        
        emptyStateView.isHidden = toolsManager.hasResources()
        normalStateView.isHidden = !toolsManager.hasResources()

        tableView.reloadData()
    }
    
    // MARK: - Actions
    
    @IBAction func pressAddNewToolsButton(_ sender: Any) {
        self.delegate?.moveToAddNewTool()
    }
    
    // MARK: - Navigation Buttons
    
    override func configureNavigationButtons() {
        self.addNavigationBurgerButton()
        self.addNavigationPlusButton()
        self.addNavigationLanguageButton()
    }
    
    override func navigationPlusButtonAction() {
        self.delegate?.moveToAddNewTool()
    }
    
    override func navigationLanguageButtonAction() {
        self.delegate?.moveToUpdateLanguageSettings()
    }
    
    // MARK: - Helpers
    
    fileprivate func displayWorkingView() {
        self.emptyStateView.isHidden = true
    }
    
    fileprivate func registerCells() {
        self.tableView.register(UINib(nibName: String(describing: HomeToolTableViewCell.self), bundle: nil), forCellReuseIdentifier: ToolsManager.toolCellIdentifier)
    }
    
    fileprivate func setupStyle() {
        self.tableView.backgroundColor = .gtWhite
        self.tableView.separatorStyle = .none
        self.tableView.contentInset = UIEdgeInsetsMake(64.0, 0.0, 0.0, 0.0)
    }
    
    fileprivate func displayOnboarding() {
        let onboardingViewController = OnboardingViewController(nibName: String(describing:OnboardingViewController.self), bundle: nil)
        onboardingViewController.modalPresentationStyle = .overCurrentContext
        self.present(onboardingViewController, animated: true, completion: nil)
    }
}

extension HomeViewController: ToolsManagerDelegate {
    func didSelectTableViewRow(cell: HomeToolTableViewCell) {
        self.delegate?.moveToTract(resource: cell.resource!)
    }
    
    func infoButtonWasPressed(resource: DownloadedResource) {
        self.delegate?.moveToToolDetail(resource: resource)
    }
}
