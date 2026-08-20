//
//  TaskBag.swift
//  godtools
//
//  Created by Levi Eggert on 8/20/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class TaskBag {
    
    private var cancelTasks: [() -> Void] = Array()
    
    init() {
        
    }
    
    deinit {
        cancelAll()
    }
    
    func add(cancelTask: @escaping () -> Void) {
        
        cancelTasks.append(cancelTask)
    }
    
    func cancelAll() {
        
        let cancelTasksToExecute: [() -> Void] = cancelTasks
        
        cancelTasks.removeAll()
        
        for cancelTask in cancelTasksToExecute {
            cancelTask()
        }
    }
}

extension Task {
    
    func store(in taskBag: TaskBag) {
        
        taskBag.add(cancelTask: cancel)
    }
}
