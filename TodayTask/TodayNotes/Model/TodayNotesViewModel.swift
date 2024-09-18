//
//  ViewModel.swift
//  TodayTask
//
//  Created by Андрей on 18.09.2024.
//

import Foundation

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
