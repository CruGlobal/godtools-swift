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
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = languagesManager
            tableView.dataSource = languagesManager
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        languagesManager.loadFromRemote().always {
            self.tableView.reloadData()
        }
    }
}
