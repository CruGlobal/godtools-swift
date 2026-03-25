//
//  QRCodeActivity.swift
//  godtools
//
//  Created by Levi Eggert on 3/20/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import UIKit

class QRCodeActivity: UIActivity {
    
    private let title: String
    private let image: UIImage?
    private let activityTypeValue: UIActivity.ActivityType
    
    private var activityItems: [Any] = Array()
    
    init(title: String, activityType: UIActivity.ActivityType) {
        
        self.title = title
        image = ImageCatalog.qrCode.uiImage
        activityTypeValue = activityType
        
        super.init()
    }
    
    override var activityTitle: String? {
        return title
    }
    
    override var activityImage: UIImage? {
        return image
    }
    
    override var activityType: UIActivity.ActivityType? {
        return activityTypeValue
    }
    
    override class var activityCategory: UIActivity.Category {
        return .share
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
