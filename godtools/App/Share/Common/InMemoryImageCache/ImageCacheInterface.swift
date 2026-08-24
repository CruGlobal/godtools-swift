//
//  ImageCacheInterface.swift
//  godtools
//
//  Created by Levi Eggert on 8/19/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import SwiftUI

protocol ImageCacheInterface: Sendable {
    
    func cacheImage(id: String, image: Image)
    func getImage(id: String) -> Image?
}
