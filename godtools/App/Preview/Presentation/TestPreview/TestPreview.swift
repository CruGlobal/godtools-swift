//
//  TestPreview.swift
//  godtools
//
//  Created by Levi Eggert on 6/20/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import SwiftUI

struct TestPreview: View {

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center, spacing: 0) {
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 100, height: 100)
            }
        }
    }
}

#Preview {
    TestPreview()
}
