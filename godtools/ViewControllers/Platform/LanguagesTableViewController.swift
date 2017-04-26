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
    
    var screenTitleAux: String?
    override var screenTitle: String {
        get {
            return screenTitleAux!.localized
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
        self.loadFromRemote()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Load data
    
    func loadFromDisk() {
        languagesManager.loadFromDisk().always {
            self.reloadTableView()
        }
    }
    
    func loadFromRemote() {
        languagesManager.loadFromRemote().catch(execute: { error in
            if self.languagesManager.languages.count == 0 {
                self.showAlertControllerWith(message: "language_download_error".localized)
            }
        }).always {
            self.reloadTableView()
            self.hideNetworkActivityIndicator()
        }
    }
    
    // MARK: - Helpers
    
    func primaryLanguage(primary:Bool) {
        if primary {
            self.screenTitleAux = "primary_language"
        }
        else {
            self.screenTitleAux = "parallel_language"
        }
    }
    
    fileprivate func registerCells() {
        self.tableView.register(UINib(nibName: "LanguageTableViewCell", bundle: nil), forCellReuseIdentifier: LanguagesManager.languageCellIdentifier)
    }
    
    fileprivate func reloadTableView() {
        self.tableView.reloadData()
    }
    
}
