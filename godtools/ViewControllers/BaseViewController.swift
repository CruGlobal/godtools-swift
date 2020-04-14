//
//  GTBaseViewController.swift
//  godtools
//
//  Created by Devserker on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

protocol BaseViewControllerDelegate: class {
    func goBack()
    func goHome()
}

class BaseViewController: UIViewController {
    
    weak var baseDelegate: BaseViewControllerDelegate?
    
    let kNavigationItemInitialSpace:CGFloat = -7.0
    let kNavigationItemSpace:CGFloat = 26.0
    
    let kNavigationItemHeight: CGFloat = 22.0
    let kNavigationItemWidth: CGFloat = 22.0
    let kNavigationItemSpaceRatio: CGFloat = 5.0
    
    var navigationLeftButtons = [UIBarButtonItem]()
    var navigationRightButtons = [UIBarButtonItem]()
    
    var screenTitle: String {
        get {
            return "GodTools"
        }
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view didload: \(type(of: self))")
        
        displayNavigationButtons()
        
        addAccessibilityIdentifiers()
        
        navigationController?.navigationBar.barStyle = .black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.displayScreenTitle()
        sendScreenViewNotification(screenName: screenName(), siteSection: siteSection(), siteSubSection: siteSubSection())
    }
    
    // MARK: - Navigation Bar
    
    func displayScreenTitle() {
        self.navigationItem.title = self.screenTitle
    }
    
    func hideScreenTitle() {
        self.navigationItem.titleView = UILabel()
    }
    
    private func displayNavigationButtons() {
        configureNavigationButtons()
        displayNavigationLeftButtons()
        displayNavigationRightButtons()
    }
    
    func displayNavigationLeftButtons() {
        addConstraintsToNavigationButtons(navigationLeftButtons)
        self.navigationItem.setLeftBarButtonItems(navigationLeftButtons.reversed(), animated: true)
        navigationController?.navigationBar.topItem?.title = ""
    }
    
    func displayNavigationRightButtons() {
        // Set 26px of fixed space between the two UIBarButtonItems
        let fixedSpace:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
        fixedSpace.width = self.kNavigationItemSpace/kNavigationItemSpaceRatio
        
        // Set -7px of fixed space before the two UIBarButtonItems so that they are aligned to the edge
        let negativeSpace:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
        negativeSpace.width = self.kNavigationItemInitialSpace
        
        var rightButtons = [UIBarButtonItem]()
        for buttonItem: UIBarButtonItem in self.navigationRightButtons {
            if rightButtons.isEmpty {
                rightButtons.append(negativeSpace)
            } else {
                rightButtons.append(fixedSpace)
            }
            rightButtons.append(buttonItem)
        }
        
        addConstraintsToNavigationButtons(rightButtons)

        self.navigationItem.setRightBarButtonItems(rightButtons.reversed(), animated: true)
    }
    
    func configureNavigationButtons() {
        
    }
    
    func addEmptyLeftButton() {
        let button = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.done, target: nil, action: nil)
        self.navigationLeftButtons.append(button)
    }
    
    func addHomeButton() {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "home"), style: UIBarButtonItem.Style.done, target: self, action: #selector(homeButtonAction))
        self.navigationLeftButtons.append(button)
    }
    
    func addShareButton() {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "share"), style: UIBarButtonItem.Style.done, target: self, action: #selector(shareButtonAction))
        self.navigationRightButtons.append(button)
    }
    
    func addDoneButton() {
        let button = UIBarButtonItem(title: "done".localized, style: UIBarButtonItem.Style.done, target: self, action: #selector(doneButtonAction))
        self.navigationRightButtons.append(button)
    }
    
    func buildNavigationButton(imageName: String, action: Selector) -> UIBarButtonItem {
        let buttonFrame = CGRect(x: 0.0, y: 0.0, width: kNavigationItemWidth, height: kNavigationItemHeight)
        let button: UIButton = UIButton(frame: buttonFrame)
        button.setBackgroundImage(UIImage(named: imageName), for: UIControl.State.normal)
        button.addTarget(self, action: action, for: UIControl.Event.touchUpInside)
        
        return UIBarButtonItem(customView: button)
    }

    private func addConstraintsToNavigationButtons(_ buttonItems: [UIBarButtonItem]) {
        for buttonItem in buttonItems {
            guard let button = buttonItem.customView else {
                continue
            }

            button.addConstraint(NSLayoutConstraint(item: button,attribute: .height, relatedBy: .equal, toItem: nil,
                                                    attribute: .notAnAttribute,multiplier: 1.0, constant: kNavigationItemHeight))
            
            button.addConstraint(NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: nil,
                                                    attribute: .notAnAttribute, multiplier: 1.0, constant: kNavigationItemWidth))
        }
    }
    // MARK: - Navigation Buttons Actions
    
    @objc func homeButtonAction() {
        baseDelegate?.goHome()
    }
    
    @objc func shareButtonAction() {
    }
    
    @objc func doneButtonAction() {
        NotificationCenter.default.post(name: .dismissMenuNotification, object: nil)
    }
    
    @objc func clearButtonAction() {
        
    }
    
    // MARK: - Accessibility ID SetupAccessibility
    
    func addAccessibilityIdentifiers() {
        
    }
    
    // MARK: - Helpers
    
    func hideNetworkActivityIndicator() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func showAlertControllerWith(message: String?) {
        let alert = UIAlertController(title: "download_error".localized,
                                      message: message,
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: "dismiss".localized, style: .default) { (action) in
            alert.presentingViewController?.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func determineMyToolsSegment() -> String {
        let myTools = "my_tools".localized
        return myTools
    }
    
    func determineFindToolsSegment() -> String {
        let findTools = "find_tools".localized
        return findTools
    }
    
    func determineSegmentFontSize(myTools: String, findTools: String) -> CGFloat {
        let count = (myTools.count > findTools.count) ? myTools.count : findTools.count
        var fontSize: CGFloat = 15.0
        if count > 14 {
            switch count {
            case 15:
                fontSize = 14.0
            case 16:
                fontSize = 13.5
            case 17:
                fontSize = 13.0
            case 18:
                fontSize = 12.5
            default:
                fontSize = 12.0
            }
        }
        
        return fontSize
    }

    // MARK: - Analytics Helpers
    
    func sendScreenViewNotification(screenName: String, siteSection: String, siteSubSection: String) {
        let relay = AnalyticsRelay.shared
        relay.screenName = screenName
        
        let userInfo = [GTConstants.kAnalyticsScreenNameKey: screenName, AdobeAnalyticsProperties.CodingKeys.siteSection.rawValue: siteSection, AdobeAnalyticsProperties.CodingKeys.siteSubSection.rawValue: siteSubSection]
        NotificationCenter.default.post(name: .screenViewNotification,
                                        object: nil,
                                        userInfo: userInfo)
    }
    
    func screenName() -> String {
        
        return "unknown screenName"
    }
    
    func siteSection() -> String {
        
        return ""
    }
    
    func siteSubSection() -> String {
        
        return ""
    }

}
