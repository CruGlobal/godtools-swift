//
//  ToolsTableView.swift
//  godtools
//
//  Created by Levi Eggert on 5/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolsTableView: UIView, NibBased {
    
    private let refreshControl: UIRefreshControl = UIRefreshControl()
    
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
        
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(
            self,
            action: #selector(handleRefreshTools),
            for: .valueChanged
        )
    }
    
    func configure(viewModel: ToolsViewModelType) {
        
        self.viewModel = viewModel
        
        tableView.delegate = self
        tableView.dataSource = self
        
        setupBinding()
    }
    
    private func setupLayout() {
        
        tableView.register(
            UINib(nibName: ToolCell.nibName, bundle: nil),
            forCellReuseIdentifier: ToolCell.reuseIdentifier
        )
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
        tableView.estimatedRowHeight = 220
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.alpha = 0
    }
    
    private func setupBinding() {
        
        viewModel.tools.addObserver(self) { [weak self] (tools: [ResourceModel]) in

            self?.refreshControl.endRefreshing()
            self?.tableView.reloadData()
            self?.animateToolsTableAlpha(alpha: tools.isEmpty ? 0 : 1)
        }
        
        viewModel.toolRefreshed.addObserver(self) { [weak self] (indexPath: IndexPath) in
            self?.tableView.reloadRows(at: [indexPath], with: .none)
        }
        
        viewModel.toolsRemoved.addObserver(self) { [weak self] (indexPaths: [IndexPath]) in
            if !indexPaths.isEmpty {
                self?.tableView.deleteRows(at: indexPaths, with: .fade)
            }
        }
        
        if viewModel.toolListIsEditable {
            
            let longPressGesture = UILongPressGestureRecognizer(
                target: self,
                action: #selector(handleLongPressForToolListEditing(gestureReconizer:))
            )
            longPressGesture.minimumPressDuration = 0.75
            tableView.addGestureRecognizer(longPressGesture)
        }
        
        viewModel.toolListIsEditing.addObserver(self) { [weak self] (isEditing: Bool) in
            self?.tableView.isEditing = isEditing
        }
        
        viewModel.didEndRefreshing.addObserver(self) { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }
    
    @objc func handleRefreshTools() {
        viewModel.refreshTools()
    }
    
    @objc func handleLongPressForToolListEditing(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state == UIGestureRecognizer.State.began {
            tableView.isEditing = !tableView.isEditing
        }
    }
    
    private func animateToolsTableAlpha(alpha: CGFloat) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.tableView.alpha = alpha
        }, completion: nil)
    }
    
    func scrollToTopOfTools(animated: Bool) {
        
        guard tableView != nil else {
            return
        }
        
        tableView.setContentOffset(.zero, animated: animated)
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
        
        let cellViewModel = viewModel.toolWillAppear(index: indexPath.row)
        
        cell.configure(viewModel: cellViewModel, delegate: self)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
                
        viewModel.didEditToolList(
            movedResource: viewModel.tools.value[sourceIndexPath.row],
            movedSourceIndexPath: sourceIndexPath,
            toDestinationIndexPath: destinationIndexPath
        )
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
