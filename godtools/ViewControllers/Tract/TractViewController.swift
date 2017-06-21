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

class TractViewController: BaseViewController {
    
    let languagesManager = LanguagesManager()
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
    let viewTagOrigin = 100
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TractBindings.setupBindings()
        getResourceData()
        setupSwipeGestures()
        defineObservers()
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
        super.viewDidDisappear(animated)
        self.progressViewHelper.removeFromSuperview()
        self.progressView.removeFromSuperview()
    }
    
    // MARK: - UI setup
    
    override func configureNavigationButtons() {
        self.addHomeButton()
        self.addShareButton()
    }

    override func displayScreenTitle() {
        if parallelLanguageIsAvailable() && determinePrimaryLabel() != determineParallelLabel() {
            self.navigationItem.titleView = languageSegmentedControl()
        }
    }
    
    fileprivate func setupContainerView() {
        let navigationBarFrame = navigationController!.navigationBar.frame
        let startingYPos = navigationBarFrame.origin.y + navigationBarFrame.size.height
        
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
        let primaryLanguage = languagesManager.loadPrimaryLanguageFromDisk()
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
    }
    
    @objc fileprivate func setupNavigationBarFrame() {
        let navigationBar = navigationController!.navigationBar
        
        let xOrigin: CGFloat = 0.0
        let yOrigin: CGFloat = 0.0
        let width = navigationBar.frame.size.width
        let navigationBarHeight: CGFloat = 64.0
        
        navigationBar.frame = CGRect(x: xOrigin, y: yOrigin, width: width, height: navigationBarHeight)
    }
    
    // MARK: - Segmented Control
    
    fileprivate func languageSegmentedControl() -> UISegmentedControl {
        let primaryLabel = self.determinePrimaryLabel()
        let parallelLabel = self.determineParallelLabel()
        
        let segmentedControl = UISegmentedControl(items: [primaryLabel, parallelLabel])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(didSelectLanguage), for: .valueChanged)
        return segmentedControl
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
        let activityController = UIActivityViewController(activityItems: [String.localizedStringWithFormat("tract_share_message".localized, "www.knowgod.com")], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
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
        let parentWidth = self.navigationController?.navigationBar.frame.size.width
        return CGFloat(self.currentPage) * parentWidth! / CGFloat(self.totalPages() - 1)
    }
    
}
