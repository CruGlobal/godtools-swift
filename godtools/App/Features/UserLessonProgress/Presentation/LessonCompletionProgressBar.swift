//
//  LessonCompletionProgressBar.swift
//  godtools
//
//  Created by Rachael Skeath on 9/10/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import SwiftUI

struct LessonCompletionProgressBar: View {
    
    private let progressBarHeight: CGFloat = 7
    
    let lessonProgress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                let progressBarWidth: CGFloat = geometry.size.width
                
                Rectangle()
                    .fill(Color.getColorWithRGB(red: 238, green: 236, blue: 238, opacity: 1))
                    .frame(width: progressBarWidth, height: progressBarHeight)
                    .cornerRadius(6)
                
                Rectangle()
                    .fill(ColorPalette.gtBlue.color)
                    .frame(width: getProgressWidth(lessonProgress: lessonProgress, progressBarWidth: progressBarWidth), height: progressBarHeight)
                    .cornerRadius(6)
            }
        }
        .frame(height: .zero)
    }
    
    private func getProgressWidth(lessonProgress: Double, progressBarWidth: CGFloat) -> CGFloat {
        
        let width: CGFloat = lessonProgress * progressBarWidth
        
        if width < 0 {
            return 0
        }
        else if width > progressBarWidth {
            return progressBarWidth
        }
        
        return width
    }
}
