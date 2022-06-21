//
//  ViewSizePreferenceKey.swift
//  godtools
//
//  Created by Levi Eggert on 6/12/22.
//

import UIKit
import SwiftUI

struct ViewSizePreferenceKey: PreferenceKey {
  
    static var defaultValue: CGSize = .zero
  
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
