//
//  GTBaseViewController.swift
//  godtools
//
//  Created by Devserker on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

import PureLayout

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
        fixedSpace.width = 26.0
        
        // Set -7px of fixed space before the two UIBarButtonItems so that they are aligned to the edge
        let negativeSpace:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        negativeSpace.width = -7.0
        
        var rightButtons = [UIBarButtonItem]()
        for buttonItem: UIBarButtonItem in self.navigationRightButtons {
            if rightButtons.isEmpty {
                rightButtons.append(negativeSpace)
            }
            else {
                rightButtons.append(fixedSpace)
            }
            rightButtons.append(buttonItem)
        }
        
        self.navigationItem.setRightBarButtonItems(rightButtons.reversed(), animated: true)
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
