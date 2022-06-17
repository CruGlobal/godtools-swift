//
//  ViewGeometry.swift
//  godtools
//
//  Created by Levi Eggert on 6/12/22.
//

import SwiftUI

struct ViewGeometry: View {
    
    var body: some View {
        
        GeometryReader { geometry in
            Color.clear
                .preference(key: ViewSizePreferenceKey.self, value: geometry.size)
        }
    }
}
