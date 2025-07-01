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
    
    static let activityType: UIActivity.ActivityType = ActivityType(rawValue: "org.cru.godtools.screenShareQRCodeActivity")
    
    private let title: String
    private let image: UIImage?
    
    private var activityItems = [Any]()
    
    override var activityTitle: String? {
        return title
    }
    
    override var activityImage: UIImage? {
        return image
    }
    
    override var activityType: UIActivity.ActivityType? {
        return Self.activityType
    }
    
    override class var activityCategory: UIActivity.Category {
        return .share
    }
    
    init(title: String) {
        
        self.title = title
        image = UIImage(named: "qr_code")
        
        super.init()
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
    
    override func prepare(withActivityItems activityItems: [Any]) {
        self.activityItems = activityItems
    }
    
    override func perform() {
        activityDidFinish(true)
    }
}
