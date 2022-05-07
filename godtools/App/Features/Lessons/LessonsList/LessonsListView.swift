//
//  LessonsListView.swift
//  godtools
//
//  Created by Levi Eggert on 4/5/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class LessonsListView: UIViewController, ToolsMenuPageView {
    
    private let viewModel: LessonsListViewModelType
    private let refreshControl: UIRefreshControl = UIRefreshControl()
          
    @IBOutlet weak private var lessonsTableView: UITableView!
    @IBOutlet weak private var loadingView: UIActivityIndicatorView!
    
    required init(viewModel: LessonsListViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: LessonsListView.self), bundle: nil)
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
        
        lessonsTableView.delegate = self
        lessonsTableView.dataSource = self
        
        lessonsTableView.addSubview(refreshControl)
        refreshControl.addTarget(
            self,
            action: #selector(handleRefreshLessons),
            for: .valueChanged
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.pageViewed()
    }
    
    private func setupLayout() {
        
        // lessonsTableView
        lessonsTableView.register(
            UINib(nibName: LessonListItemView.nibName, bundle: nil),
            forCellReuseIdentifier: LessonListItemView.reuseIdentifier
        )
        lessonsTableView.rowHeight = UITableView.automaticDimension
        lessonsTableView.separatorStyle = .none
    }
    
    private func setupBinding() {
        
        viewModel.numberOfLessons.addObserver(self) { [weak self] (numberOfLessons: Int) in
            self?.lessonsTableView.reloadData()
        }
        
        viewModel.isLoading.addObserver(self) { [weak self] (isLoading: Bool) in
            isLoading ? self?.loadingView.startAnimating() : self?.loadingView.stopAnimating()
        }
        
        viewModel.didEndRefreshing.addObserver(self) { [ weak self] in
            self?.refreshControl.endRefreshing()
        }
    }
    
    @objc func handleRefreshLessons() {
        viewModel.refreshLessons()
    }
    
    func pageViewed() {
        
    }
    
    func scrollToTop(animated: Bool) {
        
        guard lessonsTableView != nil else {
            return
        }
        
        lessonsTableView.setContentOffset(.zero, animated: animated)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension LessonsListView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfLessons.value
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        viewModel.lessonTapped(index: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: LessonListItemView = lessonsTableView.dequeueReusableCell(
            withIdentifier: LessonListItemView.reuseIdentifier,
            for: indexPath) as! LessonListItemView
        
        let cellViewModel: LessonListItemViewModelType = viewModel.lessonWillAppear(index: indexPath.row)
        
        cell.configure(viewModel: cellViewModel)
        
        return cell
    }
}
