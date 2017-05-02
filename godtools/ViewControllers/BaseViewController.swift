//
//  GTBaseViewController.swift
//  godtools
//
//  Created by Devserker on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

protocol BaseViewControllerDelegate {
    mutating func goBack();
}

class BaseViewController: UIViewController {
    
    var baseDelegate: BaseViewControllerDelegate?
    
    let kNavigationItemInitialSpace:CGFloat = -7.0
    let kNavigationItemSpace:CGFloat = 26.0
    
    var navigationLeftButtons = [UIBarButtonItem]()
    var navigationRightButtons = [UIBarButtonItem]()
    
    var screenTitle: String {
        get {
            return "GodTools"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.displayNavigationButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.displayScreenTitle()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Navigation Bar
    
    func displayScreenTitle() {
        self.navigationItem.title = self.screenTitle
    }
    
    func hideScreenTitle() {
        self.navigationItem.titleView = UILabel()
    }
    
    func displayNavigationButtons() {
        self.configureNavigationButtons()
        self.displayNavigationLeftButtons()
        self.displayNavigationRightButtons()
    }
    
    func displayNavigationLeftButtons() {
        self.navigationItem.setLeftBarButtonItems(self.navigationLeftButtons.reversed(), animated: true)
        navigationController?.navigationBar.topItem?.title = ""
    }
    
    func displayNavigationRightButtons() {
        // Set 26px of fixed space between the two UIBarButtonItems
        let fixedSpace:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        fixedSpace.width = self.kNavigationItemSpace
        
        // Set -7px of fixed space before the two UIBarButtonItems so that they are aligned to the edge
        let negativeSpace:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
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
        
        self.navigationItem.setRightBarButtonItems(rightButtons.reversed(), animated: true)
    }
    
    func configureNavigationButtons() {
    }
    
    func addEmptyLeftButton() {
        let button = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.done, target: nil, action: nil)
        self.navigationLeftButtons.append(button)
    }
    
    func addNavigationBurgerButton() {
        let button = self.buildNavigationButton(imageName: "burger_white", action: #selector(navigationBurgerButtonAction))
        self.navigationLeftButtons.append(button)
    }
    
    func addNavigationPlusButton() {
        let button = self.buildNavigationButton(imageName: "plus_white", action: #selector(navigationPlusButtonAction))
        self.navigationRightButtons.append(button)
    }
    
    func addNavigationLanguageButton() {
        let button = self.buildNavigationButton(imageName: "language_logo_white", action: #selector(navigationLanguageButtonAction))
        self.navigationRightButtons.append(button)
    }
    
    func addHomeButton() {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "home"), style: UIBarButtonItemStyle.done, target: self, action: #selector(homeButtonAction))
        self.navigationLeftButtons.append(button)
    }
    
    func addShareButton() {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "share"), style: UIBarButtonItemStyle.done, target: self, action: #selector(shareButtonAction))
        self.navigationRightButtons.append(button)
    }
    
    func addDoneButton() {
        let button = UIBarButtonItem(title: "done".localized, style: UIBarButtonItemStyle.done, target: self, action: #selector(doneButtonAction))
        self.navigationRightButtons.append(button)
    }
    
    func buildNavigationButton(imageName: String, action: Selector) -> UIBarButtonItem {
        let buttonFrame = CGRect(x: 0.0, y: 0.0, width: 22.0, height: 22.0)
        let button: UIButton = UIButton(frame: buttonFrame)
        button.setBackgroundImage(UIImage(named: imageName), for: UIControlState.normal)
        button.addTarget(self, action: action, for: UIControlEvents.touchUpInside)
        return UIBarButtonItem(customView: button)
    }
    
    // MARK: - Navigation Buttons Actions
    
    func navigationBurgerButtonAction() {
        NotificationCenter.default.post(name: .displayMenuNotification, object: nil)
    }
    
    func navigationPlusButtonAction() {
    }
    
    func navigationLanguageButtonAction() {
    }
    
    func homeButtonAction() {
    }
    
    func shareButtonAction() {
    }
    
    func doneButtonAction() {
        NotificationCenter.default.post(name: .dismissMenuNotification, object: nil)
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

}
