//
//  ChooseScaleSliderView.swift
//  godtools
//
//  Created by Levi Eggert on 9/29/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

protocol ChooseScaleSliderViewDelegate: AnyObject {
    
    func chooseScaleSliderDidChangeScaleValue(chooseScaleSlider: ChooseScaleSliderView, scaleValue: Int)
}

@IBDesignable
class ChooseScaleSliderView: UIView, NibBased {
    
    private static let defaultMinScale: Int = 1
    private static let defaultMaxScale: Int = 10
    
    private let minAndMaxScaleLabelWidth: CGFloat = 50
    
    private var minScaleValue: CGFloat = 0
    private var maxScaleValue: CGFloat = 0
    private var lastBoundsSize: CGSize = .zero
    private var didSetProgressValue: Bool = false
    
    private var sliderViewY: CGFloat {
        return (frame.size.height - sliderViewSize) / 2
    }
    
    private var sliderViewSize: CGFloat {
        return frame.size.height
    }
    private var isLoaded: Bool = false
    
    private(set) var currentScaleValue: Int = 0
    
    private weak var delegate: ChooseScaleSliderViewDelegate?
    
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
                
        // minScaleLabel
        minScaleLabel.frame = CGRect(x: 0, y: 0, width: minAndMaxScaleLabelWidth, height: frame.size.height)
        
        // maxScaleLabel
        maxScaleLabel.frame = CGRect(x: frame.size.width - minAndMaxScaleLabelWidth, y: 0, width: minAndMaxScaleLabelWidth, height: frame.size.height)
        
        // progressBar
        progressBar.frame = CGRect(x: minAndMaxScaleLabelWidth, y: frame.size.height / 2, width: frame.size.width - minAndMaxScaleLabelWidth - minAndMaxScaleLabelWidth, height: 1)
        
        // scaleValueLabel
        scaleValueLabel.frame = CGRect(x: 0, y: 0, width: sliderViewSize, height: sliderViewSize)
        
        // sliderView
        let sliderViewFrame: CGRect = sliderView.frame
        sliderView.frame = CGRect(x: sliderViewFrame.origin.x, y: sliderViewY, width: sliderViewSize, height: sliderViewSize)
        sliderView.layer.cornerRadius = sliderViewSize / 2
        
        if lastBoundsSize.width != frame.size.width {
            setScale(scaleValue: currentScaleValue)
        }
        
        lastBoundsSize = frame.size
    }
    
    // MARK: -
    
    var progressWidth: CGFloat {
        return progressBar.frame.size.width
    }
    
    func setDelegate(delegate: ChooseScaleSliderViewDelegate?) {
        self.delegate = delegate
    }
    
    func setMinScaleText(text: String) {
        minScaleLabel.text = text
    }
    
    func setMaxScaleText(text: String) {
        maxScaleLabel.text = text
    }
    
    func setScaleValueText(text: String) {
        scaleValueLabel.text = text
    }
    
    func setMinScaleValue(minScaleValue: Int, maxScaleValue: Int) {
        
        if minScaleValue < 0 {
            assertionFailure("minScaleValue must be greater than or equal to zero.")
        }
        
        if minScaleValue >= maxScaleValue {
            assertionFailure("minScaleValue must be less than maxScaleValue.")
        }
        
        self.minScaleValue = CGFloat(minScaleValue)
        self.maxScaleValue = CGFloat(maxScaleValue)
    }
    
    func setScale(scaleValue: Int, shouldUpdateSliderPosition: Bool = true) {
                
        if shouldUpdateSliderPosition {
            
            let progressValue: CGFloat = getPercentage(scale: scaleValue)
            
            setProgress(progressValue: progressValue)
        }
        else {
            
            currentScaleValue = scaleValue
            
            setScaleValueText(text: "\(scaleValue)")
            
            delegate?.chooseScaleSliderDidChangeScaleValue(chooseScaleSlider: self, scaleValue: scaleValue)
        }
    }
    
    func setProgress(progressValue: CGFloat) {
        
        let clampedProgressValue: CGFloat
        
        if progressValue < 0 {
            clampedProgressValue = 0
        }
        else if progressValue > 1 {
            clampedProgressValue = 1
        }
        else {
            clampedProgressValue = progressValue
        }
        
        let absoluteXPosition: CGFloat = progressWidth * clampedProgressValue
        
        setSliderAbsoluteXPosition(absoluteXPosition: absoluteXPosition)
    }
    
    func setSliderAbsoluteXPosition(absoluteXPosition: CGFloat) {
        
        // NOTE: absoluteXPosition is based along the progressWidth and assumes that the progressBar x position is starting at 0.
        
        let clampedAbsoluteXPosition: CGFloat
        
        if absoluteXPosition < 0 {
            clampedAbsoluteXPosition = 0
        }
        else if absoluteXPosition > progressWidth {
            clampedAbsoluteXPosition = progressWidth
        }
        else {
            clampedAbsoluteXPosition = absoluteXPosition
        }
                
        sliderView.frame = CGRect(
            x: clampedAbsoluteXPosition - (sliderViewSize / 2) + progressBar.frame.origin.x,
            y: sliderViewY,
            width: sliderViewSize,
            height: sliderViewSize
        )
        
        let currentSliderPercentageAlongProgressBar: CGFloat = clampedAbsoluteXPosition / progressWidth
        
        let scaleValue: Int = getScale(percentage: currentSliderPercentageAlongProgressBar)
                
        setScale(scaleValue: scaleValue, shouldUpdateSliderPosition: false)
    }
    
    private func getPercentage(scale: Int) -> CGFloat {
        
        let minimumScaleToZero: CGFloat = 0 - minScaleValue
        let maximumScaleValueBasedOnMinimumScaleToZero: CGFloat = maxScaleValue + minimumScaleToZero
        let floatScale: CGFloat = CGFloat(scale)
        let floatScaleBasedOnMinimumScaleToZero: CGFloat = floatScale + minimumScaleToZero
        let percentage: CGFloat = floatScaleBasedOnMinimumScaleToZero / maximumScaleValueBasedOnMinimumScaleToZero
        
        return percentage
    }
    
    private func getScale(percentage: CGFloat) -> Int {
        
        let floatScaleValue: CGFloat = floor(((maxScaleValue - minScaleValue) * percentage) + minScaleValue)
        let scaleValue: Int = Int(floatScaleValue)
        
        return scaleValue
    }
    
    // MARK: - Touches
    
    private func handleSliderTouched(touch: UITouch) {
        
        let touchPoint: CGPoint = touch.location(in: self)
        
        let absoluteXPosition: CGFloat = touchPoint.x - progressBar.frame.origin.x
                        
        setSliderAbsoluteXPosition(absoluteXPosition: absoluteXPosition)
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
