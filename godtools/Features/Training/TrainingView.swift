//
//  TrainingView.swift
//  godtools
//
//  Created by Levi Eggert on 10/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class TrainingView: UIViewController {
    
    private let viewModel: TrainingViewModelType
            
    @IBOutlet weak private var overlayButton: UIButton!
    @IBOutlet weak private var contentView: UIView!
    @IBOutlet weak private var tipPagesNavigationView: PageNavigationCollectionView!
    @IBOutlet weak private var closeButton: UIButton!
    @IBOutlet weak private var progressView: ProgressView!
    @IBOutlet weak private var iconImageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var continueButton: UIButton!
    
    required init(viewModel: TrainingViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: TrainingView.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view didload: \(type(of: self))")
        
        setupLayout()
        setupBinding()
        
        tipPagesNavigationView.delegate = self
    }
    
    private func setupLayout() {
        
    }
    
    private func setupBinding() {
        
        viewModel.icon.addObserver(self) { [weak self] (icon: UIImage?) in
            self?.iconImageView.image = icon
        }
        
        viewModel.title.addObserver(self) { [weak self] (title: String) in
            self?.titleLabel.text = title
        }
        
        viewModel.numberOfTipPages.addObserver(self) { [weak self] (numberOfTipPages: Int) in
            self?.tipPagesNavigationView.reloadData()
        }
    }
}

extension TrainingView: PageNavigationCollectionViewDelegate {
    
    func pageNavigationNumberOfPages(pageNavigation: PageNavigationCollectionView) -> Int {
        return viewModel.numberOfTipPages.value
    }
    
    func pageNavigation(pageNavigation: PageNavigationCollectionView, cellForPageAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    func pageNavigationDidChangePage(pageNavigation: PageNavigationCollectionView, page: Int) {
        
    }
    
    func pageNavigationDidStopOnPage(pageNavigation: PageNavigationCollectionView, page: Int) {
        
    }
}
