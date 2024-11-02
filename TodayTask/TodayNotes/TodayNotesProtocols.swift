//
//  TodayProtocols.swift
//  TodayTask
//
//  Created by Андрей on 08.09.2024.
//


// ViewController
protocol TodayNotesDisplayLogic: AnyObject {
    func configure(with viewState: TodayNotesViewState)
    func updateInterface(with viewState: TodayNotesViewState)
    func changeTabOutput(for index: Int, viewState: TodayNotesViewState)
    func showError(state: TodayNotesErrorViewState)
}

// Presenter
protocol TodayNotesPresenting: AnyObject {
    // view methods
    func viewDidLoad()
    func changeTab(for index: Int, viewState: TodayNotesViewState)
    func createNewTask(title: String, subtitle: String)
    func editTask(for id: String, title: String, subtitle: String)
    func deleteTask(for id: String)
    
    // interactor methods
    func configure(with viewModel: TodayNotesViewModel)
    func updateInterface(with items: [TodayNotesItem])
    func showError(title: String, titleButton: String)
}

// Interactor
protocol TodayNotesBusinessLogic {
    func viewDidLoad()
    func changeCompletedTask(for id: String)
    func createNewTask(title: String, subtitle: String)
    func editTask(for id: String, title: String, subtitle: String)
    func deleteTask(for id: String)
}

// Entity network
protocol TodayNotesEntityProtocol {
    func fetch(completion: @escaping (Result<TodayNotesModel, Error>) -> Void)
}

// Entity database
protocol TodayNotesDataBaseStoring {
    func fetch(completion: @escaping ([TodayNotesItem]) -> Void)
    func save(for items: [TodayNotesItem], completion: @escaping () -> Void)
    func delete(for id: String, completion: @escaping () -> Void) 
}
