//
//  ScaleValueSliderView.swift
//  godtools
//
//  Created by Levi Eggert on 10/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct ScaleValueSliderView: View {
    
    private let viewWidth: CGFloat
    private let backgroundColor: Color = Color.white
    private let textBoundsWidth: CGFloat = 40
    private let scrubberBarLeading: CGFloat
    private let scrubberBarWidth: CGFloat
    private let scrubberSize: CGFloat = 44
    private let tintColor: Color
    private let lineWidth: CGFloat = 1
    private let minScaleValue: CGFloat
    private let maxScaleValue: CGFloat
        
    @Binding private var scale: Int
    
    @State private var progress: CGFloat
    
    init(viewWidth: CGFloat, tintColor: Color, minScaleValue: Int = 0, maxScaleValue: Int = 10, scale: Binding<Int>) {
                
        self.viewWidth = viewWidth
        self.tintColor = tintColor
        self.scrubberBarLeading = textBoundsWidth
        self.scrubberBarWidth = viewWidth - (textBoundsWidth * 2)
        
        if minScaleValue < 0 {
            assertionFailure("minScaleValue must be greater than or equal to zero.")
        }
        
        if minScaleValue >= maxScaleValue {
            assertionFailure("minScaleValue must be less than maxScaleValue.")
        }
        
        let minScaleFloatValue: CGFloat = CGFloat(minScaleValue)
        let maxScaleFloatValue: CGFloat = CGFloat(maxScaleValue)
        
        self.minScaleValue = minScaleFloatValue
        self.maxScaleValue = maxScaleFloatValue
                
        self._scale = scale
        self.progress = ScaleValueSliderView.getProgress(scale: scale.wrappedValue, minScaleValue: minScaleFloatValue, maxScaleValue: maxScaleFloatValue)
    }
    
    var body: some View {
        
        let dragGesture = DragGesture(minimumDistance: 0)
            .onChanged { (value: DragGesture.Value) in
            
                didPanScrubber(location: value.location)
            }
            .onEnded { (value: DragGesture.Value) in

                didPanScrubber(location: value.location)
            }
        
        ZStack(alignment: .leading) {
            
            Rectangle()
                .foregroundColor(backgroundColor)
                .frame(width: viewWidth, height: scrubberSize)
                .gesture(dragGesture)
            
            HStack(alignment: .center, spacing: 0) {
                
                Text("\(Int(minScaleValue))")
                    .foregroundColor(tintColor)
                    .frame(width: textBoundsWidth, alignment: .center)
                
                Rectangle()
                    .foregroundColor(tintColor)
                    .frame(width: scrubberBarWidth, height: lineWidth)
                
                Text("\(Int(maxScaleValue))")
                    .foregroundColor(tintColor)
                    .frame(width: textBoundsWidth, alignment: .center)
            }
            .allowsHitTesting(false)
            
            CircledTextView(
                backgroundColor: .white,
                tintColor: tintColor,
                lineWidth: lineWidth,
                size: CGSize(width: scrubberSize, height: scrubberSize),
                text: "\(scale)"
            )
            .allowsHitTesting(false)
            .padding([.leading], scrubberBarLeading + (progress * scrubberBarWidth) - (scrubberSize / 2))
        }
        .frame(width: viewWidth)
    }
    
    private func didPanScrubber(location: CGPoint) {
        
        let panGestureXRelativeToView: CGFloat = location.x
        let minScrubberX: CGFloat = scrubberBarLeading
        let maxSrubberX: CGFloat = minScrubberX + scrubberBarWidth
        
        let clampedPanGestureX: CGFloat
        
        if panGestureXRelativeToView < minScrubberX {
            clampedPanGestureX = minScrubberX
        }
        else if panGestureXRelativeToView > maxSrubberX {
            clampedPanGestureX = maxSrubberX
        }
        else {
            clampedPanGestureX = panGestureXRelativeToView
        }
        
        var progress: CGFloat = (clampedPanGestureX - minScrubberX) / scrubberBarWidth
        
        if ApplicationLayout.shared.layoutDirection == .rightToLeft {
            progress = ScaleValueSliderView.invertProgress(progress: progress)
        }
        
        self.progress = progress
        self.scale = getScale(progress: progress)
    }
    
    private static func getProgress(scale: Int, minScaleValue: CGFloat, maxScaleValue: CGFloat) -> CGFloat {
        
        let minimumScaleToZero: CGFloat = 0 - minScaleValue
        let maximumScaleValueBasedOnMinimumScaleToZero: CGFloat = maxScaleValue + minimumScaleToZero
        let floatScale: CGFloat = CGFloat(scale)
        let floatScaleBasedOnMinimumScaleToZero: CGFloat = floatScale + minimumScaleToZero
        
        let progress: CGFloat = floatScaleBasedOnMinimumScaleToZero / maximumScaleValueBasedOnMinimumScaleToZero
        
        return progress
    }

    private func getScale(progress: CGFloat) -> Int {
        
        let floatScaleValue: CGFloat = floor(((maxScaleValue - minScaleValue) * progress) + minScaleValue)
        let scaleValue: Int = Int(floatScaleValue)
        
        return scaleValue
    }
    
    private static func invertProgress(progress: CGFloat) -> CGFloat {
        return (progress * -1) + 1
    }
}

struct ScaleValueSliderView_Preview: PreviewProvider {
           
    @State static private var scale: Int = 4
    
    static var previews: some View {
        
        GeometryReader { geometry in
            
            ScaleValueSliderView(
                viewWidth: 300,
                tintColor: ColorPalette.gtBlue.color,
                scale: ScaleValueSliderView_Preview.$scale
            )
        }
    }
}
