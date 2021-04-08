//
//  LessonsListView.swift
//  godtools
//
//  Created by Levi Eggert on 4/5/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class LessonsListView: UIViewController {
    
    private let viewModel: LessonsListViewModelType
          
    @IBOutlet weak private var lessonsTableView: UITableView!
    
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
    }
    
    private func setupLayout() {
        
        // lessonsTableView
        lessonsTableView.rowHeight = UITableView.automaticDimension
        lessonsTableView.separatorStyle = .none
    }
    
    private func setupBinding() {
        
    }
    
    func scrollToTopOfLessons(animated: Bool) {
        if lessonsTableView != nil {
            lessonsTableView.setContentOffset(.zero, animated: animated)
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension LessonsListView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
