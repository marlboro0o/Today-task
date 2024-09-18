//
//  TodayNotesModel.swift
//  TodayTask
//
//  Created by Андрей on 08.09.2024.
//

import Foundation

struct TodayNotesViewState {
    let headerTitle: String
    let headerSubtitle: String
    let headerButtonTitle: String
    let tabs: [Tab] // Табики сверху
    var currentType: TypeTask // Выбранный таб
    var items: [TodayNotesCellViewState]
}

struct TodayNotesCellViewState: Equatable, CustomStringConvertible {
    
    let id: String
    let title: String
    let subtitle: String?
    let createdDate: Date
    let createdDateDay: String
    let createdDateTime: String
    let isCompleted: Bool
    
    let action: (() -> Void)?
    
    var description: String {
        "Task #\(id)"
    }
    
    static func == (lhs: TodayNotesCellViewState, rhs: TodayNotesCellViewState) -> Bool {
        lhs.id == rhs.id
    }
}

struct TodayNotesViewModel {
    let items: [TodayNotesItem]
}

struct TodayNotesItem {
    let id: String
    let title: String
    let subtitle: String?
    let creationDate: Date
    let isCompleted: Bool
    
    init(id: String, title: String, subtitle: String?, creationDate: Date, isCompleted: Bool) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.creationDate = creationDate
        self.isCompleted = isCompleted
    }
    
    init?(for item: NotesItem) {
        guard
            let id = item.id,
            let title = item.title,
            let creationDate = item.creationDate
        else { return nil }
        self.id = id
        self.title = title
        self.subtitle = item.subtitle
        self.creationDate = creationDate
        self.isCompleted = item.isCompleted
    }
}

struct Tab {
    let title: String
    let count: Int
    let type: TypeTask
}

struct TodayNotesModel: Decodable {
    var todos: [Todo]
}

struct Todo: Decodable {
    let id: Int
    var todo: String
    var completed: Bool
    
    enum CodingKeys: CodingKey {
        case id, todo, completed
    }
}

enum TypeTask {
    case all, open, closed
}
