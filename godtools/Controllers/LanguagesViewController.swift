//
//  LanguagesViewController.swift
//  godtools
//
//  Created by Ryan Carlson on 4/18/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

class LanguagesViewController: UIViewController {
    
    let languagesManager = LanguagesManager.shared
    let resourcesManager = DownloadedResourceManager.shared
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = languagesManager
            tableView.dataSource = languagesManager
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        languagesManager.loadFromDisk().catch(execute: { error in
            self.showAlertControllerWith(message: error.localizedDescription)
        }).always {
            self.tableView.reloadData()
        }
        
        languagesManager.loadFromRemote().catch(execute: { error in
            self.showAlertControllerWith(message: error.localizedDescription)
        }).always {
            self.tableView.reloadData()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        
        _ = resourcesManager.loadFromRemote()
    }
    
    @IBAction func backButtonWasPressed(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func showAlertControllerWith(message: String?) {
        let alert = UIAlertController(title: "Error loading languages", message: message, preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
    }
}
