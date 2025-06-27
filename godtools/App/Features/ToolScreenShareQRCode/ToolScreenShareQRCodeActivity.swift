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
    
    private let title: String
    private let image: UIImage?
    private let action: ([Any]) -> Void
    
    private var activityItems = [Any]()
    
    override var activityTitle: String? {
        return title
    }
    
    override var activityImage: UIImage? {
        return image
    }
    
    override var activityType: UIActivity.ActivityType? {
        return UIActivity.ActivityType(rawValue: "org.cru.godtools.screenShareQRCodeActivity")
    }
    
    override class var activityCategory: UIActivity.Category {
        return .share
    }
    
    init(title: String, performAction: @escaping ([Any]) -> Void) {
        
        self.title = title
        image = UIImage(named: "qr_code")
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
