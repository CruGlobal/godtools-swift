//
//  AccountView.swift
//  godtools
//
//  Created by Levi Eggert on 2/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class AccountView: UIViewController {
    
    private let viewModel: AccountViewModelType
        
    @IBOutlet weak private var headerView: UIView!
    @IBOutlet weak private var nameLabel: UILabel!
    @IBOutlet weak private var loadingProfileView: UIActivityIndicatorView!
    @IBOutlet weak private var accountItemsPagesView: PageNavigationCollectionView!
    @IBOutlet weak private var itemsControl: GTSegmentedControl!
    
    required init(viewModel: AccountViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: AccountView.self), bundle: nil)
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
        
        addDefaultNavBackItem()
        
        accountItemsPagesView.delegate = self
    }
    
    private func setupLayout() {
        
        nameLabel.text = ""
        
        itemsControl.layer.shadowColor = UIColor.black.cgColor
        itemsControl.layer.shadowOffset = CGSize(width: 0, height: 1)
        itemsControl.layer.shadowRadius = 5
        itemsControl.layer.shadowOpacity = 0.3
        
        accountItemsPagesView.registerPageCell(
            nib: UINib(nibName: AccountItemCell.nibName, bundle: nil),
            cellReuseIdentifier: AccountItemCell.reuseIdentifier
        )

        // TODO: Add navigation gear icon in the future.  Disabling for now.  02/24/20.
//        _ = addBarButtonItem(
//            to: .right,
//            image: ImageCatalog.navSettings.image,
//            color: nil,
//            target: self,
//            action: #selector(handleSettings(barButtonItem:))
//        )
    }
    
    private func setupBinding() {
        
        title = viewModel.navTitle
        
        viewModel.profileName.addObserver(self) { [weak self] (animatableValue: AnimatableValue<String>) in
            
            self?.nameLabel.text = animatableValue.value
            self?.nameLabel.alpha = 1
            
            if animatableValue.animated {
                self?.nameLabel.alpha = 0
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                    self?.nameLabel.alpha = 1
                }, completion: nil)
            }
        }
        
        viewModel.isLoadingProfile.addObserver(self) { [weak self] (isLoading: Bool) in
            isLoading ? self?.loadingProfileView.startAnimating() : self?.loadingProfileView.stopAnimating()
        }
        
        viewModel.accountItems.addObserver(self) { [weak self] (items: [AccountItem]) in
            
            self?.itemsControl.configure(
                segments: items,
                delegate: nil
            )
            
            self?.accountItemsPagesView.reloadData()
        }
    }
    
    @objc func handleSettings(barButtonItem: UIBarButtonItem) {
        viewModel.settingsTapped()
    }
}

// MARK: - PageNavigationCollectionViewDelegate

extension AccountView: PageNavigationCollectionViewDelegate {
    
    func pageNavigationNumberOfPages(pageNavigation: PageNavigationCollectionView) -> Int {
        return viewModel.accountItems.value.count
    }
    
    func pageNavigation(pageNavigation: PageNavigationCollectionView, cellForPageAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: AccountItemCell = accountItemsPagesView.getReusablePageCell(
            cellReuseIdentifier: AccountItemCell.reuseIdentifier,
            indexPath: indexPath) as! AccountItemCell
        
        cell.configure(
            viewModel: AccountItemCellViewModel(
                item: viewModel.accountItems.value[indexPath.row],
                localizationServices: viewModel.localizationServices,
                globalAnalyticsService: viewModel.globalAnalyticsService
            ),
            delegate: self
        )
        
        cell.backgroundColor = .systemPink
        
        return cell
    }
    
    func pageNavigationPageDidAppear(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int) {
        viewModel.accountPageDidAppear(page: page)
    }
}

// MARK: - AccountItemCellDelegate

extension AccountView: AccountItemCellDelegate {
    
    func accountItemCellDidProcessAlertMessage(cell: AccountItemCell, alertMessage: AlertMessageType) {
        
        let viewModel = AlertMessageViewModel(
            title: alertMessage.title,
            message: alertMessage.message,
            cancelTitle: nil,
            acceptTitle: "OK",
            acceptHandler: nil
        )
        let view = AlertMessageView(viewModel: viewModel)
        
        present(view.controller, animated: true, completion: nil)
    }
}
