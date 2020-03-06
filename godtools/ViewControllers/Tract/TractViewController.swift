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
    
    private let viewModel: TractViewModelType
    
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
    var isRightToLeft: Bool {
        return primaryLanguage?.isRightToLeft() ?? false
    }
    var currentMovement: CGFloat {
        let multiplier: CGFloat = isRightToLeft ? -1 : 1
        return CGFloat(currentPage) * -self.view.frame.width * multiplier
    }
    var containerView = UIView()
    var pagesViews = [TractView?]()
    private var languageSegmentedControl: UISegmentedControl?
    
    var arrivedByUniversalLink = false
    var universalLinkLanguage: Language?
    
    let viewTagOrigin = 100
    
    static let iPhoneXStatusBarHeight: CGFloat = 44.0
    static let iPhoneXMarginBottomToSafeArea: CGFloat = 44.0
    static let navigationBarHeight: CGFloat = 44.0
    static let standardStatusBarInitialYPosition: CGFloat = 0.0
    
    override var prefersStatusBarHidden: Bool {
        return !UIDevice.current.iPhoneWithNotch()
    }
    
    required init(viewModel: TractViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: "TractViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        viewModel.viewLoaded()
        
        TractBindings.setupBindings()
        loadLanguages()
        getResourceData()
        setupSwipeGestures()
        defineObservers()
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if self.viewsWereGenerated {
            return
        }
        
        setupContainerView()
        setupNavigationBarFrame()
        loadPagesViews()
        self.viewsWereGenerated = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBarStyles()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        TractBindings.clearAllBindings()
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    // MARK: - UI setup
    
    override func configureNavigationButtons() {
        self.addHomeButton()
        
        if self.resource?.code == nil || GTSettings.ignoredTools.contains(self.resource!.code) {
            return
        }
        
        self.addShareButton()
    }
    
    fileprivate func setupContainerView() {
        let startingYPos: CGFloat = 0.0
        
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
        guard let resource = resource else { return "" }
        let primaryLanguage = resolvePrimaryLanguage()
        return resource.localizedName(language: primaryLanguage)
    }
    
    fileprivate func setupNavigationBarStyles() {
        
        let navBarColor: UIColor = manifestProperties.navbarColor ?? manifestProperties.primaryColor
        let navBarControlColor: UIColor = manifestProperties.navbarControlColor ?? manifestProperties.primaryTextColor
                    
        navigationController?.navigationBar.barTintColor = .clear
        navigationController?.navigationBar.setBackgroundImage(NavigationBarBackground.createFrom(navBarColor), for: .default)
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: navBarControlColor,
            NSAttributedString.Key.font: UIFont.gtSemiBold(size: 17.0)
        ]
        
        navigationController?.navigationBar.tintColor = navBarControlColor

        let primaryLabel: String = determinePrimaryLabel()
        let parallelLabel: String = determineParallelLabel()
        
        if parallelLanguageIsAvailable() && primaryLabel != parallelLabel {
            
            let shouldSelectFirstSegment: Bool = languageSegmentedControl == nil
            
            if languageSegmentedControl == nil {
                languageSegmentedControl = UISegmentedControl()
            }
            
            languageSegmentedControl?.removeAllSegments()
            languageSegmentedControl?.insertSegment(withTitle: primaryLabel, at: 0, animated: false)
            languageSegmentedControl?.insertSegment(withTitle: parallelLabel, at: 1, animated: false)
            
            if shouldSelectFirstSegment {
                languageSegmentedControl?.selectedSegmentIndex = 0
            }
            
            let font = UIFont.defaultFont(size: 14, weight: nil)
            if #available(iOS 13.0, *) {
                languageSegmentedControl?.selectedSegmentTintColor = navBarControlColor
                languageSegmentedControl?.layer.borderColor = navBarControlColor.cgColor
                languageSegmentedControl?.layer.borderWidth = 1
                languageSegmentedControl?.backgroundColor = .clear
            } else {
                // Fallback on earlier versions
            }
            
            languageSegmentedControl?.setTitleTextAttributes([.font: font, .foregroundColor: navBarControlColor], for: .normal)
            languageSegmentedControl?.setTitleTextAttributes([.font: font, .foregroundColor: navBarColor.withAlphaComponent(1)], for: .selected)
            
            languageSegmentedControl?.addTarget(self, action: #selector(didSelectLanguage), for: .valueChanged)
            
            navigationItem.titleView = languageSegmentedControl
        }
        
        guard let navigationBar = navigationController?.navigationBar else { return }
        TractPage.navbarHeight = navigationBar.frame.size.height
    }
    
    @objc fileprivate func setupNavigationBarFrame() {
        guard let navController = navigationController else {
            return
        }
        
        let navigationBar = navController.navigationBar
        let xOrigin: CGFloat = 0.0
        let yOrigin: CGFloat = UIDevice.current.iPhoneWithNotch() ? TractViewController.iPhoneXStatusBarHeight : TractViewController.standardStatusBarInitialYPosition
        let width = navigationBar.frame.size.width
        let height: CGFloat = TractViewController.navigationBarHeight
        
        navigationBar.frame = CGRect(x: xOrigin, y: yOrigin, width: width, height: height)
    }
    
    // MARK: - Segmented Control
    
    @objc fileprivate func didSelectLanguage(segmentedControl: UISegmentedControl) {
        if segmentedControl.selectedSegmentIndex == 0 {
            usePrimaryLanguageResources()
            sendLanguageToggleNotification(language: primaryLanguage)
        } else {
            useParallelLanguageResources()
            sendLanguageToggleNotification(language: parallelLanguage)
        }
        
        loadPagesViews()
        view.setNeedsLayout()
    }
    
    private func sendLanguageToggleNotification(language: Language?) {
        guard let language = language else { return }
        NotificationCenter.default.post(name: .actionTrackNotification,
                                        object: nil,
                                        userInfo: ["action": AdobeAnalyticsConstants.Values.parallelLanguageToggle,
                                                   AdobeAnalyticsConstants.Keys.parallelLanguageToggle: "",
                                                   AdobeAnalyticsConstants.Keys.contentLanguageSecondary: language.code,
                                                   AdobeAnalyticsConstants.Keys.siteSection: (resource?.code) as Any])
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
        
        let shareMessage = buildShareMessage(resourceCode, languageCode)
        
        let activityController = UIActivityViewController(activityItems: [shareMessage], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
        
        let userInfo: [String: Any] = ["action": AdobeAnalyticsConstants.Values.share,
                        AdobeAnalyticsConstants.Keys.shareAction: 1,
                        GTConstants.kAnalyticsScreenNameKey: screenName()]
        NotificationCenter.default.post(name: .actionTrackNotification,
                                        object: nil,
                                        userInfo: userInfo)
        self.sendScreenViewNotification(screenName: screenName(), siteSection: siteSection(), siteSubSection: siteSubSection())
    }
    
    private func buildShareMessage(_ resourceCode: String, _ languageCode: String) -> String {
        let shareURLString = buildShareURLString(resourceCode, languageCode)
        return String.localizedStringWithFormat("tract_share_message".localized, shareURLString)
    }
    
    private func buildShareURLString(_ resourceCode: String, _ languageCode: String) -> String {
        var shareURLString = "https://www.knowgod.com/\(languageCode)/\(resourceCode)"
        
        if currentPage > 0 {
            shareURLString = shareURLString.appending("/").appending("\(currentPage)")
        }
        
        // the space is intentional to separate any punctuation in the share message from the end of the URL
        return shareURLString.replacingOccurrences(of: " ", with: "").appending("?icid=gtshare ")
    }
    
    // Notifications
    
    func defineObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(moveToPage),
                                               name: .moveToPageNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(moveToNextPage),
                                               name: .moveToNextPageNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(moveToPreviousPage),
                                               name: .moveToPreviousPageNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sendEmail),
                                               name: .sendEmailFromTractForm,
                                               object: nil)
    }
    
    // MARK: - Helpers
    
    override func screenName() -> String {
        guard let resource = self.resource else {
            return super.screenName()
        }
        return "\(resource.code)-\(self.currentPage)"
    }
    
    override func siteSection() -> String {
        guard let resource = self.resource else {
            return super.siteSection()
        }
        return "\(resource.code)"
    }
    
    private func loadLanguages() {
        guard let resource = resource else {
            return
        }
        
        let languagesManager = LanguagesManager()
        
        primaryLanguage = languagesManager.loadPrimaryLanguageFromDisk()
        
        if resource.getTranslationForLanguage(primaryLanguage!) == nil {
            primaryLanguage = languagesManager.loadFromDisk(code: "en")
        }
        
        parallelLanguage = languagesManager.loadParallelLanguageFromDisk(arrivingFromUniversalLink: arrivedByUniversalLink)
    }
    
    func resolvePrimaryLanguage() -> Language? {        
        if arrivedByUniversalLink {
            return universalLinkLanguage
        } else {
            return primaryLanguage
        }
    }
}

extension TractViewController: BaseTractElementDelegate {
    func showAlert(_ alert: UIAlertController) {
        present(alert, animated: true, completion: nil)
    }
    
    func displayedLanguage() -> Language? {
        let languagesManager = LanguagesManager()
        
        guard let languageSegmentedControl = languageSegmentedControl else {
            return resolvePrimaryLanguage()
        }
        
        if languageSegmentedControl.selectedSegmentIndex == 0 {
            return resolvePrimaryLanguage()
        } else {
            return languagesManager.loadParallelLanguageFromDisk(arrivingFromUniversalLink: arrivedByUniversalLink)
        }
    }
}
