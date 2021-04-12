//
//  LessonProgressView.swift
//  godtools
//
//  Created by Levi Eggert on 4/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

protocol LessonProgressViewDelegate: class {
    
    func lessonProgressViewCloseTapped(progressView: LessonProgressView)
}

class LessonProgressView: UIView, NibBased {
    
    private weak var delegate: LessonProgressViewDelegate?
    
    let height: CGFloat
    
    @IBOutlet weak private var progressView: ProgressView!
    @IBOutlet weak private var closeButton: UIButton!
    
    required init() {
        
        let height: CGFloat = 64
        
        self.height = height
        
        super.init(frame: CGRect(x: 0, y: 0, width: 414, height: height))
        
        loadNib()
        setupLayout()
        
        closeButton.addTarget(self, action: #selector(handleCloseTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        
    }
    
    @objc func handleCloseTapped() {
        delegate?.lessonProgressViewCloseTapped(progressView: self)
    }
    
    func setDelegate(delegate: LessonProgressViewDelegate?) {
        self.delegate = delegate
    }
}
