//
//  HomeViewController.swift
//  godtools
//
//  Created by Devserker on 4/20/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit
import PromiseKit

protocol HomeViewControllerDelegate {
    mutating func moveToUpdateLanguageSettings()
    mutating func moveToAddNewTool()
    mutating func moveToToolDetail(resource: DownloadedResource)
    mutating func moveToTract(resource: DownloadedResource)
}

class HomeViewController: BaseViewController {
    
    var delegate: HomeViewControllerDelegate?
    
    let toolsManager = ToolsManager.shared
    var refreshControl = UIRefreshControl()
    
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
        addRefreshControl()
        
        if onboardingShouldDisplay() {
            self.displayOnboarding()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        toolsManager.delegate = self
        reloadView()
        tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
    }
    
    // Notifications
    
    func defineObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadView),
                                               name: .downloadPrimaryTranslationCompleteNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadView),
                                               name: .reloadHomeListNotification,
                                               object: nil)
    }
    
    @objc private func reloadView() {
        toolsManager.loadResourceList()
        
        emptyStateView.isHidden = toolsManager.hasResources()
        normalStateView.isHidden = !toolsManager.hasResources()

        tableView.reloadData()
    }
    
    @objc private func loadLatestResources() {
        _ = LanguagesManager().loadFromRemote().then { (languages) -> Promise<Void> in
            return DownloadedResourceManager().loadFromRemote()
                .then { (resources) -> Promise<Void> in
                    TranslationZipImporter().catchupMissedDownloads()
                    return Promise(value: ())
            }
            }.always {
                self.refreshControl.endRefreshing()
                self.reloadView()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    private func addRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(loadLatestResources), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    // MARK: - Actions
    
    @IBAction func pressAddNewToolsButton(_ sender: Any) {
     //   self.delegate?.moveToAddNewTool()
    }
    
    // MARK: - Navigation Buttons
    
    override func configureNavigationButtons() {
        //self.addNavigationBurgerButton()
       // self.addNavigationPlusButton()
       // self.addNavigationLanguageButton()
    }
    
    override func navigationPlusButtonAction() {
     //   self.delegate?.moveToAddNewTool()
    }
    
//    override func navigationLanguageButtonAction() {
//        self.delegate?.moveToUpdateLanguageSettings()
//    }
    
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
        UserDefaults.standard.set(true, forKey: GTConstants.kOnboardingScreensShownKey)
    }

    private func onboardingShouldDisplay() -> Bool {
        let hasAlreadyShown = UserDefaults.standard.bool(forKey: GTConstants.kOnboardingScreensShownKey)
        
        return !hasAlreadyShown
    }
    
    // MARK: - Analytics
    
    override func screenName() -> String {
        return "Home"
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
