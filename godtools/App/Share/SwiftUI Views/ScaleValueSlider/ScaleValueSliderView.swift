//
//  ScaleValueSliderView.swift
//  godtools
//
//  Created by Levi Eggert on 10/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct ScaleValueSliderView: View {
    
    private static let defaultMinScale: ScaleValue = ScaleValue(integerValue: 0, displayValue: "0")
    private static let defaultMaxScale: ScaleValue = ScaleValue(integerValue: 10, displayValue: "10")
    
    private let viewWidth: CGFloat
    private let backgroundColor: Color = Color.white
    private let textBoundsWidth: CGFloat = 40
    private let scrubberBarLeading: CGFloat
    private let scrubberBarWidth: CGFloat
    private let scrubberSize: CGFloat = 44
    private let tintColor: Color
    private let lineWidth: CGFloat = 1
    private let minScale: ScaleValue
    private let maxScale: ScaleValue
    private let scaleDisplayValue: String
        
    @Binding private var scaleIntValue: Int
    
    @State private var progress: CGFloat
    
    init(viewWidth: CGFloat, tintColor: Color, minScale: ScaleValue = ScaleValueSliderView.defaultMinScale, maxScale: ScaleValue = ScaleValueSliderView.defaultMaxScale, scaleIntValue: Binding<Int>, scaleDisplayValue: String) {
                
        self.viewWidth = viewWidth
        self.tintColor = tintColor
        self.scrubberBarLeading = textBoundsWidth
        self.scrubberBarWidth = viewWidth - (textBoundsWidth * 2)
        
        if minScale.integerValue < 0 {
            assertionFailure("minScaleValue must be greater than or equal to zero.")
        }
        
        if minScale.integerValue >= maxScale.integerValue {
            assertionFailure("minScaleValue must be less than maxScaleValue.")
        }
                
        self.minScale = minScale
        self.maxScale = maxScale
        self.scaleDisplayValue = scaleDisplayValue
        
        self._scaleIntValue = scaleIntValue
        
        self.progress = ScaleValueSliderView.getProgress(
            scale: scaleIntValue.wrappedValue,
            minScaleValue: CGFloat(minScale.integerValue),
            maxScaleValue: CGFloat(maxScale.integerValue)
        )
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
                
                Text(minScale.displayValue)
                    .foregroundColor(tintColor)
                    .frame(width: textBoundsWidth, alignment: .center)
                
                Rectangle()
                    .foregroundColor(tintColor)
                    .frame(width: scrubberBarWidth, height: lineWidth)
                
                Text(maxScale.displayValue)
                    .foregroundColor(tintColor)
                    .frame(width: textBoundsWidth, alignment: .center)
            }
            .allowsHitTesting(false)
            
            CircledTextView(
                backgroundColor: .white,
                tintColor: tintColor,
                lineWidth: lineWidth,
                size: CGSize(width: scrubberSize, height: scrubberSize),
                text: scaleDisplayValue
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
        self.scaleIntValue = getScale(progress: progress)
    }
    
    private static func getProgress(scale: Int, minScaleValue: CGFloat, maxScaleValue: CGFloat) -> CGFloat {
        
        let minimumScaleToZero: CGFloat = 0 - minScaleValue
        let maximumScaleValueBasedOnMinimumScaleToZero: CGFloat = maxScaleValue + minimumScaleToZero
        let floatScale: CGFloat = CGFloat(scale)
        let floatScaleBasedOnMinimumScaleToZero: CGFloat = floatScale + minimumScaleToZero
        
        let progress: CGFloat = floatScaleBasedOnMinimumScaleToZero / maximumScaleValueBasedOnMinimumScaleToZero
        
        return progress
    }
    
    private func getMinScaleFloatValue() -> CGFloat {
        return CGFloat(minScale.integerValue)
    }
    
    private func getMaxScaleFloatValue() -> CGFloat {
        return CGFloat(maxScale.integerValue)
    }

    private func getScale(progress: CGFloat) -> Int {
        
        let floatScaleValue: CGFloat = floor(((getMaxScaleFloatValue() - getMinScaleFloatValue()) * progress) + getMinScaleFloatValue())
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
                scaleIntValue: ScaleValueSliderView_Preview.$scale,
                scaleDisplayValue: "\(ScaleValueSliderView_Preview.scale)"
            )
        }
    }
}
