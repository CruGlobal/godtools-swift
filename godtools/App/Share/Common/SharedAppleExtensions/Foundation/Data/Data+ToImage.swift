//
//  Data+ToImage.swift
//  godtools
//
//  Created by Levi Eggert on 5/14/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

extension Data {
    
    func toImage() -> Image? {
        
        guard let uiImage = toUIImage() else {
            return nil
        }
        
        return Image(uiImage: uiImage)
    }
    
    func toUIImage() -> UIImage? {
        return UIImage(data: self)
    }
}
