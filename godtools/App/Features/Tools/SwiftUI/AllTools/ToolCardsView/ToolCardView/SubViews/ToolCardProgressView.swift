//
//  ToolCardProgressView.swift
//  godtools
//
//  Created by Rachael Skeath on 5/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolCardProgressView: View {
    let frontProgress: Double
    let backProgress: Double
    
    var body: some View {
        ZStack {
            ProgressBarView(color: .yellow, progress: backProgress)
            ProgressBarView(color: ColorPalette.progressBarBlue.color, progress: frontProgress)
        }
        .frame(height: 2)
    }
}

struct ToolCardProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ToolCardProgressView(frontProgress: 0.5, backProgress: 0.99)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
