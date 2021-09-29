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
        
        sliderView.layer.borderWidth = 1
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let sliderViewSize: CGFloat = frame.size.height
        
        scaleValueLabel.frame = CGRect(x: 0, y: 0, width: sliderViewSize, height: sliderViewSize)
        sliderView.frame = CGRect(x: 30, y: 0, width: sliderViewSize, height: sliderViewSize)
        sliderView.layer.cornerRadius = sliderViewSize / 2
    }
}
