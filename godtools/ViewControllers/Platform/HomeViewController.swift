//
//  HomeViewController.swift
//  godtools
//
//  Created by Devserker on 4/20/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

protocol HomeViewControllerDelegate {
    mutating func moveToUpdateLanguageSettings()
    mutating func moveToAddNewTool()
}

class HomeViewController: BaseViewController {
    
    var delegate: HomeViewControllerDelegate?
    
    @IBOutlet weak var emptyStateView: UIView!
    @IBOutlet weak var normalStateView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.displayWorkingView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Actions
    
    @IBAction func pressAddNewToolsButton(_ sender: Any) {
        self.delegate?.moveToAddNewTool()
    }
    
    // MARK: - Navigation Buttons
    
    override func configureNavigationButtons() {
        self.addNavigationBurgerButton()
        self.addNavigationPlusButton()
        self.addNavigationLanguageButton()
    }
    
    override func navigationPlusButtonAction() {
        self.delegate?.moveToAddNewTool()
    }
    
    override func navigationLanguageButtonAction() {
        self.delegate?.moveToUpdateLanguageSettings()
    }
    
    // MARK: - Helpers
    
    fileprivate func displayWorkingView() {
        self.normalStateView.isHidden = true
    }
}
