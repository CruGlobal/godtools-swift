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
    
    private var minScaleValue: CGFloat = 0
    private var maxScaleValue: CGFloat = 0
    private var didSetProgressValue: Bool = false
    
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
        
        let floatScaleValue: CGFloat = CGFloat(scaleValue)
        
        if !(floatScaleValue >= minScaleValue && floatScaleValue <= maxScaleValue) {
            assertionFailure("scaleValue must be greater than or equal to \(minScaleValue) and less than or equal to \(maxScaleValue).")
        }
        
        if shouldUpdateSliderPosition {
            
            setProgress(progressValue: getPercentage(scale: scaleValue))
        }
        else {
            
            currentScaleValue = scaleValue
            
            setScaleValueText(text: "\(scaleValue)")
            
            delegate?.chooseScaleSliderDidChangeScaleValue(chooseScaleSlider: self, scaleValue: scaleValue)
        }
    }
    
    func setProgress(progressValue: CGFloat) {
        
        if !(progressValue >= 0 && progressValue <= 1) {
            assertionFailure("progressValue must be greater than or equal to 0 and less than or equal to 1.")
        }
        
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
        
        let scaleValue: Int = getScale(percentage: currentSliderPercentageAlongProgressBar)
                
        setScale(scaleValue: scaleValue, shouldUpdateSliderPosition: false)
    }
    
    private func getPercentage(scale: Int) -> CGFloat {
        
        let minimumScaleToZero: CGFloat = 0 - minScaleValue
        let maximumScaleValueBasedOnMinimumScaleToZero: CGFloat = maxScaleValue + minimumScaleToZero
        let floatScale: CGFloat = CGFloat(scale)
        let floatScaleBasedOnMinimumScaleToZero: CGFloat = floatScale + minimumScaleToZero
        
        return floatScaleBasedOnMinimumScaleToZero / maximumScaleValueBasedOnMinimumScaleToZero
    }
    
    private func getScale(percentage: CGFloat) -> Int {
        
        let floatScaleValue: CGFloat = floor(((maxScaleValue - minScaleValue) * percentage) + minScaleValue)
        let scaleValue: Int = Int(floatScaleValue)
        
        return scaleValue
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
