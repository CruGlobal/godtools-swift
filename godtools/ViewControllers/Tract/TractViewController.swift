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

class TractViewController: BaseViewController {
    
    let tractsManager: TractManager = TractManager()
    var resource: DownloadedResource?
    var viewsWereGenerated :Bool = false
    var xmlPages = [XMLIndexer]()
    var colors: TractColors?
    var primaryTextColor: UIColor?
    var textColor: UIColor?
    var currentPage = 0
    var currentMovement: CGFloat {
        return CGFloat(currentPage) *  -self.view.frame.width
    }
    var containerView = UIView()
    var pagesViews = [UIView]()
    var progressView = UIView()
    var progressViewHelper = UIView()
    var currentProgressView = UIView()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getResourceData()
        displayTitle()
        setupSwipeGestures()
        defineObservers()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if self.viewsWereGenerated {
            return
        }
        
        initializeView()
        self.viewsWereGenerated = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupStyle()
        self.displayTitle()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.progressViewHelper.removeFromSuperview()
        self.progressView.removeFromSuperview()
    }
    
    override func configureNavigationButtons() {
        self.addHomeButton()
        self.addShareButton()
    }
    
    fileprivate func displayTitle() {
        if parallelLanguageIsAvailable() {
            self.navigationItem.titleView = languageSegmentedControl()
        } else {
            self.title = currentTractTitle()
        }
    }
    
    fileprivate func setupStyle() {
        setupNavigationBarStyles()
    }
    
    fileprivate func setupNavigationBarStyles() {
        self.baseDelegate?.changeNavigationBarColor((self.colors?.primaryColor)!)
        
        let navigationBar = navigationController!.navigationBar
        
        let width = navigationBar.frame.size.width
        let height = CGFloat(4.0)
        let xOrigin = CGFloat(0.0)
        let yOrigin = CGFloat(0.0)
        let progressViewFrame = CGRect(x: xOrigin, y: yOrigin, width: width, height: height)
        
        self.currentProgressView = UIView()
        self.currentProgressView.frame = CGRect(x: 0.0, y: 0.0, width: currentProgressWidth(), height: height)
        self.currentProgressView.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        
        self.progressViewHelper = UIView()
        self.progressViewHelper.frame = progressViewFrame
        self.progressViewHelper.backgroundColor = .white
        
        self.progressView = UIView()
        self.progressView.frame = progressViewFrame
        self.progressView.backgroundColor = self.colors?.primaryColor?.withAlphaComponent(0.65)
        self.progressView.addSubview(self.currentProgressView)
        
        navigationBar.addSubview(self.progressViewHelper)
        navigationBar.addSubview(self.progressView)
        
        setupNavigationBarFrame()
    }
    
    @objc fileprivate func setupNavigationBarFrame() {
        let navigationBar = navigationController!.navigationBar
        
        let xOrigin = CGFloat(0.0)
        let yOrigin = CGFloat(0.0)
        let width = navigationBar.frame.size.width
        let navigationBarHeight = CGFloat(64.0)
        
        navigationBar.frame = CGRect(x: xOrigin, y: yOrigin, width: width, height: navigationBarHeight)
    }
    
    // MARK: Build content
    
    fileprivate func initializeView() {
        let navigationBarFrame = navigationController!.navigationBar.frame
        let startingPoint = navigationBarFrame.origin.y + navigationBarFrame.size.height
        
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height - startingPoint
        self.containerView.frame = CGRect(x: 0.0, y: startingPoint, width: width, height: height)
        self.view.addSubview(self.containerView)
        
        buildPages(width, height)
    }
    
    fileprivate func buildPages(_ width: CGFloat, _ height: CGFloat) {
        let range = getRangeOfViews()
        
        for pageNumber in range.start...range.end {
            let view = buildPage(pageNumber, width: width, height: height)
            self.pagesViews.append(view)
            self.containerView.addSubview(view)
        }
    }
    
    fileprivate func buildPage(_ page: Int, width: CGFloat, height: CGFloat) -> UIView {
        let xPosition = (width * CGFloat(page))
        let frame = CGRect(x: xPosition,
                           y: 0.0,
                           width: width,
                           height: height)
        let view = BaseTractView(frame: frame)
        view.transform = CGAffineTransform(translationX: self.currentMovement, y: 0.0)
        view.data = getPage(page)
        view.colors = self.colors
        view.tag = 100 + page
        return view
    }
    
    fileprivate func reloadPagesViews() {
        let range = getRangeOfViews()
        let firstTag = (self.pagesViews.first?.tag)! - 100
        let lastTag = (self.pagesViews.last?.tag)! - 100
        let width = self.containerView.frame.size.width
        let height = self.containerView.frame.size.height
        
        if firstTag < range.start {
            let view = self.pagesViews.first
            self.pagesViews.removeFirst()
            view?.removeFromSuperview()
        } else if firstTag > range.start {
            let view = buildPage(range.start, width: width, height: height)
            self.pagesViews.insert(view, at: 0)
            self.containerView.addSubview(view)
        }
        
        if lastTag < range.end {
            let view = buildPage(range.end, width: width, height: height)
            self.pagesViews.append(view)
            self.containerView.addSubview(view)
        } else if lastTag > range.end {
            let view = self.pagesViews.last
            self.pagesViews.removeLast()
            view?.removeFromSuperview()
        }
    }
    
    fileprivate func getRangeOfViews() -> (start: Int, end: Int) {
        var start = self.currentPage - 2
        if start < 0 {
            start = 0
        }
        
        var end = self.currentPage + 2
        if end > self.totalPages() - 1 {
            end = totalPages() - 1
        }
        
        return (start, end)
    }
    
    // MARK: - Swipe gestures
    
    fileprivate func setupSwipeGestures() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    @objc fileprivate func handleGesture(sender: UISwipeGestureRecognizer) {
        if sender.direction == .right {
            moveToPreviousPage()
        } else if sender.direction == .left {
            moveToNextPage()
        }
    }
    
    // MARK: - Handle page movements
    
    func moveToNextPage() {
        if self.currentPage >= totalPages() - 1 {
            return
        }
        
        self.currentPage += 1
        reloadPagesViews()
        moveViews()
    }
    
    func moveToPreviousPage() {
        if self.currentPage == 0 {
            return
        }
        
        self.currentPage -= 1
        reloadPagesViews()
        moveViews()
    }
    
    fileprivate func moveViews() {
        let newCurrentProgressViewFrame = CGRect(x: 0.0,
                                                 y: 0.0,
                                                 width: currentProgressWidth(),
                                                 height: self.currentProgressView.frame.size.height)
        
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        self.currentProgressView.frame = newCurrentProgressViewFrame
                        for view in self.pagesViews {
                            view.transform = CGAffineTransform(translationX: self.currentMovement, y: 0.0)
                        } },
                       completion: nil )
    }
    
    fileprivate func currentProgressWidth() -> CGFloat {
        let parentWidth = self.navigationController?.navigationBar.frame.size.width
        return CGFloat(self.currentPage) * parentWidth! / CGFloat(self.totalPages() - 1)
    }
    
    // MARK: - Navigation buttons actions
    
    override func homeButtonAction() {
        self.baseDelegate?.goBack()
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
                                               selector: #selector(moveToNextPage),
                                               name: NSNotification.Name.moveToNextPageNotification,
                                               object: nil)
    }
    
}

extension TractViewController {
    
    fileprivate func currentTractTitle() -> String {
        return resource != nil ? resource!.name! : "GodTools"
    }
    
    fileprivate func parallelLanguageIsAvailable() -> Bool {
        let parallelLanguage = LanguagesManager.shared.loadParallelLanguageFromDisk()
        
        if parallelLanguage == nil {
            return false
        }
        
        return resource!.isAvailableInLanguage(parallelLanguage!)
    }
    
    fileprivate func languageSegmentedControl() -> UISegmentedControl {
        let primaryLabel = self.determinePrimaryLabel()
        let parallelLabel = self.determineParallelLabel()
        
        let control = UISegmentedControl(items: [primaryLabel, parallelLabel])
        control.selectedSegmentIndex = 0
        return control
    }
    
    fileprivate func determinePrimaryLabel() -> String {
        let primaryLanguage = LanguagesManager.shared.loadPrimaryLanguageFromDisk()
        
        if primaryLanguage == nil {
            return Locale.current.localizedString(forLanguageCode: Locale.current.languageCode!)!
        } else {
            return primaryLanguage!.localizedName()
        }
    }
    
    fileprivate func determineParallelLabel() -> String {
        let parallelLanguage = LanguagesManager.shared.loadParallelLanguageFromDisk()
        
        return parallelLanguage!.localizedName()
    }
    
    fileprivate func getResourceData() {
        let resource = self.tractsManager.loadResource(resource: "kgp")
        self.xmlPages = resource.pages
        self.colors = resource.colors
    }
    
    fileprivate func getPage(_ pageNumber: Int) -> XMLIndexer {
        return self.xmlPages[pageNumber]
    }
    
    fileprivate func totalPages() -> Int {
        return self.xmlPages.count;
    }
    
}
