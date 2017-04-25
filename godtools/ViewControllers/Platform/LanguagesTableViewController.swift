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
        self.loadFromRemote()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Load data
    
    func loadFromDisk() {
        languagesManager.loadFromDisk().catch(execute: { error in
            self.showAlertControllerWith(message: error.localizedDescription)
        }).always {
            self.reloadTableView()
        }
    }
    
    func loadFromRemote() {
        languagesManager.loadFromRemote().catch(execute: { error in
            self.showAlertControllerWith(message: "language_download_error".localized)
        }).always {
            self.reloadTableView()
            self.hideNetworkActivityIndicator()
        }
    }
    
    // MARK: - Helpers
    
    fileprivate func registerCells() {
        self.tableView .register(
            LanguageTableViewCell.classForKeyedArchiver(), forCellReuseIdentifier: LanguagesManager.languageCellIdentifier)
    }
    
    fileprivate func reloadTableView() {
        self.tableView.reloadData()
    }
    
}
