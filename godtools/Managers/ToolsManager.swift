//
//  ToolsManager.swift
//  godtools
//
//  Created by Devserker on 4/21/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit
import PromiseKit

@objc protocol ToolsManagerDelegate {
    @objc optional func didSelectTableViewRow(cell: HomeToolTableViewCell)
    func infoButtonWasPressed(resource: DownloadedResource)
    @objc optional func downloadButtonWasPressed(resource: DownloadedResource)
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
    
    func download(resource: DownloadedResource) -> AnyPromise {
        resource.shouldDownload = true
        saveToDisk()
        
        return AnyPromise(Promise(value: "ok"))
    }
    
    func delete(resource: DownloadedResource) -> AnyPromise {
        resource.shouldDownload = false
        saveToDisk()
        
        return AnyPromise(Promise(value: "ok"))
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
        
        if cell.isAvailable || self.delegate is AddToolsViewController {
            self.delegate?.didSelectTableViewRow!(cell: cell)
        }
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
        cell.resource = resource
        cell.configure(primaryLanguage: LanguagesManager.shared.loadPrimaryLanguageFromDisk()!)
        cell.selectionStyle = .none
        
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
        self.download(resource: resource)
            .always {
                self.delegate?.downloadButtonWasPressed!(resource: resource)
            }.catch { (error) in
                //TODO throw an notification to report an error
        }
        
    }
    
    func infoButtonWasPressed(resource: DownloadedResource) {
        self.delegate?.infoButtonWasPressed(resource: resource)
    }
}
