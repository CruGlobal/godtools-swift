//
//  AddToolsViewController.swift
//  godtools
//
//  Created by Devserker on 4/21/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

protocol AddToolsViewControllerDelegate {
}

class AddToolsViewController: BaseViewController, ToolsManagerDelegate {
    
    var delegate: AddToolsViewControllerDelegate?
    
    let toolsManager = ToolsManager.shared
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = toolsManager
            tableView.dataSource = toolsManager
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerCells()
        self.setupStyle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.toolsManager.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Helpers
    
    fileprivate func registerCells() {
        self.tableView.register(UINib(nibName: "HomeToolTableViewCell", bundle: nil), forCellReuseIdentifier: ToolsManager.toolCellIdentifier)
    }
    
    fileprivate func setupStyle() {
        self.tableView.separatorStyle = .none
    }
    
    // MARK: - ToolsManagerDelegate
    
    func didSelectTableViewRow(cell: HomeToolTableViewCell) {
    }

}
