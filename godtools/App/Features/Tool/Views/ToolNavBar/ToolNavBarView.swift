//
//  ToolNavBarView.swift
//  godtools
//
//  Created by Levi Eggert on 11/16/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

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
    
    override init() {
        super.init()
    }
    
    func configure(parentViewController: UIViewController, viewModel: ToolNavBarViewModelType) {
        
        guard !isConfigured else {
            return
        }
        isConfigured = true
        
        self.parentViewController = parentViewController
        self.viewModel = viewModel
        
        setupNavigationBar(parentViewController: parentViewController, viewModel: viewModel)
        setupBinding(viewModel: viewModel)
    }
    
    private func setupNavigationBar(parentViewController: UIViewController, viewModel: ToolNavBarViewModelType) {
        
        let navigationController: UINavigationController? = parentViewController.navigationController
        let navBarColor: UIColor = viewModel.navBarColor
        let navBarControlColor: UIColor = viewModel.navBarControlColor
             
        parentViewController.title = viewModel.navTitle
        
        navigationController?.navigationBar.barTintColor = .clear
        navigationController?.navigationBar.tintColor = navBarControlColor
        navigationController?.navigationBar.setBackgroundImage(UIImage.createImageWithColor(color: navBarColor), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = .clear
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: navBarControlColor,
            NSAttributedString.Key.font: viewModel.navBarFont
        ]
        
        _ = parentViewController.addBarButtonItem(
            to: .left,
            image: ImageCatalog.navHome.image,
            color: navBarControlColor,
            target: self,
            action: #selector(handleHome(barButtonItem:))
        )
        
        if !viewModel.hidesShareButton {
            
            _ = parentViewController.addBarButtonItem(
                to: .right,
                index: RightNavbarPosition.shareMenu.rawValue,
                image: ImageCatalog.navShare.image,
                color: navBarControlColor,
                target: self,
                action: #selector(handleShare(barButtonItem:))
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
    
    @objc func handleHome(barButtonItem: UIBarButtonItem) {
        viewModel?.navHomeTapped()
    }
    
    @objc func handleShare(barButtonItem: UIBarButtonItem) {
        viewModel?.shareTapped()
    }
    
    @objc func didChooseLanguage(segmentedControl: UISegmentedControl) {
        viewModel?.languageTapped(index: segmentedControl.selectedSegmentIndex)
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
                image: ImageCatalog.shareToolRemoteSessionActive.image,
                color: .white,
                target: nil,
                action: nil
            )
        }
    }
}

