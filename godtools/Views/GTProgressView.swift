//
//  GTProgressView.swift
//  godtools
//
//  Created by Ryan Carlson on 5/11/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

class GTProgressView: UIProgressView {
    override func layoutSubviews() {
        super.layoutSubviews()
        progressTintColor = .gtBlue
        trackTintColor = .clear
    }
}
