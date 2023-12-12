//
//  LanguageDownloadIcon.swift
//  godtools
//
//  Created by Rachael Skeath on 12/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct LanguageDownloadIcon: View {
    
    private static let lightGrey = Color.getColorWithRGB(red: 151, green: 151, blue: 151, opacity: 1)
    
    private let languageDownloadStatus: LanguageDownloadStatusDomainModel
    
    init(languageDownloadStatus: LanguageDownloadStatusDomainModel) {
        self.languageDownloadStatus = languageDownloadStatus
    }

    var body: some View {
        
        ZStack {
            
            Circle()
                .stroke(lineWidth: 1.3)
            
            innerIcon()
        }
        .frame(width: 21, height: 21)
        .foregroundColor(iconColor())
    }
    
    @ViewBuilder private func innerIcon() -> some View {
        
        switch languageDownloadStatus {
        case .notDownloaded:
            
            Image(systemName: "arrow.down.to.line")
                .imageScale(.small)
            
        case .downloading(let progress):
            
            drawProgressInCircle(progress: progress)
            
        case .downloaded:
            
            Image(systemName: "checkmark")
                .imageScale(.small)
        }
    }
    
    @ViewBuilder private func drawProgressInCircle(progress: Double) -> some View {
        
        GeometryReader { geometry in
            
            Path { path in
                let width: CGFloat = min(geometry.size.width, geometry.size.height)
                let height = width
                
                let center = CGPoint(x: width * 0.5, y: height * 0.5)
                
                path.move(to: center)
                
                let startAngle = Angle(degrees: -90.0)
                let endAngle = startAngle + Angle(degrees: 360 * progress)
                
                path.addArc(
                    center: center,
                    radius: width * 0.5,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false)
                                    
            }
            .fill(ColorPalette.gtBlue.color)
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    private func iconColor() -> Color {
        switch languageDownloadStatus {
        case .notDownloaded:
            return LanguageDownloadIcon.lightGrey
        case .downloading:
            return ColorPalette.gtBlue.color
        case .downloaded:
            return ColorPalette.gtBlue.color
        }
    }
}
