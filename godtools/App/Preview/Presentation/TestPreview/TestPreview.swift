//
//  TestPreview.swift
//  godtools
//
//  Created by Levi Eggert on 6/20/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import SwiftUI

struct TestPreview: View {

    private let title: String
    
    init(title: String) {
        self.title = title
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center, spacing: 0) {
                
                Text(title)
                    .foregroundStyle(.black)
                
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 100, height: 100)
            }
        }
    }
}

#Preview {
    
    let appDiContainer = AppDiContainer.createUITestsDiContainer()
    let resource: ResourceModel? = appDiContainer.dataLayer.getResourcesRepository().getResource(id: "1")
    
    TestPreview(
        title: resource?.name ?? "no name"
    )
}
