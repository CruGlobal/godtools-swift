//
//  GTLanguagesTableViewController.swift
//  godtools
//
//  Created by Devserker on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

protocol LanguagesTableViewControllerDelegate {
}

class LanguagesTableViewController: BaseViewController {
    
    var delegate: LanguagesTableViewControllerDelegate?
    
    let languagesManager = LanguagesManager.shared
    
    var screenTitleAux: String = "primary_language"
    override var screenTitle: String {
        get {
            return screenTitleAux.localized
        }
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = languagesManager
            tableView.dataSource = languagesManager
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerCells()
        
        self.loadFromDisk()
    }
    
    // MARK: - Load data
    
    func loadFromDisk() {
        _ = languagesManager.loadFromDisk()

        self.tableView.reloadData()
    }
    
    // MARK: - Helpers
    
    func selectingPrimaryLanguage(_ primary:Bool) {
        if primary {
            self.screenTitleAux = "primary_language"
        } else {
            self.screenTitleAux = "parallel_language"
        }
    }
    
    fileprivate func registerCells() {
        self.tableView.register(UINib(nibName: "LanguageTableViewCell", bundle: nil), forCellReuseIdentifier: LanguagesManager.languageCellIdentifier)
    }
}
