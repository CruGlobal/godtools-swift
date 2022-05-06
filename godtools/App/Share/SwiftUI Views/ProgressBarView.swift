//
//  ProgressBarView.swift
//  godtools
//
//  Created by Rachael Skeath on 5/5/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ProgressBarView: View {
    let color: Color
    let progress: Double
    
    var body: some View {
        GeometryReader { geo in
            color
                .frame(width: geo.size.width * progress)
                .opacity(progress == 1 ? 0 : 1)
        }
        
    }
}

struct ProgressBarView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressBarView(color: .blue, progress: 0.25)
            .frame(width: 375, height: 5)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
