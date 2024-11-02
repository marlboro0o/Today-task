//
//  TodayNotesEntity.swift
//  TodayTask
//
//  Created by Андрей on 08.09.2024.
//
import Foundation
import Alamofire

final class TodayNotesEntity: TodayNotesEntityProtocol {
    func fetch(completion: @escaping (Result<TodayNotesModel, Error>) -> Void) {
        let urlPath = "https://dummyjson.com/todos"
        
        AF.request(urlPath).responseData {
            (response) in
            guard let data = response.data
            else {
                completion(.failure(NSError()))
                return
            }
            
            DispatchQueue.global().async {
                guard let model = try? JSONDecoder().decode(TodayNotesModel.self, from: data)
                else {
                    completion(.failure(NSError()))
                    return
                }
                
                DispatchQueue.main.async {
                    completion(.success(model))
                }
            }
        }
    }
}
