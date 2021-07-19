//
//  ContentTextModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/14/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol ContentTextModelType {
    
    var endImage: String? { get }
    var endImageSize: String { get }
    var startImage: String? { get }
    var startImageSize: String { get }
    var text: String? { get }
    var textAlign: String? { get }
    var textColor: String? { get }
    var textScale: String? { get }
    var textStyle: String? { get }
    var textAlignment: MobileContentTextAlign? { get }
    
    func getTextColor() -> MobileContentRGBAColor?
}
