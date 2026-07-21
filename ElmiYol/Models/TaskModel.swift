//
//  TaskModel.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 16.07.26.
//

import Foundation
import UIKit
import SnapKit

struct TaskModel {
    let id: String
    var title: String
    var isCompleted: Bool
    var dueDate: Date
    var priority: TaskPriority

    init(id: String = UUID().uuidString, title: String, isCompleted: Bool = false, dueDate: Date, priority: TaskPriority = .medium) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.dueDate = dueDate
        self.priority = priority
    }
}

enum TaskPriority: String {
    case low = "Aşağı"
    case medium = "Orta"
    case high = "Yüksək"
}


protocol TaskCellDelegate: AnyObject {
    func taskCell(_ cell: UITableViewCell, didToggleCompletionFor taskId: String)
    func taskCell(_ cell: UITableViewCell, didRequestDeleteFor taskId: String)
}


final class TaskStore {
    private(set) var tasks: [TaskModel] = []

    init() {
        print("TaskStore yaradıldı")
    }

    deinit {
        print("TaskStore yaddaşdan silindi")
    }

    func add(_ task: TaskModel) {
        tasks.append(task)
    }

    func remove(id: String) {
        tasks.removeAll { $0.id == id }
    }

    func toggleCompletion(id: String) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[index].isCompleted.toggle()
    }
}
