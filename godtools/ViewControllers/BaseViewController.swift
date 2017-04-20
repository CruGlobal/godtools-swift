//
//  GTBaseViewController.swift
//  godtools
//
//  Created by Devserker on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    var navigationLeftButtons = [UIBarButtonItem]()
    var navigationRightButtons = [UIBarButtonItem]()
    
    var screenTitle: String {
        get {
            return "GodTools"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.displayScreenTitle()
        self.displayNavigationButtons()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Navigation Bar
    
    func displayScreenTitle() {
        self.navigationItem.title = self.screenTitle
    }
    
    func displayNavigationButtons() {
        self.configureNavigationButtons()
        self.navigationItem.setLeftBarButtonItems(self.navigationLeftButtons.reversed(), animated: true)
        self.navigationItem.setRightBarButtonItems(self.navigationRightButtons.reversed(), animated: true)
        navigationController?.navigationBar.topItem?.title = ""
    }
    
    func configureNavigationButtons() {
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
    
    func buildNavigationButton(imageName: String, action: Selector) -> UIBarButtonItem {
        let buttonFrame = CGRect(x: 0.0, y: 0.0, width: 22.0, height: 22.0)
        let button: UIButton = UIButton(frame: buttonFrame)
        button.setBackgroundImage(UIImage(named: imageName), for: UIControlState.normal)
        button.addTarget(self, action: action, for: UIControlEvents.touchUpInside)
        return UIBarButtonItem(customView: button)
    }
    
    // MARK: - Navigation Buttons Actions
    
    func navigationBurgerButtonAction() {
    }
    
    func navigationPlusButtonAction() {
    }
    
    func navigationLanguageButtonAction() {
    }
    
    // MARK: - Helpers
    
    func hideNetworkActivityIndicator() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func showAlertControllerWith(message: String?) {
        let alert = UIAlertController(title: "Error loading languages", message: message, preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
    }

}
