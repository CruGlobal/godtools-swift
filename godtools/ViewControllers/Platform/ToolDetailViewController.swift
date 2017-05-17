//
//  ToolDetailViewController.swift
//  godtools
//
//  Created by Devserker on 4/21/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class ToolDetailViewController: BaseViewController {
    
    @IBOutlet weak var titleLabel: GTLabel!
    @IBOutlet weak var totalViewsLabel: GTLabel!
    @IBOutlet weak var descriptionLabel: GTLabel!
    @IBOutlet weak var totalLanguagesLabel: GTLabel!
    @IBOutlet weak var languagesLabel: GTLabel!
    @IBOutlet weak var mainButton: GTButton!
    
    let toolsManager = ToolsManager.shared
    
    var resource: DownloadedResource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.displayData()
        self.hideScreenTitle()
    }

    // MARK: Present data
    
    fileprivate func displayData() {
        self.totalViewsLabel.text = String.localizedStringWithFormat("total_views".localized, "5,000,000")
        self.totalLanguagesLabel.text = String.localizedStringWithFormat("total_languages".localized, "40")
        self.titleLabel.text = resource?.name

        self.languagesLabel.text = Array(resource!.translations!)
            .map({ "\(($0 as! Translation).language!.localizedName())"})
            .sorted(by: { $0 < $1 })
            .joined(separator: ", ")
        
        self.displayButton()
    }
    
    fileprivate func displayButton() {
        if resource!.shouldDownload {
            mainButton.designAsDeleteButton()
        } else {
            mainButton.designAsDownloadButton()
        }
    }
    
    @IBAction func mainButtonWasPressed(_ sender: Any) {
        if resource!.shouldDownload {
            toolsManager.delete(resource: self.resource!)
            self.displayButton()
        } else {
            toolsManager.download(resource: self.resource!)
            self.displayButton()
        }
    }

}
