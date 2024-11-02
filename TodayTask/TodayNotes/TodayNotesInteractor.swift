//
//  TodayNotesInteractor.swift
//  TodayTask
//
//  Created by Андрей on 08.09.2024.
//

import Foundation

final class TodayNotesInteractor: TodayNotesBusinessLogic {
    
    weak var presenter: TodayNotesPresenting?
    
    private let entity: TodayNotesEntityProtocol
    private let storage = DataBaseStorage()
    
    private var viewModel: TodayNotesViewModel?
    
    init(entity: TodayNotesEntityProtocol) {
        self.entity = entity
    }
    
    func viewDidLoad() {
        if UserDefaults.standard.bool(forKey: "networkDataLoaded") {
            storageFetch()
        } else {
            networkFetch()
        }
    }
    
    // MARK: - Edit items methods
    func changeCompletedTask(for id: String) {
        guard
            let viewModel,
            let index = viewModel.items.firstIndex(where: { $0.id == id })
        else {
            return
        }
        
        let currentItem = viewModel.items[index]
        let modifyItem = TodayNotesItem(
            id: String(currentItem.id),
            title: currentItem.title,
            subtitle: currentItem.subtitle,
            creationDate: currentItem.creationDate,
            isCompleted: !currentItem.isCompleted
        )

        var items = viewModel.items
        items[index] = modifyItem
        
        storage.save(for: items) { [weak self] in
            let newViewModel = TodayNotesViewModel(items: items)
            self?.viewModel = newViewModel
            self?.presenter?.updateInterface(with: items)
        }
       
    }
    
    func createNewTask(title: String, subtitle: String){
        guard let viewModel else { return }
        
        var items = viewModel.items
        items.insert(
            TodayNotesItem(
                id: UUID().uuidString,
                title: title,
                subtitle: subtitle,
                creationDate: .now,
                isCompleted: false
            ),
            at: 0
        )
        
        storage.save(for: items) { [weak self] in
            let newViewModel = TodayNotesViewModel(items: items)
            self?.viewModel = newViewModel
            self?.presenter?.updateInterface(with: items)
        }
    }
    
    func editTask(for id: String, title: String, subtitle: String) {
        guard
            let viewModel,
            let index = viewModel.items.firstIndex(where: { $0.id == id })
        else {
            return
        }
        
        let item = viewModel.items[index]
        
        let modifyElement = TodayNotesItem(
            id: item.id,
            title: title,
            subtitle: subtitle,
            creationDate: item.creationDate,
            isCompleted: item.isCompleted
        )
        
        var items = viewModel.items
        items[index] = modifyElement

        storage.save(for: items) { [weak self] in
            let newViewModel = TodayNotesViewModel(items: items)
            self?.viewModel = newViewModel
            self?.presenter?.updateInterface(with: items)
        }
    }
    
    func deleteTask(for id: String) {
        
        guard let viewModel else { return }
        
        var items = viewModel.items
        items.removeAll(where: { $0.id == id } )
        
        storage.delete(for: id) { [weak self] in
            let newViewModel = TodayNotesViewModel(items: items)
            self?.viewModel = newViewModel
            self?.presenter?.updateInterface(with: items)
        }
    }
    
    // MARK: - Private methods
    private func storageFetch() {
        storage.fetch { [weak self] items in
            let viewModel = TodayNotesViewModel(items: items)
            self?.viewModel = viewModel
            self?.presenter?.configure(with: viewModel)
        }
    }
    
    private func networkFetch() {
        entity.fetch { result in
            DispatchQueue.main.async { [weak self] in
                guard
                    let result = try? result.get(),
                    !result.todos.isEmpty
                else {
                    self?.presenter?.showError(title: "Network error", titleButton: "try again")
                    return
                }
                let items = result.todos.map {
                    TodayNotesItem(
                        id: String($0.id),
                        title: $0.todo,
                        subtitle: "",
                        creationDate: .now,
                        isCompleted: $0.completed
                    )
                }
                self?.storage.save(for: items) {
                    let viewModel = TodayNotesViewModel(items: items)
                    self?.viewModel = viewModel
                    self?.presenter?.configure(with: viewModel)
                    
                    UserDefaults.standard.setValue(true, forKey: "networkDataLoaded")
                }
            }
        }
    }
}

