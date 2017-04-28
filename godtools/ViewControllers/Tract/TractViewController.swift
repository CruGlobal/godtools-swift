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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayTitle()
        initializeView()
        setupSwipeGestures()
    }
    
    func setupSwipeGestures() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    @objc fileprivate func handleGesture(gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .right {
            moveToPreviousPage()
        } else if gesture.direction == .left {
            moveToNextPage()
        }
    }
    
    func moveToNextPage() {
        let navigationController = self.navigationController
        let tractViewController = TractViewController(nibName: String(describing:TractViewController.self), bundle: nil)
        navigationController?.pushViewController(tractViewController, animated: true)
    }
    
    func moveToPreviousPage() {
        let navigationController = self.navigationController
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func configureNavigationButtons() {
        addHomeButton()
        addShareButton()
    }

    fileprivate func displayTitle() {
        if parallelLanguageIsAvailable() {
            navigationItem.titleView = languageSegmentedControl()
        } else {
            navigationItem.title = currentTractTitle()
        }
    }
    
    fileprivate func initializeView() {
        let navigationBarFrame = navigationController!.navigationBar.frame
        let startingPoint = navigationBarFrame.origin.y + navigationBarFrame.size.height
        
        let baseView = Bundle.main.loadNibNamed("BaseTractView", owner: self, options: nil)!.first as! BaseTractView
        baseView.data = getData()
        baseView.frame = CGRect(x: 0.0,
                                y: startingPoint,
                                width: self.view.frame.size.width,
                                height: self.view.frame.size.height - startingPoint)
                
        view.addSubview(baseView)
    }
    
    override func homeButtonAction() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func shareButtonAction() {
        let activityController = UIActivityViewController(activityItems: [String.localizedStringWithFormat("tract_share_message".localized, "www.knowgod.com")], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
    
    func getData() -> XMLIndexer {
        return dummyDataPage1()
    }
    
    // MARK: - Dummy Data
    
    fileprivate func dummyDataPage1() -> XMLIndexer {
        let xmlToParse = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?><!-- https://projects.invisionapp.com/d/main#/console/10765517/228342248/preview --><page xmlns=\"http://mobile-content-api.cru.org/xmlns/tract\" xmlns:content=\"https://mobile-content-api.cru.org/xmlns/content\"><hero><heading><content:text i18n-id=\"{{uuid}}\">Knowing God Personally</content:text></heading><paragraph><content:text i18n-id=\"{{uuid}}\">These four points explain how to enter into a personal relationship with God and experience the life for which you were created.</content:text></paragraph></hero></page>"
        let xml = SWXMLHash.parse(xmlToParse)
        
        
        return xml
    }
    
    fileprivate func dummyDataPage2() -> XMLIndexer {
        let xmlToParse = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?><!-- https://projects.invisionapp.com/d/main#/console/10765517/228342251/preview --><page xmlns=\"http://mobile-content-api.cru.org/xmlns/tract\" xmlns:content=\"https://mobile-content-api.cru.org/xmlns/content\" background-image=\"{{path_to_sunrise.png}}\"><header><number><content:text i18n-id=\"{{uuid}}\">1</content:text></number><title><content:text i18n-id=\"{{uuid}}\">God loves you and created you to know him personally.</content:text></title></header><card><label><content:text i18n-id=\"{{uuid}}\">God loves you</content:text></label><paragraph><content:text i18n-id=\"{{uuid}}\">\"For God so loved the world, that He gave His only begotten Son, that whoever believes in Him should not perish, but have eternal life.\"</content:text><content:text i18n-id=\"{{uuid}}\">John 3:16 NIV</content:text></paragraph></card><card><label><content:text i18n-id=\"{{uuid}}\">God wants you to know him</content:text></label><paragraph><content:text i18n-id=\"{{uuid}}\">\"Now this is eternal life: that they may know You, the only true God, and Jesus Christ, whom You have sent.\"</content:text><content:text i18n-id=\"{{uuid}}\">John 17:3 NIV</content:text></paragraph></card></page>"
        let xml = SWXMLHash.parse(xmlToParse)
        return xml
    }
    
    fileprivate func dummyDataPage3() -> XMLIndexer {
        let xmlToParse = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?><!-- https://projects.invisionapp.com/d/main#/console/10765517/228342261/preview --><page xmlns=\"http://mobile-content-api.cru.org/xmlns/tract\" xmlns:content=\"https://mobile-content-api.cru.org/xmlns/content\" background-image=\"{{chasm_in_between.png}}\"><header><number><content:text i18n-id=\"{{uuid}}\">2</content:text></number><title><content:text i18n-id=\"{{uuid}}\">We are separated from God by our sin, so we cannot know him or experience his love.</content:text></title></header><card><label><content:text i18n-id=\"{{uuid}}\">What is sin?</content:text></label><paragraph><content:text i18n-id=\"{{uuid}}\">We were created to have a relationship with God, but we rejected him and the relationship was broken.</content:text><content:text>This rejection of God and the building of our lives around anything else is what the Bible calls sin.</content:text><content:text>We show this by having selfish actions and attitudes, by disobeying God or displaying indifference toward him.</content:text></paragraph></card><card background-image=\"{{chasm_in_between.png}}\" background-image-align=\"bottom\"><label><content:text i18n-id=\"{{uuid}}\">Everyone is sinful</content:text></label><paragraph><content:text i18n-id=\"{{uuid}}\">“For everyone has sinned: we all fall short of God’s glorious standard.”</content:text><content:text i18n-id=\"{{uuid}}\">Romans 3:23</content:text></paragraph></card><card><label><content:text i18n-id=\"{{uuid}}\">Sin has consequences</content:text></label><paragraph><content:text i18n-id=\"{{uuid}}\">For the wages of sin is death, but the free gift of God is eternal life through Christ Jesus our Lord.</content:text><content:text i18n-id=\"{{uuid}}\">Romans 6:23</content:text><content:text i18n-id=\"{{uuid}}\">God is perfect and just and will hold us accountable for our sin. There is a penalty for rejecting God.</content:text><content:text i18n-id=\"{{uuid}}\">God is perfect and we are sinful. There is a great gap between us because of our sin.</content:text><content:text i18n-id=\"{{uuid}}\">We may try to bridge this gap through good deeds or following a religion. However, all our efforts fail because they can’t solve the problem of sin that keeps us from God.</content:text></paragraph></card><call-to-action><content:text i18n-id=\"{{uuid}}\">The third point gives us the only solution to this problem…</content:text></call-to-action></page>"
        let xml = SWXMLHash.parse(xmlToParse)
        return xml
    }
}

// MARK - stub methods to be filled in with real logic later

extension TractViewController {
    fileprivate func parallelLanguageIsAvailable() -> Bool {
        return arc4random_uniform(2) % 2 == 0
    }
    
    fileprivate func currentTractTitle() -> String {
        return "Knowing God Personally"
    }
    
    fileprivate func languageSegmentedControl() -> UISegmentedControl {
        let control = UISegmentedControl(items: ["English", "French"])
        control.selectedSegmentIndex = 0
        return control
    }
}
