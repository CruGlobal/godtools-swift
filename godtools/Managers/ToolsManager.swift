//
//  ToolsManager.swift
//  godtools
//
//  Created by Devserker on 4/21/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

@objc protocol ToolsManagerDelegate {
    @objc optional func didSelectTableViewRow(cell: HomeToolTableViewCell)
    func infoButtonWasPressed(resource: DownloadedResource)
}

class ToolsManager: GTDataManager {
    
    static let shared = ToolsManager()
    
    var resources: [DownloadedResource]?
    
    var delegate: ToolsManagerDelegate? {
        didSet {
            if self.delegate is HomeViewController {
                resources = DownloadedResourceManager.shared.loadFromDisk().filter( { $0.shouldDownload } )
            } else {
                resources = DownloadedResourceManager.shared.loadFromDisk().filter( { !$0.shouldDownload } )
            }
        }
    }
}

extension ToolsManager: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 113.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! HomeToolTableViewCell
        
        self.delegate?.didSelectTableViewRow!(cell: cell)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerViewFrame = CGRect(x: 0.0, y: 0.0, width: tableView.bounds.size.width, height: 15.0)
        let headerView = UIView(frame: headerViewFrame)
        headerView.backgroundColor = .clear
        return headerView
    }
}

extension ToolsManager: UITableViewDataSource {
    
    static let toolCellIdentifier = "toolCell"
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ToolsManager.toolCellIdentifier) as! HomeToolTableViewCell
        let resource = self.resources![indexPath.section]
        
        cell.cellDelegate = self
        cell.setLanguage(LanguagesManager.shared.loadPrimaryLanguageFromDisk()?.localizedName())
        cell.resource = resource
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.resources!.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}

extension ToolsManager: HomeToolTableViewCellDelegate {
    func downloadButtonWasPressed(resource: DownloadedResource) {
        resource.shouldDownload = true
        saveToDisk()
    }
    
    func infoButtonWasPressed(resource: DownloadedResource) {
        self.delegate?.infoButtonWasPressed(resource: resource)
    }
}
