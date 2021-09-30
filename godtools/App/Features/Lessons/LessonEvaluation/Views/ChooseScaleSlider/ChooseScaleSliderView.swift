//
//  ChooseScaleSliderView.swift
//  godtools
//
//  Created by Levi Eggert on 9/29/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

@IBDesignable
class ChooseScaleSliderView: UIView, NibBased {
    
    private static let defaultMinScale: CGFloat = 1
    private static let defaultMaxScale: CGFloat = 10
    
    private var minScaleValue: CGFloat = ChooseScaleSliderView.defaultMinScale
    private var maxScaleValue: CGFloat = ChooseScaleSliderView.defaultMaxScale
    private var didSetProgressValue: Bool = false
    
    private var sliderViewSize: CGFloat {
        return frame.size.height
    }
    private var isLoaded: Bool = false
    
    @IBInspectable var primaryColor: UIColor = UIColor.red {
        didSet {
            if isLoaded {
                minScaleLabel.textColor = primaryColor
                maxScaleLabel.textColor = primaryColor
                progressBar.backgroundColor = primaryColor
                sliderView.layer.borderColor = primaryColor.cgColor
                scaleValueLabel.textColor = primaryColor
            }
        }
    }
    
    @IBInspectable var sliderBackgroundColor: UIColor = UIColor.white {
        didSet {
            if isLoaded {
                sliderView.backgroundColor = sliderBackgroundColor
            }
        }
    }
    
    @IBOutlet weak private var minScaleLabel: UILabel!
    @IBOutlet weak private var maxScaleLabel: UILabel!
    @IBOutlet weak private var progressBar: UIView!
    @IBOutlet weak private var sliderView: UIView!
    @IBOutlet weak private var scaleValueLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        
        loadNib()
        setMinScaleValue(minScaleValue: ChooseScaleSliderView.defaultMinScale, maxScaleValue: ChooseScaleSliderView.defaultMaxScale)
        isLoaded = true
        setupLayout()
        setProgress(progressValue: 0)
    }
    
    private func setupLayout() {
        
        isMultipleTouchEnabled = false
        
        sliderView.layer.borderWidth = 1
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
                
        // scaleValueLabel
        scaleValueLabel.frame = CGRect(x: 0, y: 0, width: sliderViewSize, height: sliderViewSize)
        
        // sliderView
        let sliderViewFrame: CGRect = sliderView.frame
        sliderView.frame = CGRect(x: sliderViewFrame.origin.x, y: sliderViewFrame.origin.y, width: sliderViewSize, height: sliderViewSize)
        sliderView.layer.cornerRadius = sliderViewSize / 2
    }
    
    // MARK: -
    
    var progressMinX: CGFloat {
        return progressBar.frame.origin.x
    }
    
    var progressMaxX: CGFloat {
        return progressBar.frame.origin.x + progressBar.frame.size.width
    }
    
    func setMinScaleValue(minScaleValue: CGFloat, maxScaleValue: CGFloat) {
        
        if minScaleValue < 0 {
            assertionFailure("minScaleValue must be greater than or equal to 0.")
        }
        
        if minScaleValue >= maxScaleValue {
            assertionFailure("minScaleValue must be less than maxScaleValue")
        }
        
        self.minScaleValue = minScaleValue
        self.maxScaleValue = maxScaleValue
    }
    
    func setProgress(progressValue: CGFloat) {
        
        let sliderXPosition: CGFloat = (progressBar.frame.size.width * progressValue) + progressMinX
        
        setSliderXPosition(newXPosition: sliderXPosition)
    }
    
    func setSliderXPosition(newXPosition: CGFloat) {
        
        var sliderXPosition: CGFloat = 0
        
        if newXPosition < progressMinX {
            sliderXPosition = progressMinX
        }
        else if newXPosition > progressMaxX {
            sliderXPosition = progressMaxX
        }
        else {
            sliderXPosition = newXPosition
        }
        
        sliderXPosition = sliderXPosition - (sliderViewSize / 2)
        
        sliderView.frame = CGRect(
            x: sliderXPosition,
            y: (frame.size.height - sliderViewSize) / 2,
            width: sliderViewSize,
            height: sliderViewSize
        )
        
        let currentSliderPercentageAlongProgressBar: CGFloat = sliderXPosition / progressBar.frame.size.width
        let floatScaleValue: CGFloat = floor(((maxScaleValue - minScaleValue) * currentSliderPercentageAlongProgressBar) + minScaleValue)
        let scaleValue: Int = Int(floatScaleValue)
                
        scaleValueLabel.text = "\(scaleValue)"
    }
    
    // MARK: - Touches
    
    private func handleSliderTouched(touch: UITouch) {
        
        let touchPoint: CGPoint = touch.location(in: self)
                
        setSliderXPosition(newXPosition: touchPoint.x)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else {
            return
        }
        
        handleSliderTouched(touch: touch)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else {
            return
        }
        
        handleSliderTouched(touch: touch)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else {
            return
        }
        
        handleSliderTouched(touch: touch)
    }
}
