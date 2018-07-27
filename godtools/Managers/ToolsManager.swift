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
import RealmSwift

@objc protocol ToolsManagerDelegate {
    @objc optional func didSelectTableViewRow(cell: HomeToolTableViewCell)
    func infoButtonWasPressed(resource: DownloadedResource)
    @objc optional func downloadButtonWasPressed(resource: DownloadedResource)
    @objc optional func primaryTranslationDownloadCompleted(at index: Int)
}

class ToolsManager: GTDataManager {
    
    static let shared = ToolsManager()
    
    private override init() {
        super.init()
        syncCachedRecordViews()
        registerDownloadCompletedObserver()
    }
    
    let viewsPath = "views"
    var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    let kRowHeightRatio: CGFloat = 4.167
    let kHeaderHeightRatio: CGFloat = 38.33
    
    var resources = DownloadedResources()
    
    weak var delegate: ToolsManagerDelegate?
    
    func hasResources() -> Bool {
        return resources.count > 0
    }
    
    func loadResourceList() {
        var predicate: NSPredicate
        if self.delegate is HomeViewController {
            predicate = NSPredicate(format: "shouldDownload = true")
        } else {
            predicate = NSPredicate(format: "shouldDownload = false")
        }
        
        resources = findEntities(DownloadedResource.self, matching: predicate)
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
        
        guard let resource = resources.filter({ $0.remoteId == resourceId }).first else {
            return
        }
        
        guard let index = resources.index(of: resource) else {
            return
        }
        
        delegate!.primaryTranslationDownloadCompleted?(at: index)
    }
}

extension ToolsManager: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       // return height/ratio
        return screenHeight/kRowHeightRatio
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let resource = resources[indexPath.section]
//        let primaryLanguage = LanguagesManager().loadPrimaryLanguageFromDisk()
//        if resource.localizedName(language: primaryLanguage).count > 25 {
//            return 133.0
//        }
        
        //return 113.0
        return screenHeight/kRowHeightRatio
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //return 15.0
        return screenHeight/kHeaderHeightRatio
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! HomeToolTableViewCell
        
        if self.delegate is AddToolsViewController {
            delegate?.didSelectTableViewRow!(cell: cell)
            return
        }
        
        recordViewed(cell.resource!)
        delegate?.didSelectTableViewRow!(cell: cell)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerViewFrame = CGRect(x: 0.0, y: 0.0, width: tableView.bounds.size.width, height: screenHeight/kHeaderHeightRatio) // 15.0 old value
        let headerView = UIView(frame: headerViewFrame)
        headerView.backgroundColor = .clear
        return headerView
    }
}

extension ToolsManager: UITableViewDataSource {
    
    static let toolCellIdentifier = "toolCell"
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ToolsManager.toolCellIdentifier) as! HomeToolTableViewCell
        if indexPath.section >= resources.count {
            return UITableViewCell()
        }
        
        let resource = resources[indexPath.section]
        let languagesManager = LanguagesManager()
        
        cell.configure(resource: resource,
                       primaryLanguage: languagesManager.loadPrimaryLanguageFromDisk(),
                       parallelLanguage: languagesManager.loadParallelLanguageFromDisk(),
                       banner: BannerManager().loadFor(remoteId: resource.bannerRemoteId),
                       delegate: self)
                
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return resources.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}

extension ToolsManager: HomeToolTableViewCellDelegate {
    func downloadButtonWasPressed(resource: DownloadedResource) {
        DownloadedResourceManager().download(resource)
        delegate?.downloadButtonWasPressed!(resource: resource)
    }
    
    func infoButtonWasPressed(resource: DownloadedResource) {
        delegate?.infoButtonWasPressed(resource: resource)
    }
}
