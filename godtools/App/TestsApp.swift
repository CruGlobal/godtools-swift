//
//  TestsApp.swift
//  godtools
//
//  Created by Levi Eggert on 6/20/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import SwiftUI

struct TestsApp: App {
    var body: some Scene {
        WindowGroup {
            GeometryReader { geometry in
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                    Text("Unit Tests...")
                        .foregroundColor(Color.black)
                        .font(Font.system(size: 19))
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                    Spacer()
                }
                .frame(width: geometry.size.width)
            }
            .background(Color.white)
        }
    }
}
