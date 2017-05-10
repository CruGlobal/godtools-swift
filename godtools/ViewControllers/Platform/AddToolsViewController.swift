//
//  AddToolsViewController.swift
//  godtools
//
//  Created by Devserker on 4/21/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

protocol AddToolsViewControllerDelegate {
    mutating func moveToToolDetail(resource: DownloadedResource)
}

class AddToolsViewController: BaseViewController {
    
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
        self.tableView.reloadData()
    }

    override func displayScreenTitle() {
        self.navigationItem.title = "Add Tools".localized
    }
    
    // MARK: - Helpers
    
    fileprivate func registerCells() {
        self.tableView.register(UINib(nibName: String(describing:HomeToolTableViewCell.self), bundle: nil), forCellReuseIdentifier: ToolsManager.toolCellIdentifier)
    }
    
    fileprivate func setupStyle() {
        self.tableView.separatorStyle = .none
    }
    
}

extension AddToolsViewController: ToolsManagerDelegate {
    func didSelectTableViewRow(cell: HomeToolTableViewCell) {
        self.delegate?.moveToToolDetail(resource: cell.resource!)
    }
    
    func infoButtonWasPressed(resource: DownloadedResource) {
        self.delegate?.moveToToolDetail(resource: resource)
    }
    
    func downloadButtonWasPressed(resource: DownloadedResource) {
        self.tableView.reloadData()
    }
}
