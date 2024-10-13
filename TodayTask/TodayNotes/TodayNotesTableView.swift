//
//  TodayNotesTableView.swift
//  TodayTask
//
//  Created by Андрей on 06.10.2024.
//

import Foundation
import UIKit

class TodayNotesTableView: UITableView {
  
    func configure() {
        separatorStyle = .none
        register(TodayNotesCell.self, forCellReuseIdentifier: "NoteCell")
        backgroundColor = .clear
    }
}
