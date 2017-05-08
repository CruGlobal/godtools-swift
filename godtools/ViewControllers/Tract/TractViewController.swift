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
    var viewsWereGenerated :Bool = false
    var xmlPages = [XMLIndexer]()
    var currentPage = 0
    var currentMovement: CGFloat {
        return CGFloat(currentPage) *  -self.view.frame.width
    }
    var containerView = UIView()
    var pagesViews = [UIView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getData()
        displayTitle()
        setupSwipeGestures()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if self.viewsWereGenerated {
            return
        }
        
        initializeView()
        self.viewsWereGenerated = true
    }
    
    var resource: DownloadedResource?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.displayTitle()
    }
    override func configureNavigationButtons() {
        self.addHomeButton()
        self.addShareButton()
    }
    
    func getData() {
        self.xmlPages = self.tractsManager.loadPagesForResource(resource: "kgp")
    }
    
    func getPage(_ pageNumber: Int) -> XMLIndexer {
        return self.xmlPages[pageNumber]
    }
    
    fileprivate func displayTitle() {
        if parallelLanguageIsAvailable() {
            self.navigationItem.titleView = languageSegmentedControl()
        } else {
            self.title = currentTractTitle()
        }
    }
    
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
    
    func setupSwipeGestures() {
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
    
    func moveViews() {
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        for view in self.pagesViews {
                            view.transform = CGAffineTransform(translationX: self.currentMovement, y: 0.0)
                        } },
                       completion: nil )
    }
    
    // MARK: - Navigation buttons actions
    
    override func homeButtonAction() {
        self.baseDelegate?.goBack()
    }
    
    override func shareButtonAction() {
        let activityController = UIActivityViewController(activityItems: [String.localizedStringWithFormat("tract_share_message".localized, "www.knowgod.com")], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
    
}

// MARK: - stub methods to be filled in with real logic later

extension TractViewController {
    
    fileprivate func parallelLanguageIsAvailable() -> Bool {
        let parallelLanguage = LanguagesManager.shared.loadParallelLanguageFromDisk()
        
        if parallelLanguage == nil {
            return false
        }
        
        return resource!.isAvailableInLanguage(parallelLanguage!)
    }
    
    fileprivate func currentTractTitle() -> String {
        return resource != nil ? resource!.name! : "GodTools"
    }
    
    fileprivate func languageSegmentedControl() -> UISegmentedControl {
        let primaryLabel = self.determinePrimaryLabel()
        let parallelLabel = self.determineParallelLabel()
        
        let control = UISegmentedControl(items: [primaryLabel, parallelLabel])
        control.selectedSegmentIndex = 0
        return control
    }
    
    fileprivate func totalPages() -> Int {
        return self.xmlPages.count;
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
    
}
