//
//  RoundedCorner.swift
//  godtools
//
//  Created by Rachael Skeath on 4/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct RoundedCorner: Shape {

    let radius: CGFloat
    let corners: UIRectCorner

    init(radius: CGFloat = .infinity, corners: UIRectCorner = .allCorners) {
        
        self.radius = radius
        self.corners = corners
    }
    
    func path(in rect: CGRect) -> Path {
        
        // NOTE: Found a strange bug specifically to SwiftUI iOS 14 where using UIBezierPath on clipShape will cause a nested ScrollView's content to be clipped / cut off. ~Levi
        // See Stackoverflow -> https://stackoverflow.com/questions/64259513/swiftui-issue-on-ios-14-with-scrollview-hstack-content-being-cut-off
        
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct RoundedCorner_Previews: PreviewProvider {
    static var previews: some View {
        RoundedCorner(radius: 26, corners: [.topLeft, .bottomRight])
            .previewLayout(.sizeThatFits)
            .padding()
            .frame(width: 200, height: 200)
    }
}
