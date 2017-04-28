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
}

class ToolsManager: NSObject {
    
    static let shared = ToolsManager()
    var delegate: ToolsManagerDelegate? {
        didSet {
            let languageId = GTSettings.shared.primaryLanguageId
            if languageId == nil {
                return
            }
            
            if self.delegate is HomeViewController {
                downloadedTranslations = TranslationsManager.shared.loadDownloadedTranslationsFromDisk(languageId: languageId!)
            } else {
                latestTranslations = TranslationsManager.shared.loadLatestTranslationsFromDisk(languageId: languageId!)
            }
        }
    }
    
    var latestTranslations: [Translation]?
    var downloadedTranslations: [Translation]?
    
    override init() {
        super.init()
    }
    
    fileprivate func getShownTranslations() -> [Translation] {
        if self.delegate is HomeViewController {
            return downloadedTranslations!
        } else {
            return latestTranslations!
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
        cell.titleLabel.text = getShownTranslations()[indexPath.section].downloadedResource!.name
        cell.languageLabel.text = LanguagesManager.shared.loadPrimaryLanguageFromDisk()!.localizedName
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let languageId = GTSettings.shared.primaryLanguageId
        
        if languageId == nil {
            return 0
        }
        
        return getShownTranslations().count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
}
