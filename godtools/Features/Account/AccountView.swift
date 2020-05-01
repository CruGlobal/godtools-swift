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
    @IBOutlet weak private var itemsControl: GTSegmentedControl!
    @IBOutlet weak private var itemsCollectionView: UICollectionView!
    
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
        
        itemsCollectionView.delegate = self
        itemsCollectionView.dataSource = self
    }
    
    private func setupLayout() {
        
        nameLabel.text = ""
        
        itemsControl.layer.shadowColor = UIColor.black.cgColor
        itemsControl.layer.shadowOffset = CGSize(width: 0, height: 1)
        itemsControl.layer.shadowRadius = 5
        itemsControl.layer.shadowOpacity = 0.3
        
        itemsCollectionView.register(
            UINib(nibName: AccountItemCell.nibName, bundle: nil),
            forCellWithReuseIdentifier: AccountItemCell.reuseIdentifier
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
        
        viewModel.profileName.addObserver(self) { [weak self] (nameTuple: (name: String, animated: Bool)) in
            self?.nameLabel.text = nameTuple.name
            self?.nameLabel.alpha = 1
            if nameTuple.animated {
                self?.nameLabel.alpha = 0
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                    self?.nameLabel.alpha = 1
                }, completion: nil)
            }
        }
        
        viewModel.isLoadingProfile.addObserver(self) { [weak self] (isLoading: Bool) in
            isLoading ? self?.loadingProfileView.startAnimating() : self?.loadingProfileView.stopAnimating()
        }
        
        itemsControl.configure(
            segments: viewModel.items,
            delegate: nil
        )
    }
    
    @objc func handleSettings(barButtonItem: UIBarButtonItem) {
        viewModel.settingsTapped()
    }
}

extension AccountView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
                        
        let cell: AccountItemCell = itemsCollectionView.dequeueReusableCell(
            withReuseIdentifier: AccountItemCell.reuseIdentifier,
            for: indexPath) as! AccountItemCell
        
        cell.configure(
            viewModel: AccountItemCellViewModel(
                item: viewModel.items[indexPath.row],
                globalActivityServices: viewModel.globalActivityServices
            ),
            delegate: self
        )
        
        cell.backgroundColor = .systemPink
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return itemsCollectionView.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// MARK: - AccountItemCellDelegate

extension AccountView: AccountItemCellDelegate {
    
    func accountItemCellDidProcessAlertMessage(cell: AccountItemCell, alertMessage: AlertMessage) {
        
        let viewModel = AlertMessageViewModel(title: alertMessage.title, message: alertMessage.message, handler: nil)
        let view = AlertMessageView(viewModel: viewModel)
        
        present(view.controller, animated: true, completion: nil)
    }
}
