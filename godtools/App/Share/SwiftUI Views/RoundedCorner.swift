//
//  RoundedCorner.swift
//  godtools
//
//  Created by Rachael Skeath on 4/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

/// For use in the custom .cornerRadius modifier
struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
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
