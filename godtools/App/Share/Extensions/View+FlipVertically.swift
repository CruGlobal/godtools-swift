//
//  View+FlipVertically.swift
//  godtools
//
//  Created by Levi Eggert on 10/18/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

extension View {
    
    func flipVertically(shouldFlip: Bool = true) -> some View {
        return rotationEffect(.degrees(shouldFlip ? -180 : 0))
    }
}
