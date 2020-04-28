//
//  TractViewController.swift
//  godtools
//
//  Created by Ryan Carlson on 4/24/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit
import SWXMLHash
import MessageUI
import PromiseKit

class TractViewController: UIViewController {
    
    private let viewModel: TractViewModelType
    
    var primaryLanguage: Language?
    var parallelLanguage: Language?
    var selectedLanguage: Language?
    
    let tractsManager: TractManager = TractManager()
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
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view didload: \(type(of: self))")
        
        setupLayout()
        setupBinding()
        
        viewModel.viewLoaded()
        
        TractBindings.setupBindings()
        loadLanguages()
        getResourceData()
        setupSwipeGestures()
        defineObservers()
        UIApplication.shared.isIdleTimerDisabled = true
        
        _ = addBarButtonItem(
            to: .left,
            image: ImageCatalog.navHome.image,
            color: .white,
            target: self,
            action: #selector(handleHome(barButtonItem:))
        )
        
        _ = addBarButtonItem(
            to: .right,
            image: ImageCatalog.navShare.image,
            color: .white,
            target: self,
            action: #selector(handleShare(barButtonItem:))
        )
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
        sendScreenViewNotification(screenName: screenName(), siteSection: siteSection(), siteSubSection: "")
        setupNavigationBarStyles()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        TractBindings.clearAllBindings()
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    private func setupLayout() {
        
    }
    
    private func setupBinding() {
        
        viewModel.navTitle.addObserver(self) { [weak self] (title: String) in
            self?.title = title
        }
    }
    
    @objc func handleHome(barButtonItem: UIBarButtonItem) {
        removeViewsBeforeCurrentView()
        viewModel.navHomeTapped()
    }
    
    @objc func handleShare(barButtonItem: UIBarButtonItem) {
        
        // TODO: Would like to handle this through viewmodel. ~Levi
        let languageCode = self.selectedLanguage?.code ?? "en"

        let shareMessage = buildShareMessage(viewModel.resource.code, languageCode)
        
        let activityController = UIActivityViewController(activityItems: [shareMessage], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
        
        let userInfo: [String: Any] = ["action": AdobeAnalyticsConstants.Values.share,
                        AdobeAnalyticsConstants.Keys.shareAction: 1,
                        GTConstants.kAnalyticsScreenNameKey: screenName()]
        NotificationCenter.default.post(name: .actionTrackNotification,
                                        object: nil,
                                        userInfo: userInfo)
        sendScreenViewNotification(screenName: screenName(), siteSection: siteSection(), siteSubSection: "")
    }
    
    func sendScreenViewNotification(screenName: String, siteSection: String, siteSubSection: String) {
        let relay = AnalyticsRelay.shared
        relay.screenName = screenName
        
        let userInfo = [GTConstants.kAnalyticsScreenNameKey: screenName, AdobeAnalyticsProperties.CodingKeys.siteSection.rawValue: siteSection, AdobeAnalyticsProperties.CodingKeys.siteSubSection.rawValue: siteSubSection]
        NotificationCenter.default.post(name: .screenViewNotification,
                                        object: nil,
                                        userInfo: userInfo)
    }
    
    // MARK: - UI setup
    
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
        let primaryLanguage = resolvePrimaryLanguage()
        return viewModel.resource.localizedName(language: primaryLanguage)
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
                                                   AdobeAnalyticsProperties.CodingKeys.contentLanguageSecondary.rawValue: language.code,
                                                   AdobeAnalyticsProperties.CodingKeys.siteSection.rawValue: (viewModel.resource.code) as Any])
    }
    
    // MARK: - Navigation buttons actions
    
    
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
    
    func screenName() -> String {
        return "\(viewModel.resource.code)-\(self.currentPage)"
    }
    
    func siteSection() -> String {

        return "\(viewModel.resource.code)"
    }
    
    private func loadLanguages() {

        let languagesManager = LanguagesManager()
        
        primaryLanguage = languagesManager.loadPrimaryLanguageFromDisk()
        
        if viewModel.resource.getTranslationForLanguage(primaryLanguage!) == nil {
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

// MARK: - Content

extension TractViewController {
    
    static let snapshotViewTag = 3210123
    static let distanceToCurrentView = 1
    
    func buildPages(width: CGFloat, height: CGFloat) {
        let range = getRangeOfViews()
        if range.end < range.start {
            viewModel.navHomeTapped()
            showErrorMessage()
            return
        }
        
        var currentElement: BaseTractElement?
        if self.pagesViews.count > self.currentPage {
            currentElement = self.pagesViews[self.currentPage]?.contentView
        }
        cleanContainerView()
    
        for pageNumber in range.start...range.end {
            var parallelElement: BaseTractElement?
            if pageNumber == self.currentPage {
                parallelElement = currentElement
            }
            
            let view = buildPage(pageNumber, width: width, height: height, parallelElement: parallelElement)
            self.pagesViews[pageNumber] = view
            self.containerView.addSubview(view)
        }
        
        removeSnapshotView()
    }
    
    func buildPage(_ pageNumber: Int, width: CGFloat, height: CGFloat, parallelElement: BaseTractElement?) -> TractView {
        let multiplier: CGFloat = isRightToLeft ? -1 : 1
        let xPosition = (width * CGFloat(pageNumber)) * multiplier
        let frame = CGRect(x: xPosition,
                           y: 0.0,
                           width: width,
                           height: height)
        
        let page = getPage(pageNumber)
        let configurations = TractConfigurations()
        configurations.defaultTextAlignment = getLanguageTextAlignment()
        configurations.pagination = page.pagination
        configurations.language = self.selectedLanguage
        configurations.resource = viewModel.resource
        let view = TractView(frame: frame,
                             data: page.pageContent(),
                             manifestProperties: self.manifestProperties,
                             configurations: configurations,
                             parallelElement: parallelElement,
                             delegate: self)
        
        view.transform = CGAffineTransform(translationX: self.currentMovement, y: 0.0)
        view.tag = self.viewTagOrigin + pageNumber
        
        return view
    }
    
    func reloadPagesViews() -> Promise<Bool> {
        return Promise<Bool> { seal in
            let range = getRangeOfViews()
            let lastPosition = self.totalPages() - 1
            let width = self.containerView.frame.size.width
            let height = self.containerView.frame.size.height
            
            for position in range.start...range.end {
                _ = addPageViewAtPosition(position: position, width: width, height: height)
            }
            
            if range.start > 0 {
                for position in 0...(range.start - 1) {
                    _ = removePageViewAtPosition(position: position)
                }
            }
            
            if range.end < lastPosition {
                for position in (range.end + 1)...lastPosition {
                    _ = removePageViewAtPosition(position: position)
                }
            }
            
            seal.fulfill(true)
        }
    }
    
    func addPageViewAtPosition(position: Int, width: CGFloat, height: CGFloat) -> Promise<Bool> {
        return Promise<Bool> { seal in
            
            if self.pagesViews[position] == nil {
                guard let firstView = self.containerView.subviews.first else {
                    seal.fulfill(false)
                    return
                }
                
                let view = buildPage(position, width: width, height: height, parallelElement: nil)
                self.pagesViews[position] = view
                if firstView.tag > view.tag {
                    self.containerView.insertSubview(view, at: 0)
                } else {
                    self.containerView.addSubview(view)
                }
            }
            
            seal.fulfill(true)
        }
    }
    
    func removePageViewAtPosition(position: Int) -> Promise<Bool> {
        return Promise<Bool> { seal in
            let pageView = self.pagesViews[position]
            if pageView != nil {
                pageView!.removeFromSuperview()
                self.pagesViews[position] = nil
            }
            seal.fulfill(true)
        }
    }
    
    func getRangeOfViews() -> (start: Int, end: Int) {
        var start = self.currentPage - TractViewController.distanceToCurrentView
        if start < 0 {
            start = 0
        }
        
        var end = self.currentPage + TractViewController.distanceToCurrentView
        if end >= self.totalPages() {
            end = totalPages() - 1
        }
        
        return (start, end)
    }
    
    func cleanContainerView() {
        addSnapshotView()
        
        for view in self.containerView.subviews {
            if view.tag != TractViewController.snapshotViewTag {
                view.removeFromSuperview()
            }
        }
        
        self.pagesViews.removeAll()
        resetPagesView()
    }
    
    func resetPagesView() {
        self.pagesViews = [TractView?](repeating: nil, count: totalPages())
    }
    
    private func addSnapshotView() {
        let imageView = UIImageView(frame: self.containerView.frame)
        imageView.image = UIImage.init(view: self.containerView)
        imageView.tag = TractViewController.snapshotViewTag
        self.containerView.addSubview(imageView)
    }
    
    private func removeSnapshotView() {
        let snapshotView = self.containerView.viewWithTag(TractViewController.snapshotViewTag)
        snapshotView?.removeFromSuperview()
    }
    
    private func showErrorMessage() {
        let alert = UIAlertController(title: "error".localized,
                                      message: "tract_loading_error_message".localized,
                                      preferredStyle: .alert)
        
        let actionYes = UIAlertAction(title: "yes".localized,
                                      style: .default,
                                      handler: { action in
                                        self.redownloadResources()
        })
        
        let actionNo = UIAlertAction(title: "no".localized,
                                      style: .cancel,
                                      handler: { action in
                                        self.disableResource()
        })
        
        alert.addAction(actionYes)
        alert.addAction(actionNo)
        present(alert, animated: true, completion: nil)
    }
    
    private func redownloadResources() {
        DownloadedResourceManager().delete(viewModel.resource)
        DownloadedResourceManager().download(viewModel.resource)
        postReloadHomeScreenNotification()
    }
    
    private func disableResource() {
        DownloadedResourceManager().delete(viewModel.resource)
        postReloadHomeScreenNotification()
    }
    
    private func postReloadHomeScreenNotification() {
        NotificationCenter.default.post(name: .reloadHomeListNotification, object: nil)
    }
}

// MARK: - Data Management

extension TractViewController {
    
    // MARK: - Management of languages
    
    func parallelLanguageIsAvailable() -> Bool {
        if parallelLanguage == nil {
            return false
        }
        
        return viewModel.resource.isDownloadedInLanguage(parallelLanguage)
    }
    
    func determinePrimaryLabel() -> String {
        let primaryLanguage = resolvePrimaryLanguage()
        
        if primaryLanguage == nil {
            return Locale.current.localizedString(forLanguageCode: Locale.current.languageCode!)!
        } else {
            return primaryLanguage!.localizedName()
        }
    }
    
    func determineParallelLabel() -> String {
        return parallelLanguage?.localizedName() ?? ""
    }
    
    func getLanguageTextAlignment() -> NSTextAlignment {
        return .left
    }
    
    // MARK: - Management of resources
    
    func getResourceData() {
        loadResourcesForLanguage()
        loadResourcesForParallelLanguage()
        usePrimaryLanguageResources()
        loadPagesIds()
    }
    
    func loadResourcesForLanguage() {
        guard let language = resolvePrimaryLanguage() else { return }
        let content = self.tractsManager.loadResource(resource: viewModel.resource, language: language)
        self.xmlPagesForPrimaryLang = content.pages
        self.manifestProperties = content.manifestProperties
    }
    
    func loadResourcesForParallelLanguage() {
        if parallelLanguageIsAvailable() {
            let content = self.tractsManager.loadResource(resource: viewModel.resource, language: parallelLanguage!)
            self.xmlPagesForParallelLang = content.pages
        }
    }
    
    func loadPagesIds() {
        var counter = 0
        for page in self.xmlPages {
            guard let pageListeners = page.pageListeners() else { continue }
            for listener in pageListeners {
                TractBindings.addPageBinding(listener, counter)
            }
            
            counter += 1
        }
    }
    
    func usePrimaryLanguageResources() {
        self.selectedLanguage = resolvePrimaryLanguage()
        self.xmlPages = self.xmlPagesForPrimaryLang
    }
    
    func useParallelLanguageResources() {
        self.selectedLanguage = parallelLanguage
        self.xmlPages = self.xmlPagesForParallelLang
    }
    
    func getPage(_ pageNumber: Int) -> XMLPage {
        return self.xmlPages[pageNumber]
    }
    
    func totalPages() -> Int {
        return self.xmlPages.count;
    }
}
