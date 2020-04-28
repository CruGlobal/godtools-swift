//
//  HomeViewController.swift
//  godtools
//
//  Created by Devserker on 4/20/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit
import PromiseKit

protocol FindToolsDelegate: class {
    func goToFindTools()
}

class HomeViewController: UIViewController {
    
    private let viewModel: MyToolsViewModelType
    
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
    
    required init(viewModel: MyToolsViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: HomeViewController.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.displayWorkingView()
        self.registerCells()
        self.setupStyle()
        self.defineObservers()
        addRefreshControl()
        
        addAccessibilityIdentifiers()

        let pressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureReconizer:)))
        pressGesture.minimumPressDuration = 0.75
        tableView.addGestureRecognizer(pressGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.pageViewed()
        
        // MARK - Product owner has requested to not display this quite yet.
        
//        if loginBannerShouldDisplay() {
//            self.displayLoginBanner()
//        }
        
        toolsManager.delegate = self
        reloadView()
        tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tableView.isEditing = false
        super.viewWillDisappear(animated)
    }
    
    @objc func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        
        guard gestureReconizer.state == UIGestureRecognizer.State.began else { return }

        tableView.isEditing = !tableView.isEditing
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
    
    func addAccessibilityIdentifiers() {
        view.accessibilityIdentifier = GTAccessibilityConstants.Home.homeMyToolsView
        tableView.accessibilityIdentifier = GTAccessibilityConstants.Home.homeTableView
    }
}

extension HomeViewController: ToolsManagerDelegate {
    
    func didSelectTableViewRow(cell: HomeToolTableViewCell) {
        
        // prevent opening tool before download is complete
        guard let resource = cell.resource, resource.isReady() else {
            showDownloadInProgressAlert()
            return
        }
        
        viewModel.toolTapped(resource: resource)
    }
    
    func infoButtonWasPressed(resource: DownloadedResource) {
        
        viewModel.toolInfoTapped(resource: resource)        
    }
    
    func showDownloadInProgressAlert() {
        let alert = UIAlertController(title: "",
                                      message: "Download in progress".localized,
                                      preferredStyle: .alert)
        
        alert.accessibilityLabel = "download_in_progress"

        let okAction = UIAlertAction(title: "OK".localized, style: .cancel)
        okAction.accessibilityLabel = "download_in_progress_ok"
        
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}
