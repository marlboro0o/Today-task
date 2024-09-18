//
//  TodayNotesModel.swift
//  TodayTask
//
//  Created by Андрей on 08.09.2024.
//
import Foundation

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

