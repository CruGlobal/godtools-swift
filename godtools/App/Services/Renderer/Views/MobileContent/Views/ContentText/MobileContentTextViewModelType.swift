//
//  MobileContentTextViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 3/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

protocol MobileContentTextViewModelType: MobileContentViewModelType {
    
    var startImage: UIImage? { get }
    var startImageSize: CGSize { get }
    var hidesStartImage: Bool { get }
    var font: UIFont { get }
    var text: String? { get }
    var textColor: UIColor { get }
    var textAlignment: NSTextAlignment { get }
    var minimumLines: CGFloat { get }
    var endImage: UIImage? { get }
    var endImageSize: CGSize { get }
    var hidesEndImage: Bool { get }
    
    func getScaledFont(fontSizeToScale: CGFloat, fontWeightElseUseTextDefault: UIFont.Weight?) -> UIFont
}
