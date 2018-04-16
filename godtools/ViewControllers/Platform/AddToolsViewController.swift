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
    mutating func moveToUpdateLanguageSettings()
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
        self.toolsManager.loadResourceList()
        self.tableView.reloadData()
    }
    
    override func configureNavigationButtons() {
        self.addNavigationLanguageButton()
    }
    
    // MARK: - Helpers
    
    fileprivate func registerCells() {
        self.tableView.register(UINib(nibName: String(describing:HomeToolTableViewCell.self), bundle: nil), forCellReuseIdentifier: ToolsManager.toolCellIdentifier)
    }
    
    fileprivate func setupStyle() {
        self.tableView.separatorStyle = .none
    }
    
    // MARK: - Analytics
    
    override func screenName() -> String {
        let relay = AnalyticsRelay.shared
        relay.siteSection = relay.convertScreenNameToSiteSection(screenName: "Find Tools")
        return "Find Tools"
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
    
    func primaryTranslationDownloadCompleted(at index: Int) {
        self.tableView.beginUpdates()
        ToolsManager.shared.resources.remove(at: index)
        self.tableView.deleteSections(IndexSet(integer: index), with: .fade)
        self.tableView.endUpdates()
    }
}
