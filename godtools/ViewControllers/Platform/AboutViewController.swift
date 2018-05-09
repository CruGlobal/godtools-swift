//
//  AboutViewController.swift
//  godtools
//
//  Created by Pablo Marti on 6/5/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class AboutViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var screenTitle: String {
        get {
            return "about".localized
        }
    }
    
    // MARK: - Analytics
    
    override func screenName() -> String {
        return "About"
    }
    
    override func siteSection() -> String {
        return "menu"
    }
    
}
