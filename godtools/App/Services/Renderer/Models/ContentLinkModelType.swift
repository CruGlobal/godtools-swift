//
//  ContentLinkModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/14/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol ContentLinkModelType {
    
    var events: [String] { get }
    var text: String? { get }
    
    func getTextColor() -> MobileContentRGBAColor?
    func getAnalyticsEvents() -> [AnalyticsEventModelType]
}
