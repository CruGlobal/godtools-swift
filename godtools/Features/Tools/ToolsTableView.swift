//
//  ToolsTableView.swift
//  godtools
//
//  Created by Levi Eggert on 5/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolsTableView: UIView, NibBased {
    
    private var viewModel: ToolsViewModelType?
    
    @IBOutlet weak private var tableView: UITableView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        fatalError("init(frame:) has not been implemented")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        loadNib()
                
        setupLayout()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @objc func reloadTableView() {
        tableView.reloadData()
    }
    
    func configure(viewModel: ToolsViewModelType) {
        
        self.viewModel = viewModel
        
        setupBinding()
    }
    
    private func setupLayout() {
        
//        tableView.register(
//            UINib(nibName: ToolCell.nibName, bundle: nil),
//            forCellReuseIdentifier: ToolCell.reuseIdentifier
//        )
        
        tableView.register(
            UINib(nibName: String(describing:HomeToolTableViewCell.self), bundle: nil),
            forCellReuseIdentifier: ToolsManager.toolCellIdentifier
        )
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = 200//UITableView.automaticDimension
        tableView.separatorStyle = .none
    }
    
    private func setupBinding() {
        
        viewModel?.tools.addObserver(self) { [weak self] (tools: [DownloadedResource]) in
            self?.tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension ToolsTableView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.tools.value.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let viewModel = self.viewModel else {
            assertionFailure("ToolsTableView not configured.  Be sure to call configure after view is loaded.")
            return
        }
        
        let resource: DownloadedResource = viewModel.tools.value[indexPath.row]
                
        viewModel.toolTapped(resource: resource)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        let cell: ToolCell = tableView.dequeueReusableCell(
//            withIdentifier: ToolCell.reuseIdentifier,
//            for: indexPath) as! ToolCell
//
//        cell.selectionStyle = .none
//
//        return cell
        
        
        // TODO: Would like to implement cell view model here. ~Levi
        
        let cell: HomeToolTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: ToolsManager.toolCellIdentifier,
            for: indexPath) as! HomeToolTableViewCell
        
        guard let viewModel = self.viewModel else {
            assertionFailure("ToolsTableView not configured.  Be sure to call configure after view is loaded.")
            return cell
        }
        
        let resource: DownloadedResource = viewModel.tools.value[indexPath.row]
        let languagesManager = LanguagesManager()
        
        cell.configure(resource: resource,
        primaryLanguage: languagesManager.loadPrimaryLanguageFromDisk(),
        parallelLanguage: languagesManager.loadParallelLanguageFromDisk(),
        banner: BannerManager().loadFor(remoteId: resource.bannerRemoteId),
        delegate: self)
                
        return cell
    }
}

// MARK: - HomeToolTableViewCellDelegate

extension ToolsTableView: HomeToolTableViewCellDelegate {
    
    // TODO: Add delegate to cell for favorite tapped and unfavorite tapped. ~Levi
    func downloadButtonWasPressed(resource: DownloadedResource) {
        
        // TODO: Don't pass resource from cell.  Cell should have no reference to DownloadedResource. ~Levi
        
        viewModel?.favoriteTapped(resource: resource)
    }
    
    // TODO: Change to tool detail tapped. ~Levi
    func infoButtonWasPressed(resource: DownloadedResource) {
        
        // TODO: Don't pass resource from cell.  Cell should have no reference to DownloadedResource. ~Levi
        
        viewModel?.toolDetailsTapped(resource: resource)
    }
}
