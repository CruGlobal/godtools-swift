//
//  ResourcesViewController.swift
//  godtools
//
//  Created by Ryan Carlson on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

class ResourcesViewController: UIViewController {
    
    let resourcesManager = DownloadedResourceManager.shared
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = resourcesManager
        tableView.dataSource = resourcesManager
        
        resourcesManager.loadFromDisk().then { (resources) -> Void in
            self.tableView.reloadData()
            }.always {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    @IBAction func backButtonWasPressed(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}
