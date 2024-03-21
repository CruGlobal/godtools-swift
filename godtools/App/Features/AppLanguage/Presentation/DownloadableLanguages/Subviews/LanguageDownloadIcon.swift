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
    private let animationDownloadProgress: Double?
    private let shouldConfirmDownloadRemoval: Bool
    
    init(languageDownloadStatus: LanguageDownloadStatusDomainModel, animationDownloadProgress: Double?, shouldConfirmDownloadRemoval: Bool) {
        self.languageDownloadStatus = languageDownloadStatus
        self.animationDownloadProgress = animationDownloadProgress
        self.shouldConfirmDownloadRemoval = shouldConfirmDownloadRemoval
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
            
            notDownloadedIcon()
            
        case .downloading(let progress):
            
            if let downloadProgress = self.animationDownloadProgress ?? progress {
            
                drawProgressInCircle(progress: downloadProgress)
                
            } else {
                
                notDownloadedIcon()
            }
                        
        case .downloaded:
            
            if shouldConfirmDownloadRemoval {
              
                Image(systemName: "xmark")
                    .imageScale(.small)
                
            } else if shouldFinishAnimatingDownloadProgress(), let animationDownloadProgress = animationDownloadProgress {

                drawProgressInCircle(progress: animationDownloadProgress)
                
            } else {
                Image(systemName: "checkmark")
                    .imageScale(.small)
            }
        }
    }
    
    @ViewBuilder private func notDownloadedIcon() -> some View {
        Image(systemName: "arrow.down.to.line")
            .imageScale(.small)
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
            
        case .downloading(let progress):
            
            let downloadProgress = self.animationDownloadProgress ?? progress
            if downloadProgress != nil {
                return ColorPalette.gtBlue.color
            } else {
                return LanguageDownloadIcon.lightGrey
            }
            
        case .downloaded:
            
            if shouldConfirmDownloadRemoval {
                return Color(.sRGB, red: 229 / 255, green: 91 / 255, blue: 54 / 255, opacity: 1.0)
            } else {
                return ColorPalette.gtBlue.color
            }
        }
    }
    
    private func shouldFinishAnimatingDownloadProgress() -> Bool {
        
        guard let animationDownloadProgress = animationDownloadProgress else { return false }
        return animationDownloadProgress <= 1
    }
}
