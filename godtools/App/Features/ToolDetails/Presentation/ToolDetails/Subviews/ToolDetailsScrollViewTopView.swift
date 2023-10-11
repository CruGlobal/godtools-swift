//
//  ToolDetailsScrollViewTopView.swift
//  godtools
//
//  Created by Levi Eggert on 10/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct ToolDetailsScrollViewTopView: View {
    
    private let geometry: GeometryProxy
    
    init(geometry: GeometryProxy) {
        
        self.geometry = geometry
    }
    
    var body: some View {
        
        ZStack {
            Rectangle()
                .fill(Color.clear)
                .frame(width: geometry.size.width, height: 0)
        }
        .id(ToolDetailsView.scrollToTopViewId)
    }
}
