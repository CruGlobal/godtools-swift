//
//  MobileContentTextView.swift
//  godtools
//
//  Created by Levi Eggert on 3/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentTextView: UIView {
    
    private let viewModel: MobileContentTextViewModelType
    private let imagePadding: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
    
    @IBOutlet weak private var startImageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var endImageView: UIImageView!
    
    @IBOutlet weak private var startImageViewLeading: NSLayoutConstraint!
    @IBOutlet weak private var startImageViewTop: NSLayoutConstraint!
    @IBOutlet weak private var startImageViewWidth: NSLayoutConstraint!
    @IBOutlet weak private var startImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak private var texLabelLeading: NSLayoutConstraint!
    @IBOutlet weak private var texLabelTop: NSLayoutConstraint!
    @IBOutlet weak private var texLabelTrailing: NSLayoutConstraint!
    @IBOutlet weak private var textLabelBottomToSuperview: NSLayoutConstraint!
    @IBOutlet weak private var endImageViewTrailing: NSLayoutConstraint!
    @IBOutlet weak private var endImageViewTop: NSLayoutConstraint!
    @IBOutlet weak private var endImageViewWidth: NSLayoutConstraint!
    @IBOutlet weak private var endImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak private var imageBottomToSuperview: NSLayoutConstraint!
        
    required init(viewModel: MobileContentTextViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        initializeNib()
        setupLayout()
        setupBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private func initializeNib() {
        
        let nib: UINib = UINib(nibName: String(describing: MobileContentTextView.self), bundle: nil)
        let contents: [Any]? = nib.instantiate(withOwner: self, options: nil)
        if let rootNibView = (contents as? [UIView])?.first {
            addSubview(rootNibView)
            rootNibView.frame = bounds
            rootNibView.translatesAutoresizingMaskIntoConstraints = false
            rootNibView.constrainEdgesToSuperview()
            rootNibView.backgroundColor = .clear
        }
    }
    
    private func setupLayout() {
        
        //setStartImageHidden(hidden: true)
        //setEndImageHidden(hidden: true)
        
        drawBorder(color: .green)
        textLabel.drawBorder(color: .blue)
        startImageView.drawBorder(color: .red)
        endImageView.drawBorder(color: .red)
    }
    
    private func setupBinding() {
        
        startImageView.image = viewModel.startImage
        textLabel.text = viewModel.text
        endImageView.image = viewModel.endImage
    }
    
    private func setStartImageHidden(hidden: Bool) {
        
        //startImageView.isHidden = hidden
        
        if hidden {
            startImageViewLeading.constant = startImageViewWidth.constant * -1
        }
        else {
            startImageViewLeading.constant = imagePadding.left
        }
        
        layoutIfNeeded()
    }
    
    private func setEndImageHidden(hidden: Bool) {
        
        //endImageView.isHidden = hidden
        
        if hidden {
            endImageViewTrailing.constant = frame.size.width
        }
        else {
            endImageViewTrailing.constant = imagePadding.right
        }
        
        layoutIfNeeded()
    }
}

