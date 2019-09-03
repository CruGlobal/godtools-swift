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
    var emptyView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerCells()
        self.setupStyle()
        emptyView = addMessageForEmptyResources()
        self.view.addSubview(emptyView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.toolsManager.delegate = self
        self.toolsManager.loadResourceList()
        refreshView()
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
    
    func refreshView() {
        self.tableView.reloadData()
        self.emptyView.isHidden = self.toolsManager.hasResources()
        self.view.setNeedsDisplay()
    }
    
    func addMessageForEmptyResources() -> UIView {
        let messageLabel = UILabel()
        let emptyBaseView = UIView()
        
        messageLabel.numberOfLines = 3
        messageLabel.font = UIFont.gtRegular(size: 16)
        messageLabel.textColor = UIColor.gtBlack
        messageLabel.layer.masksToBounds = true
        let screenSize = UIScreen.main.bounds
        let topBarHeight = UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
        let centerX = screenSize.width/2
        let centerY = screenSize.height/2
        messageLabel.textAlignment = .center
        messageLabel.lineBreakMode = .byWordWrapping

        let labelWidth: CGFloat = 250.0
        let labelHeight: CGFloat = 90.0
        let x = (centerX - (labelWidth/2))
        let y = (centerY - (labelHeight/2))
        emptyBaseView.frame = CGRect(x: x, y: y - topBarHeight, width: labelWidth, height: labelHeight)
        messageLabel.frame = CGRect(x: 0, y: 0, width: labelWidth, height: labelHeight)
        
        messageLabel.text = "You have downloaded all available tools.".localized
        emptyBaseView.addSubview(messageLabel)
        
        return emptyBaseView
    }
    
    // MARK: - Analytics
    
    override func screenName() -> String {
        return "Find Tools"
    }
    
    override func siteSection() -> String {
        return "tools"
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
        refreshView()
    }
    
    func translationDownloadCompleted(at index: Int, isPrimary: Bool) {
        // Tool should only be removed if the primary language is being downloaded
        guard isPrimary else {
            return
        }
        
        ToolsManager.shared.resources.remove(at: index)
        DispatchQueue.main.async {
            self.tableView.deleteSections(IndexSet(integer: index), with: .fade)
            self.refreshView()
        }
    }
}
