//
//  OnboardingTutorialUsageListCell.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class OnboardingTutorialUsageListCell: UICollectionViewCell {
    
    static let nibName: String = "OnboardingTutorialUsageListCell"
    static let reuseIdentifier: String = "OnboardingTutorialUsageListCellReuseIdentifier"
    
    private var viewModel: OnboardingTutorialUsageListCellViewModel?
    
    @IBOutlet weak private var usageTableView: UITableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        usageTableView.register(
            UINib(nibName: OnboardingTutorialUsageCell.nibName, bundle: nil),
            forCellReuseIdentifier: OnboardingTutorialUsageCell.reuseIdentifier
        )
        usageTableView.separatorStyle = .none
        usageTableView.estimatedRowHeight = 80
        usageTableView.rowHeight = UITableView.automaticDimension
        usageTableView.delegate = self
        usageTableView.dataSource = self
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel = nil
    }
    
    func configure(viewModel: OnboardingTutorialUsageListCellViewModel) {
        self.viewModel = viewModel
        usageTableView.reloadData()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension OnboardingTutorialUsageListCell: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.usageListItem.usageItems.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: OnboardingTutorialUsageCell = usageTableView.dequeueReusableCell(
            withIdentifier: OnboardingTutorialUsageCell.reuseIdentifier,
            for: indexPath) as! OnboardingTutorialUsageCell
        
        cell.selectionStyle = .none
        
        let usageItems: [OnboardingTutorialUsageItem] = viewModel?.usageListItem.usageItems ?? []
        let usageItem: OnboardingTutorialUsageItem = usageItems[indexPath.row]
        
        cell.configure(viewModel: OnboardingTutorialUsageCellViewModel(item: usageItem))
        
        return cell
    }
}

