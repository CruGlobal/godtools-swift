//
//  ToolsTableView.swift
//  godtools
//
//  Created by Levi Eggert on 5/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolsTableView: UIView, NibBased {
    
    private var viewModel: ToolsViewModelType!
    
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
        
        tableView.register(
            UINib(nibName: ToolCell.nibName, bundle: nil),
            forCellReuseIdentifier: ToolCell.reuseIdentifier
        )
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.estimatedRowHeight = 150
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.alpha = 0
    }
    
    private func setupBinding() {
        
        viewModel.tools.addObserver(self) { [weak self] (tools: [RealmResource]) in
            self?.tableView.reloadData()
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                self?.tableView.alpha = tools.isEmpty ? 0 : 1
            }, completion: nil)
        }
        
        if viewModel.toolListIsEditable {
            
            let longPressGesture = UILongPressGestureRecognizer(
                target: self,
                action: #selector(handleLongPressForToolListEditing(gestureReconizer:))
            )
            longPressGesture.minimumPressDuration = 0.75
            tableView.addGestureRecognizer(longPressGesture)
        }
    }
    
    @objc func handleLongPressForToolListEditing(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state == UIGestureRecognizer.State.began {
            tableView.isEditing = !tableView.isEditing
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension ToolsTableView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tools.value.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let resource = viewModel.tools.value[indexPath.row]
                
        viewModel.toolTapped(resource: resource)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: ToolCell = tableView.dequeueReusableCell(
            withIdentifier: ToolCell.reuseIdentifier,
            for: indexPath) as! ToolCell

        cell.selectionStyle = .none
        
        let resource = viewModel.tools.value[indexPath.row]
        let cellViewModel = ToolCellViewModel(
            resource: resource,
            resourcesDownloaderAndCache: viewModel.resourcesDownloaderAndCache,
            favoritedResourcesCache: viewModel.favoritedResourcesCache,
            languageSettingsCache: viewModel.languageSettingsCache
        )
        
        cell.configure(viewModel: cellViewModel, delegate: self)
        
        return cell
        
        
        // TODO: Would like to implement cell view model here. ~Levi
        
        /*
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
         */
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
                
        viewModel.didEditToolList(movedSourceIndexPath: sourceIndexPath, toDestinationIndexPath: destinationIndexPath)
    }
}

// MARK: -

extension ToolsTableView: ToolCellDelegate {
    
    func toolCellAboutToolTapped(toolCell: ToolCell) {
        
        if let indexPath = tableView.indexPath(for: toolCell) {
            let resource = viewModel.tools.value[indexPath.row]
            viewModel.aboutToolTapped(resource: resource)
        }
    }
    
    func toolCellOpenToolTapped(toolCell: ToolCell) {
        
        if let indexPath = tableView.indexPath(for: toolCell) {
            let resource = viewModel.tools.value[indexPath.row]
            viewModel.openToolTapped(resource: resource)
        }
    }
    
    func toolCellFavoriteTapped(toolCell: ToolCell) {
        
        if let indexPath = tableView.indexPath(for: toolCell) {
            let resource = viewModel.tools.value[indexPath.row]
            viewModel.favoriteToolTapped(resource: resource)
        }
    }
}
