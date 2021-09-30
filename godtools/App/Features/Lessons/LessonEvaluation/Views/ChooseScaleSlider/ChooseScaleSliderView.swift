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
    
    private let minScaleValue: CGFloat = 1
    private let maxScaleValue: CGFloat = 10
    
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
        isLoaded = true
        setupLayout()
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
    
    func setScale(scaleValue: CGFloat) {
        
    }
    
    // MARK: - Touches
    
    private func handleSliderTouched(touch: UITouch) {
        
        let touchPoint: CGPoint = touch.location(in: self)
                
        sliderView.frame = CGRect(
            x: touchPoint.x,
            y: touchPoint.y,
            width: sliderViewSize,
            height: sliderViewSize
        )
        
        print("--> touchPoint: \(touchPoint)")
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
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
}
