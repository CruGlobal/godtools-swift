//
//  ToolNavBarView.swift
//  godtools
//
//  Created by Levi Eggert on 11/16/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol ToolNavBarViewDelegate: class {
    
    func navBarHomeTapped(navBar: ToolNavBarView, remoteShareIsActive: Bool)
    func navBarShareTapped(navBar: ToolNavBarView, selectedLanguage: LanguageModel)
    func navBarLanguageChanged(navBar: ToolNavBarView)
}

class ToolNavBarView: NSObject {
    
    enum RightNavbarPosition: Int {
        case shareMenu = 0
        case remoteShareActive = 1
    }
    
    private let chooseLanguageControl: UISegmentedControl = UISegmentedControl()
    
    private var viewModel: ToolNavBarViewModelType?
    private var remoteShareActiveNavItem: UIBarButtonItem?
    private var isConfigured: Bool = false
    
    private weak var parentViewController: UIViewController?
    private weak var delegate: ToolNavBarViewDelegate?
    
    override init() {
        super.init()
    }
    
    func configure(parentViewController: UIViewController, viewModel: ToolNavBarViewModelType, delegate: ToolNavBarViewDelegate) {
        
        guard !isConfigured else {
            return
        }
        isConfigured = true
        
        self.parentViewController = parentViewController
        self.viewModel = viewModel
        self.delegate = delegate
        
        setupNavigationBar(parentViewController: parentViewController, viewModel: viewModel)
        setupBinding(viewModel: viewModel)
    }
    
    private func setupNavigationBar(parentViewController: UIViewController, viewModel: ToolNavBarViewModelType) {
        
        let navigationController: UINavigationController? = parentViewController.navigationController
        let navBarColor: UIColor = viewModel.navBarColor
        let navBarControlColor: UIColor = viewModel.navBarControlColor
             
        parentViewController.title = viewModel.navTitle
        
        navigationController?.navigationBar.setupNavigationBarAppearance(
            backgroundColor: navBarColor,
            controlColor: navBarControlColor,
            titleFont: viewModel.navBarFont,
            titleColor: navBarControlColor,
            isTranslucent: true
        )
                
        _ = parentViewController.addBarButtonItem(
            to: .left,
            image: viewModel.backButtonImage,
            color: navBarControlColor,
            target: self,
            action: #selector(backButtonTapped)
        )
        
        if !viewModel.hidesShareButton {
            
            _ = parentViewController.addBarButtonItem(
                to: .right,
                index: RightNavbarPosition.shareMenu.rawValue,
                image: ImageCatalog.navShare.image,
                color: navBarControlColor,
                target: self,
                action: #selector(shareButtonTapped)
            )
        }
        
        if !viewModel.hidesChooseLanguageControl {
                
            let navBarColor: UIColor = navBarColor
            let navBarControlColor: UIColor = navBarControlColor
            
            for index in 0 ..< viewModel.numberOfLanguages {
                chooseLanguageControl.insertSegment(
                    withTitle: viewModel.languageSegmentWillAppear(index: index).title,
                    at: index,
                    animated: false
                )
            }
            
            chooseLanguageControl.selectedSegmentIndex = 0

            let font: UIFont = viewModel.languageControlFont
            if #available(iOS 13.0, *) {
                chooseLanguageControl.selectedSegmentTintColor = navBarControlColor
                chooseLanguageControl.layer.borderColor = navBarControlColor.cgColor
                chooseLanguageControl.layer.borderWidth = 1
                chooseLanguageControl.backgroundColor = .clear
            } else {
                // Fallback on earlier versions
            }
            
            chooseLanguageControl.setTitleTextAttributes([.font: font, .foregroundColor: navBarControlColor], for: .normal)
            chooseLanguageControl.setTitleTextAttributes([.font: font, .foregroundColor: navBarColor.withAlphaComponent(1)], for: .selected)
            
            parentViewController.navigationItem.titleView = chooseLanguageControl
                        
            chooseLanguageControl.addTarget(
                self,
                action: #selector(didChooseLanguage(segmentedControl:)),
                for: .valueChanged
            )
        }
    }
    
    private func setupBinding(viewModel: ToolNavBarViewModelType) {
        
        viewModel.remoteShareIsActive.addObserver(self) { [weak self] (isActive: Bool) in
            self?.setRemoteShareActiveNavItem(hidden: !isActive)
        }
        
        viewModel.selectedLanguage.addObserver(self) { [weak self] (index: Int) in
            self?.chooseLanguageControl.selectedSegmentIndex = index
        }
    }
    
    @objc func backButtonTapped() {
        
        guard let viewModel = self.viewModel else {
            return
        }
        
        delegate?.navBarHomeTapped(
            navBar: self,
            remoteShareIsActive: viewModel.remoteShareIsActive.value
        )
    }

    @objc func shareButtonTapped() {
        
        guard let viewModel = self.viewModel else {
            return
        }
        
        delegate?.navBarShareTapped(
            navBar: self,
            selectedLanguage: viewModel.language
        )
    }

    @objc func didChooseLanguage(segmentedControl: UISegmentedControl) {
        
        guard let viewModel = self.viewModel else {
            return
        }
           
        viewModel.languageTapped(index: segmentedControl.selectedSegmentIndex)
        
        delegate?.navBarLanguageChanged(navBar: self)
    }
    
    private func setRemoteShareActiveNavItem(hidden: Bool) {
        
        let position: ButtonItemPosition = .right
        
        if hidden, let remoteShareActiveNavItem = self.remoteShareActiveNavItem {
            parentViewController?.removeBarButtonItem(item: remoteShareActiveNavItem, barPosition: position)
            self.remoteShareActiveNavItem = nil
        }
        else if !hidden && remoteShareActiveNavItem == nil {
            
            remoteShareActiveNavItem = parentViewController?.addBarButtonItem(
                to: .right,
                index: RightNavbarPosition.remoteShareActive.rawValue,
                animationName: "remote_share_active"
            )
        }
    }
}

