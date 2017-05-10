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
    
    var viewsWereGenerated = false
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
        self.xmlPages = buildData()
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
        let startingYPos = navigationBarFrame.origin.y + navigationBarFrame.size.height
        
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height - startingYPos
        self.containerView.frame = CGRect(x: 0.0, y: startingYPos, width: width, height: height)
        self.view.addSubview(self.containerView)
        
        buildPages(width: width, height: height)
    }
    
    fileprivate func buildPages(width: CGFloat, height: CGFloat) {
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
    
    fileprivate func buildData() -> [XMLIndexer] {
        var xmlPages = [XMLIndexer]()
        
        let page1 = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?><!-- https://projects.invisionapp.com/d/main#/console/10765517/228342248/preview --><page xmlns=\"http://mobile-content-api.cru.org/xmlns/tract\" xmlns:content=\"https://mobile-content-api.cru.org/xmlns/content\"><hero><heading><content:text i18n-id=\"{{uuid}}\">Knowing God Personally</content:text></heading><paragraph><content:text i18n-id=\"{{uuid}}\">These four points explain how to enter into a personal relationship with God and experience the life for which you were created.</content:text></paragraph></hero></page>"
        let xml1 = SWXMLHash.parse(page1)
        
        let page2 = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?><!-- https://projects.invisionapp.com/d/main#/console/10765517/228342251/preview --><page xmlns=\"http://mobile-content-api.cru.org/xmlns/tract\" xmlns:content=\"https://mobile-content-api.cru.org/xmlns/content\" background-image=\"{{path_to_sunrise.png}}\"><header><number><content:text i18n-id=\"{{uuid}}\">1</content:text></number><title><content:text i18n-id=\"{{uuid}}\">God loves you and created you to know him personally.</content:text></title></header><card><label><content:text i18n-id=\"{{uuid}}\">God loves you</content:text></label><paragraph><content:text i18n-id=\"{{uuid}}\">\"For God so loved the world, that He gave His only begotten Son, that whoever believes in Him should not perish, but have eternal life.\"</content:text><content:text i18n-id=\"{{uuid}}\">John 3:16 NIV</content:text></paragraph></card><card><label><content:text i18n-id=\"{{uuid}}\">God wants you to know him</content:text></label><paragraph><content:text i18n-id=\"{{uuid}}\">\"Now this is eternal life: that they may know You, the only true God, and Jesus Christ, whom You have sent.\"</content:text><content:text i18n-id=\"{{uuid}}\">John 17:3 NIV</content:text></paragraph></card></page>"
        let xml2 = SWXMLHash.parse(page2)
        
        let page3 = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?><!-- https://projects.invisionapp.com/d/main#/console/10765517/228342261/preview --><page xmlns=\"http://mobile-content-api.cru.org/xmlns/tract\" xmlns:content=\"https://mobile-content-api.cru.org/xmlns/content\" background-image=\"{{chasm_in_between.png}}\"><header><number><content:text i18n-id=\"{{uuid}}\">2</content:text></number><title><content:text i18n-id=\"{{uuid}}\">We are separated from God by our sin, so we cannot know him or experience his love.</content:text></title></header><card><label><content:text i18n-id=\"{{uuid}}\">What is sin?</content:text></label><paragraph><content:text i18n-id=\"{{uuid}}\">We were created to have a relationship with God, but we rejected him and the relationship was broken.</content:text><content:text>This rejection of God and the building of our lives around anything else is what the Bible calls sin.</content:text><content:text>We show this by having selfish actions and attitudes, by disobeying God or displaying indifference toward him.</content:text></paragraph></card><card background-image=\"{{chasm_in_between.png}}\" background-image-align=\"bottom\"><label><content:text i18n-id=\"{{uuid}}\">Everyone is sinful</content:text></label><paragraph><content:text i18n-id=\"{{uuid}}\">“For everyone has sinned: we all fall short of God’s glorious standard.”</content:text><content:text i18n-id=\"{{uuid}}\">Romans 3:23</content:text></paragraph></card><card><label><content:text i18n-id=\"{{uuid}}\">Sin has consequences</content:text></label><paragraph><content:text i18n-id=\"{{uuid}}\">For the wages of sin is death, but the free gift of God is eternal life through Christ Jesus our Lord.</content:text><content:text i18n-id=\"{{uuid}}\">Romans 6:23</content:text><content:text i18n-id=\"{{uuid}}\">God is perfect and just and will hold us accountable for our sin. There is a penalty for rejecting God.</content:text><content:text i18n-id=\"{{uuid}}\">God is perfect and we are sinful. There is a great gap between us because of our sin.</content:text><content:text i18n-id=\"{{uuid}}\">We may try to bridge this gap through good deeds or following a religion. However, all our efforts fail because they can’t solve the problem of sin that keeps us from God.</content:text></paragraph></card><call-to-action><content:text i18n-id=\"{{uuid}}\">The third point gives us the only solution to this problem…</content:text></call-to-action></page>"
        let xml3 = SWXMLHash.parse(page3)
        
        let page4 = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?><!-- https://projects.invisionapp.com/d/main#/console/10765517/228342261/preview --><page xmlns=\"http://mobile-content-api.cru.org/xmlns/tract\" xmlns:content=\"https://mobile-content-api.cru.org/xmlns/content\" background-image=\"{{chasm_in_between.png}}\"><header><number><content:text i18n-id=\"{{uuid}}\">3</content:text></number><title><content:text i18n-id=\"{{uuid}}\">We are separated from God by our sin, so we cannot know him or experience his love.</content:text></title></header><card><label><content:text i18n-id=\"{{uuid}}\">What is sin?</content:text></label><paragraph><content:text i18n-id=\"{{uuid}}\">We were created to have a relationship with God, but we rejected him and the relationship was broken.</content:text><content:text>This rejection of God and the building of our lives around anything else is what the Bible calls sin.</content:text><content:text>We show this by having selfish actions and attitudes, by disobeying God or displaying indifference toward him.</content:text></paragraph></card><card background-image=\"{{chasm_in_between.png}}\" background-image-align=\"bottom\"><label><content:text i18n-id=\"{{uuid}}\">Everyone is sinful</content:text></label><paragraph><content:text i18n-id=\"{{uuid}}\">“For everyone has sinned: we all fall short of God’s glorious standard.”</content:text><content:text i18n-id=\"{{uuid}}\">Romans 3:23</content:text></paragraph></card><card><label><content:text i18n-id=\"{{uuid}}\">Sin has consequences</content:text></label><paragraph><content:text i18n-id=\"{{uuid}}\">For the wages of sin is death, but the free gift of God is eternal life through Christ Jesus our Lord.</content:text><content:text i18n-id=\"{{uuid}}\">Romans 6:23</content:text><content:text i18n-id=\"{{uuid}}\">God is perfect and just and will hold us accountable for our sin. There is a penalty for rejecting God.</content:text><content:text i18n-id=\"{{uuid}}\">God is perfect and we are sinful. There is a great gap between us because of our sin.</content:text><content:text i18n-id=\"{{uuid}}\">We may try to bridge this gap through good deeds or following a religion. However, all our efforts fail because they can’t solve the problem of sin that keeps us from God.</content:text><content:text i18n-id=\"{{uuid}}\">We may try to bridge this gap through good deeds or following a religion. However, all our efforts fail because they can’t solve the problem of sin that keeps us from God.</content:text><content:text i18n-id=\"{{uuid}}\">We may try to bridge this gap through good deeds or following a religion. However, all our efforts fail because they can’t solve the problem of sin that keeps us from God.</content:text></paragraph></card><call-to-action><content:text i18n-id=\"{{uuid}}\">The third point gives us the only solution to this problem…</content:text></call-to-action></page>"
        let xml4 = SWXMLHash.parse(page4)
        
        let page5 = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?><!-- https://projects.invisionapp.com/d/main#/console/10765517/228342251/preview --><page xmlns=\"http://mobile-content-api.cru.org/xmlns/tract\" xmlns:content=\"https://mobile-content-api.cru.org/xmlns/content\" background-image=\"{{path_to_sunrise.png}}\"><header><number><content:text i18n-id=\"{{uuid}}\">4</content:text></number><title><content:text i18n-id=\"{{uuid}}\">God loves you and created you to know him personally.</content:text></title></header><card><label><content:text i18n-id=\"{{uuid}}\">God loves you</content:text></label><paragraph><content:text i18n-id=\"{{uuid}}\">\"For God so loved the world, that He gave His only begotten Son, that whoever believes in Him should not perish, but have eternal life.\"</content:text><content:text i18n-id=\"{{uuid}}\">John 3:16 NIV</content:text></paragraph></card><card><label><content:text i18n-id=\"{{uuid}}\">God wants you to know him</content:text></label><paragraph><content:text i18n-id=\"{{uuid}}\">\"Now this is eternal life: that they may know You, the only true God, and Jesus Christ, whom You have sent.\"</content:text><content:text i18n-id=\"{{uuid}}\">John 17:3 NIV</content:text></paragraph></card></page>"
        let xml5 = SWXMLHash.parse(page5)
        
        let page6 = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?><!-- https://projects.invisionapp.com/d/main#/console/10765517/228342261/preview --><page xmlns=\"http://mobile-content-api.cru.org/xmlns/tract\" xmlns:content=\"https://mobile-content-api.cru.org/xmlns/content\" background-image=\"{{chasm_in_between.png}}\"><header><number><content:text i18n-id=\"{{uuid}}\">5</content:text></number><title><content:text i18n-id=\"{{uuid}}\">We are separated from God by our sin, so we cannot know him or experience his love.</content:text></title></header><card><label><content:text i18n-id=\"{{uuid}}\">What is sin?</content:text></label><paragraph><content:text i18n-id=\"{{uuid}}\">We were created to have a relationship with God, but we rejected him and the relationship was broken.</content:text><content:text>This rejection of God and the building of our lives around anything else is what the Bible calls sin.</content:text><content:text>We show this by having selfish actions and attitudes, by disobeying God or displaying indifference toward him.</content:text></paragraph></card><card background-image=\"{{chasm_in_between.png}}\" background-image-align=\"bottom\"><label><content:text i18n-id=\"{{uuid}}\">Everyone is sinful</content:text></label><paragraph><content:text i18n-id=\"{{uuid}}\">“For everyone has sinned: we all fall short of God’s glorious standard.”</content:text><content:text i18n-id=\"{{uuid}}\">Romans 3:23</content:text></paragraph></card><card><label><content:text i18n-id=\"{{uuid}}\">Sin has consequences</content:text></label><paragraph><content:text i18n-id=\"{{uuid}}\">For the wages of sin is death, but the free gift of God is eternal life through Christ Jesus our Lord.</content:text><content:text i18n-id=\"{{uuid}}\">Romans 6:23</content:text><content:text i18n-id=\"{{uuid}}\">God is perfect and just and will hold us accountable for our sin. There is a penalty for rejecting God.</content:text><content:text i18n-id=\"{{uuid}}\">God is perfect and we are sinful. There is a great gap between us because of our sin.</content:text><content:text i18n-id=\"{{uuid}}\">We may try to bridge this gap through good deeds or following a religion. However, all our efforts fail because they can’t solve the problem of sin that keeps us from God.</content:text></paragraph></card><call-to-action><content:text i18n-id=\"{{uuid}}\">The third point gives us the only solution to this problem…</content:text></call-to-action></page>"
        let xml6 = SWXMLHash.parse(page6)
        
        let page7 = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?><!-- https://projects.invisionapp.com/d/main#/console/10765517/228342261/preview --><page xmlns=\"http://mobile-content-api.cru.org/xmlns/tract\" xmlns:content=\"https://mobile-content-api.cru.org/xmlns/content\" background-image=\"{{chasm_in_between.png}}\"><header><number><content:text i18n-id=\"{{uuid}}\">6</content:text></number><title><content:text i18n-id=\"{{uuid}}\">We are separated from God by our sin, so we cannot know him or experience his love.</content:text></title></header><card><label><content:text i18n-id=\"{{uuid}}\">What is sin?</content:text></label><paragraph><content:text i18n-id=\"{{uuid}}\">We were created to have a relationship with God, but we rejected him and the relationship was broken.</content:text><content:text>This rejection of God and the building of our lives around anything else is what the Bible calls sin.</content:text><content:text>We show this by having selfish actions and attitudes, by disobeying God or displaying indifference toward him.</content:text></paragraph></card><card background-image=\"{{chasm_in_between.png}}\" background-image-align=\"bottom\"><label><content:text i18n-id=\"{{uuid}}\">Everyone is sinful</content:text></label><paragraph><content:text i18n-id=\"{{uuid}}\">“For everyone has sinned: we all fall short of God’s glorious standard.”</content:text><content:text i18n-id=\"{{uuid}}\">Romans 3:23</content:text></paragraph></card><card><label><content:text i18n-id=\"{{uuid}}\">Sin has consequences</content:text></label><paragraph><content:text i18n-id=\"{{uuid}}\">For the wages of sin is death, but the free gift of God is eternal life through Christ Jesus our Lord.</content:text><content:text i18n-id=\"{{uuid}}\">Romans 6:23</content:text><content:text i18n-id=\"{{uuid}}\">God is perfect and just and will hold us accountable for our sin. There is a penalty for rejecting God.</content:text><content:text i18n-id=\"{{uuid}}\">God is perfect and we are sinful. There is a great gap between us because of our sin.</content:text><content:text i18n-id=\"{{uuid}}\">We may try to bridge this gap through good deeds or following a religion. However, all our efforts fail because they can’t solve the problem of sin that keeps us from God.</content:text><content:text i18n-id=\"{{uuid}}\">We may try to bridge this gap through good deeds or following a religion. However, all our efforts fail because they can’t solve the problem of sin that keeps us from God.</content:text><content:text i18n-id=\"{{uuid}}\">We may try to bridge this gap through good deeds or following a religion. However, all our efforts fail because they can’t solve the problem of sin that keeps us from God.</content:text></paragraph></card><call-to-action><content:text i18n-id=\"{{uuid}}\">The third point gives us the only solution to this problem…</content:text></call-to-action></page>"
        let xml7 = SWXMLHash.parse(page7)
        
        xmlPages.append(xml1)
        xmlPages.append(xml2)
        xmlPages.append(xml3)
        xmlPages.append(xml4)
        xmlPages.append(xml5)
        xmlPages.append(xml6)
        xmlPages.append(xml7)
        
        return xmlPages
    }
}
