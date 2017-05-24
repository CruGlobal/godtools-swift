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
    @objc optional func primaryTranslationDownloadCompleted(at index: Int)
}

class ToolsManager: GTDataManager {
    
    static let shared = ToolsManager()
    
    var resources: [DownloadedResource]?
    
    weak var delegate: ToolsManagerDelegate? {
        didSet {
            if self.delegate is HomeViewController {
                resources = DownloadedResourceManager.shared.loadFromDisk().filter( { $0.shouldDownload } )
                    .sorted(by: { $0.name! < $1.name! })
                deregisterDownloadCompletedObserver()
            } else {
                resources = DownloadedResourceManager.shared.loadFromDisk().filter( { !$0.shouldDownload } )
                    .sorted(by: { $0.name! < $1.name! })
                registerDownloadCompletedObserver()
            }
        }
    }
    
    func hasResources() -> Bool {
        return resources != nil && resources!.count > 0
    }
    
    func download(resource: DownloadedResource) {
        resource.shouldDownload = true
        saveToDisk()
        TranslationZipImporter.shared.download(resource: resource)
        
    }
    
    func delete(resource: DownloadedResource) {
        resource.shouldDownload = false
        for translation in resource.translationsAsArray() {
            translation.isDownloaded = false            
            translation.removeFromReferencedFiles(translation.referencedFiles!)
        }
        
        TranslationFileRemover().deleteUnusedPages()
        
        saveToDisk()
    }
}

// MARK - Download Notification listening methods
extension ToolsManager {
    fileprivate func registerDownloadCompletedObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(downloadCompletedObserver),
                                               name: .downloadPrimaryTranslationCompleteNotification,
                                               object: nil)
    }
    
    @objc fileprivate func downloadCompletedObserver(notifcation: NSNotification) {
        guard let resourceId = notifcation.userInfo?[GTConstants.kDownloadProgressResourceIdKey] as? String else {
            return
        }
        
        guard let resource = resources!.filter({ $0.remoteId == resourceId }).first else {
            return
        }
        
        guard let index = resources!.index(of: resource) else {
            return
        }
        
        delegate!.primaryTranslationDownloadCompleted!(at: index)
    }
    
    fileprivate func deregisterDownloadCompletedObserver() {
        NotificationCenter.default.removeObserver(self,
                                                  name: .downloadPrimaryTranslationCompleteNotification,
                                                  object: nil)
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
        
        cell.configure(resource: resource,
                       primaryLanguage: LanguagesManager.shared.loadPrimaryLanguageFromDisk(),
                       parallelLanguage: LanguagesManager.shared.loadParallelLanguageFromDisk(),
                       banner: BannerManager.shared.loadFor(resource),
                       delegate: self)
                
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
        self.delegate?.downloadButtonWasPressed!(resource: resource)
    }
    
    func infoButtonWasPressed(resource: DownloadedResource) {
        self.delegate?.infoButtonWasPressed(resource: resource)
    }
}
