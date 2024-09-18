//
//  TodayPresenter.swift
//  TodayTask
//
//  Created by Андрей on 08.09.2024.
//

import Foundation

final class TodayNotesPresenter: TodayNotesPresenting {
    
    weak var view: TodayNotesDisplayLogic?
    
    private let interactor: TodayNotesBusinessLogic
    private var viewState: TodayNotesViewState?
    
    init(interactor: TodayNotesBusinessLogic) {
        self.interactor = interactor
    }
    
    //MARK: - PRESENTER METODS
    func viewDidLoad() {
        interactor.viewDidLoad()
    }
    
    
    func changeTab(for index: Int, viewState: TodayNotesViewState) {
        
        let currentType = viewState.tabs[index].type
        
        if currentType == viewState.currentType {
            return
        }
        
        self.viewState?.currentType = currentType
        
        DispatchQueue.global().async {
            
            guard let currentViewState = self.viewState else { return }

            let items = currentViewState.items.filterItemsByType(type: currentType)
            let newViewState = self.makeViewState(viewState: viewState, items: items)
            
            DispatchQueue.main.async {
                self.view?.changeTab(for: index, viewState: newViewState)
            }
        }
    }
    
    func createNewTask(title: String, subtitle: String) {
        self.interactor.createNewTask(title: title, subtitle: subtitle)
    }
    
    func editTask(for id: String, title: String, subtitle: String) {
        self.interactor.editTask(for: id, title: title, subtitle: subtitle)
    }
    
    func deleteTask(for id: String) {
        self.interactor.deleteTask(for: id)
    }
    
    //MARK: - INTERACTOR METODS
    func configure(with viewModel: TodayNotesViewModel) {
        let items = mapItems(for: viewModel.items)
        let viewState = makeViewState(items: items)
        self.viewState = viewState
        view?.configure(with: viewState)
    }
    
    func updateInterface(with items: [TodayNotesItem]) {
        
        guard let viewState else { return }
        
        let items = mapItems(for: items)
        var newViewState = makeViewState(viewState: viewState, items: items)
        self.viewState = newViewState
        
        newViewState.items = newViewState.items.filterItemsByType(type: viewState.currentType)
        self.view?.updateInterface(with: newViewState)
    }
    
    func showError() {
        view?.showError()
    }
    
    //MARK: - Private methods
    private func changeCompletedTask(for id: String) {
        interactor.changeCompletedTask(for: id)
    }
    
    
    //MARK: - HELPERS
    private func makeTabs(for items: [TodayNotesCellViewState]) -> [Tab] {
        [
            Tab(title: "All", count: items.filterItemsByType(type: .all).count, type: .all),
            Tab(title: "Open", count: items.filterItemsByType(type: .open).count, type: .open),
            Tab(title: "Closed", count: items.filterItemsByType(type: .closed).count, type: .closed)
        ]
    }
    
    private func mapItems(for items: [TodayNotesItem]) -> [TodayNotesCellViewState] {
        items.map { element in
            TodayNotesCellViewState(
                id: element.id,
                title: element.title,
                subtitle: element.subtitle == "" ? "\(String(element.title.prefix(15)))..." : element.subtitle,
                createdDate: element.creationDate,
                createdDateDay: formatterCreateDateDay(for: element.creationDate),
                createdDateTime: formatterCreateDateTime(for: element.creationDate),
                isCompleted: element.isCompleted,
                action: { [weak self] in
                    self?.changeCompletedTask(for: element.id)
                }
            )
        }
    }
    
    private func makeViewState(viewState: TodayNotesViewState? = nil, items: [TodayNotesCellViewState]) -> TodayNotesViewState {
       
        if let viewState {
            return TodayNotesViewState(
                headerTitle: viewState.headerTitle,
                headerSubtitle: viewState.headerSubtitle,
                headerButtonTitle: viewState.headerButtonTitle,
                tabs: makeTabs(for: items),
                currentType: viewState.currentType,
                items: items
            )
        } else {
            return TodayNotesViewState(
                headerTitle: "Today's Task",
                headerSubtitle: formatterSubTitle(date: .now),
                headerButtonTitle: "+ New Task",
                tabs: makeTabs(for: items),
                currentType: .all,
                items: items
            )
        }
    }
    
    private func formatterDate(from date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        
        return formatter.string(from: date)
    }
    
    private func formatterSubTitle(date: Date) -> String {
        formatterDate(from: date, format: "EEEE, dd MMMM")
    }
    
    private func formatterCreateDateTime(for createDate: Date) -> String {
        formatterDate(from: createDate, format: "hh:mm a")
    }
    
    private func formatterCreateDateDay(for date: Date) -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            return formatterDate(from: date, format: "dd MMMM")
        }
    }
}

extension Array where Element == TodayNotesCellViewState {
    func filterItemsByType(type: TypeTask) -> [TodayNotesCellViewState] {
        filter { element in
            switch type {
            case .all:
                return true
            case .open:
                return !element.isCompleted
            case .closed:
                return element.isCompleted
            }
        }
    }
}
