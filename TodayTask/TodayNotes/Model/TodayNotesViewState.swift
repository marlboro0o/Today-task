//
//  ViewState.swift
//  TodayTask
//
//  Created by Андрей on 18.09.2024.
//

import Foundation

struct TodayNotesViewState {
    let headerTitle: String
    let headerSubtitle: String
    let headerButtonTitle: String
    let tabs: [Tab]
    var currentType: TypeTask
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

struct Tab {
    let title: String
    let count: Int
    let type: TypeTask
}

enum TypeTask {
    case all, open, closed
}
