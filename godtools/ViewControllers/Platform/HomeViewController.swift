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
    mutating func moveToToolDetail(resource: DownloadedResource)
    mutating func moveToTract(resource: DownloadedResource)
    mutating func moveToArticle(resource: DownloadedResource)
}

protocol FindToolsDelegate: class {
    func goToFindTools()
}

class HomeViewController: BaseViewController {
    
    var delegate: HomeViewControllerDelegate?
    weak var findDelegate: FindToolsDelegate?
    
    let toolsManager = ToolsManager.shared
    var refreshControl = UIRefreshControl()
    var loginBannerView: UIView?
   
    
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
        
        // MARK - Product owner has requested to not display this quite yet.
        
//        if loginBannerShouldDisplay() {
//            self.displayLoginBanner()
//        }
        
        toolsManager.delegate = self
        reloadView()
        tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
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
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadView),
                                               name: .loginBannerDismissedNotification,
                                               object: nil)
    }
    
    @objc private func reloadView() {
        toolsManager.loadResourceList()
        
        emptyStateView.isHidden = toolsManager.hasResources()
        normalStateView.isHidden = !toolsManager.hasResources()

        tableView.reloadData()
        
        // MARK - Product owner has requested to not display this quite yet.
        
        //updateHeaderView()
    }
    
    @objc private func loadLatestResources() {
        _ = LanguagesManager().loadFromRemote().then { (languages) -> Promise<Void> in
            return DownloadedResourceManager().loadFromRemote()
                .then { (resources) -> Promise<Void> in
                    TranslationZipImporter().catchupMissedDownloads()
                    return .value(())
            }
            }.ensure {
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
    
    @IBAction func pressFindToolsButton(_ sender: Any) {
        findDelegate?.goToFindTools()
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
        self.tableView.contentInset = UIEdgeInsets(top: 64.0, left: 0.0, bottom: 0.0, right: 0.0)
        
        // MARK - Product owner has requested to not display this quite yet.
        
       // loginBannerView = createLoginBannerView()
    }
    
    fileprivate func displayOnboarding() {
        let onboardingViewController = OnboardingViewController(nibName: String(describing:OnboardingViewController.self), bundle: nil)
        onboardingViewController.modalPresentationStyle = .overCurrentContext
        self.present(onboardingViewController, animated: true, completion: nil)
        
        UserDefaults.standard.set(true, forKey: GTConstants.kOnboardingScreensShownKey)
    }

    private func onboardingShouldDisplay() -> Bool {
        return false
        // temp removed by request
//        let hasAlreadyShown = UserDefaults.standard.bool(forKey: GTConstants.kOnboardingScreensShownKey)
//        return !hasAlreadyShown
    }
    
    private func loginBannerShouldDisplay() -> Bool {
        var shouldDisplayBanner = false
        
        // MARK - These are the current conditions that have to be met to display the login banner.
        let hasTappedFindTools = UserDefaults.standard.bool(forKey: GTConstants.kHasTappedFindTools)
        let hasAlreadyAccessedATract = UserDefaults.standard.bool(forKey: GTConstants.kAlreadyAccessTract)
        let bannerHasDiplayedOnce = UserDefaults.standard.bool(forKey: GTConstants.kHasDiplayedBannerOnce)
        let bannerHasBeenDismissed = UserDefaults.standard.bool(forKey: GTConstants.kBannerHasBeenDismissed)
        let languageIsEnglish = (Locale.current.languageCode == "en")
        
        if hasTappedFindTools && hasAlreadyAccessedATract && !bannerHasDiplayedOnce && !bannerHasBeenDismissed && languageIsEnglish {
            shouldDisplayBanner = true
            UserDefaults.standard.set(true, forKey: GTConstants.kHasDiplayedBannerOnce)
        }

        return shouldDisplayBanner
    }
    
    private func updateHeaderView() {
        DispatchQueue.main.async {
            let bannerHasDiplayedOnce = UserDefaults.standard.bool(forKey: GTConstants.kHasDiplayedBannerOnce)
            let bannerHasBeenDismissed = UserDefaults.standard.bool(forKey: GTConstants.kBannerHasBeenDismissed)
            if bannerHasDiplayedOnce && !bannerHasBeenDismissed  {
                self.tableView.tableHeaderView = self.loginBannerView
            } else {
                self.tableView.tableHeaderView = UIView()
            }
        }
    }
    
    private func createLoginBannerView() -> UIView {
        let loginBanner = LoginBannerView()
        loginBanner.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 75)
        return loginBanner
    }
    
    private func displayLoginBanner() {
        DispatchQueue.main.async {
            self.tableView.tableHeaderView = self.loginBannerView
        }
    }
    
    // MARK: - Analytics
    
    override func screenName() -> String {
        return "Home"
    }
    
    // MARK: - Accessiblity
    
    override func addAccessibilityIdentifiers() {
        self.view.accessibilityIdentifier = GTAccessibilityConstants.Home.homeMyToolsView
        self.tableView.accessibilityIdentifier = GTAccessibilityConstants.Home.homeTableView
    }
}

extension HomeViewController: ToolsManagerDelegate {
    func didSelectTableViewRow(cell: HomeToolTableViewCell) {
        
        // prevent opening tool before download is complete
        guard let resource = cell.resource, resource.isReady() else {
            showDownloadInProgressAlert()
            return
        }

        switch cell.resource!.toolType {
        case "tract":
            self.delegate?.moveToTract(resource: cell.resource!)
        case "article":
            self.delegate?.moveToArticle(resource: cell.resource!)
        default:
            // TODO: should not crash if unrecognized tool type; for now - ignore (maybe a friendly alert message through another delegate function?)
            debugPrint("Unrecognized tool type \(cell.resource!.toolType)")
        }
    }
    
    func infoButtonWasPressed(resource: DownloadedResource) {
        self.delegate?.moveToToolDetail(resource: resource)
    }
    
    func showDownloadInProgressAlert() {
        let alert = UIAlertController(title: "",
                                      message: "Download in progress".localized,
                                      preferredStyle: .alert)
        
        
        let okAction = UIAlertAction(title: "OK".localized, style: .cancel)
        
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}
