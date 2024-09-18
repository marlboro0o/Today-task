//
//  TodayNotesAssemler.swift
//  TodayTask
//
//  Created by Андрей on 08.09.2024.
//

import UIKit

enum TodayNotesAssemly {
    static func createViewController() -> UIViewController {
        let interactor = TodayNotesInteractor(entity: TodayNotesEntity())
        let presenter = TodayNotesPresenter(interactor: interactor)
        let view = TodayNotesViewController(presenter: presenter)
        
        interactor.presenter = presenter
        presenter.view = view
        
        view.setup()
        
        return view
    }
}
