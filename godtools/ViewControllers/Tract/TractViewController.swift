//
//  TractViewController.swift
//  godtools
//
//  Created by Ryan Carlson on 4/24/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit
import SWXMLHash
import MessageUI
import PromiseKit

class TractViewController: BaseViewController {
    
//    let languagesManager = LanguagesManager()
    
    var primaryLanguage: Language?
    var parallelLanguage: Language?
    var selectedLanguage: Language?
    
    let tractsManager: TractManager = TractManager()
    var resource: DownloadedResource?
    var viewsWereGenerated = false
    var xmlPages = [XMLPage]()
    var xmlPagesForPrimaryLang = [XMLPage]()
    var xmlPagesForParallelLang = [XMLPage]()
    var manifestProperties = ManifestProperties()
    var primaryTextColor: UIColor?
    var textColor: UIColor?
    var currentPage = 0
    var currentMovement: CGFloat {
        return CGFloat(currentPage) *  -self.view.frame.width
    }
    var containerView = UIView()
    var pagesViews = [TractView?]()
    var progressView = UIView()
    var progressViewHelper = UIView()
    var currentProgressView = UIView()
    var languageSegmentedControl: UISegmentedControl?
    
    let viewTagOrigin = 100
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TractBindings.setupBindings()
        loadLanguages()
        getResourceData()
        setupSwipeGestures()
        defineObservers()
    }
    
    deinit {
        #if DEBUG
            print("deinit for TractViewController")
        #endif
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if self.viewsWereGenerated {
            return
        }
        
        setupContainerView()
        loadPagesViews()
        self.viewsWereGenerated = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupStyle()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.progressViewHelper.removeFromSuperview()
        self.progressView.removeFromSuperview()
        TractBindings.clearAllBindings()
    }
    
    // MARK: - UI setup
    
    override func configureNavigationButtons() {
        self.addHomeButton()
        
        if self.resource?.code == nil || GTSettings.ignoredTools.contains(self.resource!.code) {
            return
        }
        
        self.addShareButton()
    }

    override func displayScreenTitle() {
        if parallelLanguageIsAvailable() && determinePrimaryLabel() != determineParallelLabel() {
            configureLanguageSegmentedControl()
            self.navigationItem.titleView = languageSegmentedControl
        }
    }
    
    fileprivate func setupContainerView() {
        let navigationBarFrame = navigationController!.navigationBar.frame
        let startingYPos = navigationBarFrame.origin.y
        
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height - startingYPos
        self.containerView.frame = CGRect(x: 0.0, y: startingYPos, width: width, height: height)
        self.view.addSubview(self.containerView)
    }
        
    fileprivate func loadPagesViews() {
        let size = self.containerView.frame.size
        buildPages(width: size.width, height: size.height)
    }
    
    fileprivate func currentTractTitle() -> String {
        return resource!.localizedName(language: primaryLanguage)
    }
    
    fileprivate func setupStyle() {
        setupNavigationBarStyles()
    }
    
    fileprivate func setupNavigationBarStyles() {
        self.baseDelegate?.changeNavigationColors(backgroundColor: self.manifestProperties.navbarColor, controlColor: self.manifestProperties.navbarControlColor)
        
        let navigationBar = navigationController!.navigationBar
        
        let width = navigationBar.frame.size.width
        let height: CGFloat = 4.0
        let xOrigin: CGFloat = 0.0
        let yOrigin: CGFloat = 0.0
        let progressViewFrame = CGRect(x: xOrigin, y: yOrigin, width: width, height: height)
        
        self.currentProgressView = UIView()
        self.currentProgressView.frame = CGRect(x: 0.0, y: 0.0, width: currentProgressWidth(), height: height)
        self.currentProgressView.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        
        self.progressViewHelper = UIView()
        self.progressViewHelper.frame = progressViewFrame
        self.progressViewHelper.backgroundColor = .white
        
        self.progressView = UIView()
        self.progressView.frame = progressViewFrame
        self.progressView.backgroundColor = self.manifestProperties.primaryColor.withAlphaComponent(0.65)
        self.progressView.addSubview(self.currentProgressView)
        
        navigationBar.addSubview(self.progressViewHelper)
        navigationBar.addSubview(self.progressView)
        
        setupNavigationBarFrame()
        
        TractPage.navbarHeight = navigationBar.frame.size.height
    }
    
    @objc fileprivate func setupNavigationBarFrame() {
        guard let navController = navigationController else {
            return
        }
        
        let navigationBar = navController.navigationBar
        
        let xOrigin: CGFloat = 0.0
        let yOrigin: CGFloat = 0.0
        let width = navigationBar.frame.size.width
        let navigationBarHeight: CGFloat = 64.0
        
        navigationBar.frame = CGRect(x: xOrigin, y: yOrigin, width: width, height: navigationBarHeight)
    }
    
    // MARK: - Segmented Control
    
    fileprivate func configureLanguageSegmentedControl() {
        let primaryLabel = self.determinePrimaryLabel()
        let parallelLabel = self.determineParallelLabel()
        
        languageSegmentedControl = UISegmentedControl(items: [primaryLabel, parallelLabel])
        languageSegmentedControl!.selectedSegmentIndex = 0
        languageSegmentedControl!.addTarget(self, action: #selector(didSelectLanguage), for: .valueChanged)
    }
    
    @objc fileprivate func didSelectLanguage(segmentedControl: UISegmentedControl) {
        if segmentedControl.selectedSegmentIndex == 0 {
            usePrimaryLanguageResources()
        } else {
            useParallelLanguageResources()
        }
        
        loadPagesViews()
    }
    
    // MARK: - Navigation buttons actions
    
    override func homeButtonAction() {
        removeViewsBeforeCurrentView()
        super.homeButtonAction()
    }
    
    override func shareButtonAction() {
        let languageCode = self.selectedLanguage?.code ?? "en"
        guard let resourceCode = self.resource?.code else {
            return
        }
        
        let shareURLString = buildShareURLString(resourceCode, languageCode)
        
        let activityController = UIActivityViewController(activityItems: [String.localizedStringWithFormat("tract_share_message".localized, shareURLString)], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
    
    private func buildShareURLString(_ resourceCode: String, _ languageCode: String) -> String {
        var shareURLString: String
        
        if resourceCode == "kgp-us" {
            shareURLString = "https://www.knowgod.com/\(languageCode)/kgp"
        } else {
            shareURLString = "https://www.knowgod.com/\(languageCode)/\(resourceCode)"
            
            if currentPage > 0 {
                shareURLString = shareURLString.appending("/").appending("\(currentPage)")
            }
        }
        
        shareURLString = shareURLString.appending(" ")
        
        return shareURLString
    }
    
    // Notifications
    
    func defineObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(setupNavigationBarFrame),
                                               name: NSNotification.Name.UIApplicationDidBecomeActive,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(moveToPage),
                                               name: NSNotification.Name.moveToPageNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(moveToNextPage),
                                               name: NSNotification.Name.moveToNextPageNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sendEmail),
                                               name: NSNotification.Name.sendEmailFromTractForm,
                                               object: nil)
    }
    
    // MARK: - Helpers
    
    func currentProgressWidth() -> CGFloat {
        let parentWidth = self.navigationController!.navigationBar.frame.size.width
        let numPages = totalPages()
        
        if numPages == 1 {
            return parentWidth
        }
        
        return CGFloat(self.currentPage) * parentWidth / CGFloat(numPages - 1)
    }
    
    override func screenName() -> String {
        guard let resource = self.resource else {
            return super.screenName()
        }
        return "\(resource.code)-\(self.currentPage)"
    }
    
    private func loadLanguages() {
        let languagesManager = LanguagesManager()
        
        primaryLanguage = languagesManager.loadPrimaryLanguageFromDisk()
        
        if resource!.getTranslationForLanguage(primaryLanguage!) == nil {
            primaryLanguage = languagesManager.loadFromDisk(code: "en")
        }
        
        parallelLanguage = languagesManager.loadParallelLanguageFromDisk()
    }
}

extension TractViewController: BaseTractElementDelegate {
    func showAlert(_ alert: UIAlertController) {
        present(alert, animated: true, completion: nil)
    }
    
    func displayedLanguage() -> Language {
        return selectedLanguage!
    }
}
