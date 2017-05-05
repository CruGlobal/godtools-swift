//
//  TractViewController.swift
//  godtools
//
//  Created by Ryan Carlson on 4/24/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

class TractViewController: BaseViewController {
    
    var resource: DownloadedResource?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.displayTitle()
    }
    override func configureNavigationButtons() {
        self.addHomeButton()
        self.addShareButton()
    }

    fileprivate func displayTitle() {
        if parallelLanguageIsAvailable() {
            self.navigationItem.titleView = languageSegmentedControl()
        } else {
            self.title = currentTractTitle()
        }
    }
    
    override func homeButtonAction() {
        self.baseDelegate?.goBack()
    }
    
    override func shareButtonAction() {
        let activityController = UIActivityViewController(activityItems: [String.localizedStringWithFormat("tract_share_message".localized, "www.knowgod.com")], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
}

// Mark - stub methods to be filled in with real logic later

extension TractViewController {
    fileprivate func parallelLanguageIsAvailable() -> Bool {
        return GTSettings.shared.parallelLanguageId != nil
    }
    
    fileprivate func currentTractTitle() -> String {
        return resource != nil ? resource!.name! : "GodTools"
    }
    
    fileprivate func languageSegmentedControl() -> UISegmentedControl {
        let primaryLabel = self.determinePrimaryLabel()
        let parallelLabel = self.determineParallelLabel()
        
        let control = UISegmentedControl(items: [primaryLabel, parallelLabel])
        control.selectedSegmentIndex = 0
        return control
    }
    
    fileprivate func determinePrimaryLabel() -> String {
        let primaryLanguage = LanguagesManager.shared.loadPrimaryLanguageFromDisk()
        
        if primaryLanguage == nil {
            return Locale.current.localizedString(forLanguageCode: Locale.current.languageCode!)!
        } else {
            return primaryLanguage!.localizedName()
        }
    }
    
    fileprivate func determineParallelLabel() -> String {
        let parallelLanguage = LanguagesManager.shared.loadParallelLanguageFromDisk()
        
        return parallelLanguage!.localizedName()
    }
}
