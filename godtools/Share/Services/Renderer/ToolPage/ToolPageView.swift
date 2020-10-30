//
//  ToolPageView.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageView: UIViewController {
    
    private let viewModel: ToolPageViewModelType
    
    private var contentStackView: MobileContentStackView?
    private var heroView: MobileContentStackView?
            
    private var didLayoutSubviews: Bool = false
    
    @IBOutlet weak private var backgroundImageView: UIImageView!
    @IBOutlet weak private var mobileContentStackContainerView: UIView!
    @IBOutlet weak private var headerView: UIView!
    @IBOutlet weak private var headerNumberLabel: UILabel!
    @IBOutlet weak private var headerTitleLabel: UILabel!
    @IBOutlet weak private var heroContainerView: UIView!
    @IBOutlet weak private var callToActionView: UIView!
    @IBOutlet weak private var callToActionTitleLabel: UILabel!
    @IBOutlet weak private var callToActionNextButton: UIButton!
    
    @IBOutlet weak private var headerTop: NSLayoutConstraint!
    @IBOutlet weak private var callToActionBottom: NSLayoutConstraint!
    
    required init(viewModel: ToolPageViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: ToolPageView.self), bundle: nil)
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
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard !didLayoutSubviews else {
            return
        }
        didLayoutSubviews = true
        
        setHeaderHidden(hidden: viewModel.hidesHeader, animated: false)
        
        setCallToActionHidden(hidden: viewModel.hidesCallToAction, animated: false)
        
        setHeroTopContentInset()
    }
    
    private func setupLayout() {
        
    }
    
    private func setupBinding() {
        
        if let contentStackViewModel = viewModel.contentStack {
            let mobileContentView = MobileContentStackView(viewModel: contentStackViewModel, viewSpacing: 10, scrollIsEnabled: true)
            mobileContentStackContainerView.addSubview(mobileContentView)
            mobileContentView.constrainEdgesToSuperview()
            mobileContentStackContainerView.isHidden = false
            self.contentStackView = mobileContentView
        }
        else {
            mobileContentStackContainerView.isHidden = true
        }
                
        headerNumberLabel.text = viewModel.headerNumber
        headerTitleLabel.text = viewModel.headerTitle
        callToActionTitleLabel.text = viewModel.callToActionTitle
        
        if let heroViewModel = viewModel.hero {
            let mobileContentView = MobileContentStackView(viewModel: heroViewModel, viewSpacing: 10, scrollIsEnabled: true)
            heroContainerView.addSubview(mobileContentView)
            mobileContentView.constrainEdgesToSuperview()
            heroContainerView.isHidden = false
            self.heroView = mobileContentView
        }
        else {
            heroContainerView.isHidden = true
        }
    }
    
    private func setHeroTopContentInset() {
        
        let heroTopContentInset: CGFloat
        if !viewModel.hidesHeader {
            heroTopContentInset = headerView.frame.size.height + 20
        }
        else {
            heroTopContentInset = 30
        }
        
        heroView?.scrollView?.contentInset = UIEdgeInsets(top: heroTopContentInset, left: 0, bottom: 0, right: 0)
        heroView?.scrollView?.contentOffset = CGPoint(x: 0, y: heroTopContentInset * -1)
    }
    
    private func setHeaderHidden(hidden: Bool, animated: Bool) {
            
        let topConstant: CGFloat = hidden ? headerView.frame.size.height * -1 : 0
        
        headerTop.constant = topConstant
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
        else {
            view.layoutIfNeeded()
        }
    }
    
    private func setCallToActionHidden(hidden: Bool, animated: Bool) {
        
        let bottomConstant: CGFloat = hidden ? callToActionView.frame.size.height * -1 : 0
        
        callToActionBottom.constant = bottomConstant
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
        else {
            view.layoutIfNeeded()
        }
    }
}
