//
//  SharedBackgroundVisibility.swift
//  godtools
//
//  Created by Levi Eggert on 8/19/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import SwiftUI

extension ToolbarContent {
    @ToolbarContentBuilder
    func ifAvailableSharedBackgroundVisibility(_ value: Visibility) -> some ToolbarContent {
        if #available(iOS 26.0, *) {
            sharedBackgroundVisibility(value)
        } else {
            self
        }
    }
}
