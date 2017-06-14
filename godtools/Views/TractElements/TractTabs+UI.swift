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
        let width = self.elementFrame.width
        let height: CGFloat = 28.0
        let frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        
        self.segmentedControl = UISegmentedControl(frame: frame)
        for i in 0..<self.properties.options.count {
            self.segmentedControl.insertSegment(withTitle: self.properties.options[i], at: i, animated: true)
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
        self.elements![self.segmentedControl.selectedSegmentIndex].isHidden = false
    }
    
}
