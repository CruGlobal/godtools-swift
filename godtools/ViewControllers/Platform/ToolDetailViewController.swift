//
//  ToolDetailViewController.swift
//  godtools
//
//  Created by Devserker on 4/21/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

protocol ToolDetailViewControllerDelegate {
}

class ToolDetailViewController: BaseViewController {
    
    var delegate: ToolDetailViewControllerDelegate?

    @IBOutlet weak var titleLabel: GTLabel!
    @IBOutlet weak var totalViewsLabel: GTLabel!
    @IBOutlet weak var descriptionLabel: GTLabel!
    @IBOutlet weak var totalLanguagesLabel: GTLabel!
    @IBOutlet weak var languagesLabel: GTLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.displayData()
    }

    // MARK: Present data
    
    fileprivate func displayData() {
        self.totalViewsLabel.text = String.localizedStringWithFormat("total_views".localized, "5,000,000")
        self.totalLanguagesLabel.text = String.localizedStringWithFormat("total_languages".localized, "40")
    }

}
