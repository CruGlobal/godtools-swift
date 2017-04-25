//
//  TractViewController.swift
//  godtools
//
//  Created by Ryan Carlson on 4/24/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

class TractViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayNavigationButtons()
        displayTitle()
    }
    
    fileprivate func displayNavigationButtons() {
        navigationItem.rightBarButtonItem = createShareButton()
        navigationItem.leftBarButtonItem = createHomeButton()
    }

    fileprivate func displayTitle() {
        navigationItem.titleView = UISegmentedControl(items: ["English", "French"])
    }
    
    fileprivate func createHomeButton() -> UIBarButtonItem {
        return UIBarButtonItem(image: #imageLiteral(resourceName: "home"), style: UIBarButtonItemStyle.done, target: self, action: #selector(backButtonWasPressed))
    }
    
    fileprivate func createShareButton() -> UIBarButtonItem {
        return UIBarButtonItem(image: #imageLiteral(resourceName: "share"), style: .done, target: self, action: #selector(shareButtonWasPressed))
    }
    
    func backButtonWasPressed() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func shareButtonWasPressed() {
        let activityController = UIActivityViewController(activityItems: [String.localizedStringWithFormat("tract_share_message".localized, "www.knowgod.com")], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
}
