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
    
    let toolsManager = ToolsManager.shared
    
    @IBOutlet weak var emptyStateView: UIView!
    @IBOutlet weak var normalStateView: UIView!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = toolsManager
            tableView.dataSource = toolsManager
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.displayWorkingView()
        self.registerCells()
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
    
    override func navigationBurgerButtonAction() {
    }
    
    override func navigationPlusButtonAction() {
        self.delegate?.moveToAddNewTool()
    }
    
    override func navigationLanguageButtonAction() {
        self.delegate?.moveToUpdateLanguageSettings()
    }
    
    // MARK: - Helpers
    
    fileprivate func displayWorkingView() {
        self.emptyStateView.isHidden = true
    }
    
    fileprivate func registerCells() {
        self.tableView .register(
            HomeToolTableViewCell.classForKeyedArchiver(), forCellReuseIdentifier: ToolsManager.toolCellIdentifier)
    }
}
