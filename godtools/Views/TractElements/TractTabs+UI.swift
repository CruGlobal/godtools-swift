//
//  TractTabs+UI.swift
//  godtools
//
//  Created by Pablo Marti on 6/13/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

extension TractTabs {
    
    func setupSegmentedControl() {
        let properties = tabsProperties()
        properties.analyticsTabsUserInfo = self.analyticsTabsDictionary
        
        let width = self.elementFrame.finalWidth()
        let height: CGFloat = 28.0
        let frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        
        self.segmentedControl = UISegmentedControl(frame: frame)
        for i in 0..<properties.options.count {
            self.segmentedControl.insertSegment(withTitle: properties.options[i], at: i, animated: true)
        }
        
        let originalAttributes = segmentedControl.titleTextAttributes(for: .normal)
        if let originalFont = originalAttributes?[NSFontAttributeName] as? UIFont {
            let font = originalFont.transformToAppropriateFontByLanguage(self.tractConfigurations!.language!, textScale: 1.0)
            self.segmentedControl.setTitleTextAttributes([NSFontAttributeName: font], for: .normal)
        }
        
        self.segmentedControl.selectedSegmentIndex = 0
        self.segmentedControl.tintColor = self.manifestProperties.primaryColor
        self.segmentedControl.addTarget(self, action: #selector(newOptionSelected), for: .valueChanged)
        
        self.addSubview(self.segmentedControl)
    }
    
    func newOptionSelected() {
        for element in self.elements! {
            element.isHidden = true
        }
        let properties = tabsProperties()
        self.elements![self.segmentedControl.selectedSegmentIndex].isHidden = false
        
        if self.segmentedControl.selectedSegmentIndex == 1 {
            NotificationCenter.default.post(name: .actionTrackNotification,
                                            object: nil,
                                            userInfo: properties.analyticsTabsUserInfo)
        }
    }
    
}
