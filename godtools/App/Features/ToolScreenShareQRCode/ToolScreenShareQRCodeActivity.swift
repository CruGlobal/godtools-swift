//
//  ToolScreenShareQRCodeActivity.swift
//  godtools
//
//  Created by Rachael Skeath on 6/25/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import UIKit

class ToolScreenShareQRCodeActivity: UIActivity {
    
    var _activityTitle: String
    var _activityImage: UIImage?
    var activityItems = [Any]()
    var action: ([Any]) -> Void
    
    override var activityTitle: String? {
        return _activityTitle
    }
    
    override var activityImage: UIImage? {
        return _activityImage
    }
    
    override var activityType: UIActivity.ActivityType? {
        return UIActivity.ActivityType(rawValue: "org.cru.godtools.screenShareQRCodeActivity")
    }
    
    override class var activityCategory: UIActivity.Category {
        return .share
    }
    
    init(performAction: @escaping ([Any]) -> Void) {
        
        _activityTitle = "QR Code"
        _activityImage = UIImage(named: "qr_code")
        action = performAction
        
        super.init()
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
    
    override func prepare(withActivityItems activityItems: [Any]) {
        self.activityItems = activityItems
    }
    
    override func perform() {
        action(activityItems)
        activityDidFinish(true)
    }
}
