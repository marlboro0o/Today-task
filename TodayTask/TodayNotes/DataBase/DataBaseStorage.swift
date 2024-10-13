//
//  DataBaseEnity.swift
//  TodayTask
//
//  Created by Андрей on 15.09.2024.
//

import Foundation
import CoreData

final class DataBaseStorage: TodayNotesDataBaseStoring {
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "NotesItem")
        container.loadPersistentStores { store, error in
            if let error = error as? NSError {
                assertionFailure("123")
            }
        }
        return container
    }()
    
    lazy var context: NSManagedObjectContext = {
        persistentContainer.viewContext
    }()
    
    lazy var backgroundContext: NSManagedObjectContext = {
        persistentContainer.newBackgroundContext()
    }()
    
    func fetch(completion: @escaping ([TodayNotesItem]) -> Void) {
        
        DispatchQueue.global().async {
            let request: NSFetchRequest<NotesItem> = NotesItem.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            let result = try? self.context.fetch(request)
            let items = result?.compactMap {
                TodayNotesItem(for: $0)
            }
            
            DispatchQueue.main.async {
                completion(items ?? [])
            }
        }
    }
    
    func save(for items: [TodayNotesItem], completion: @escaping () -> Void) {
        DispatchQueue.global().async {
            items.forEach { element in
                let fetchRequest: NSFetchRequest<NotesItem> = NotesItem.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %@", element.id)
                
                do {
                    let result = try self.context.fetch(fetchRequest)
                    if result.isEmpty {
                        guard
                            let item = NSEntityDescription.insertNewObject(
                                forEntityName: "NotesItem",
                                into: self.backgroundContext
                            ) as? NotesItem
                        else {
                            return
                        }
                        item.id = element.id
                        item.title = element.title
                        item.subtitle = element.subtitle
                        item.creationDate = element.creationDate
                        item.isCompleted = element.isCompleted
                        
                        do {
                            try self.backgroundContext.save()
                        } catch {
                            assertionFailure(error.localizedDescription)
                        }
                    } else {
                        result[0].title = element.title
                        result[0].subtitle = element.subtitle
                        result[0].creationDate = element.creationDate
                        result[0].isCompleted = element.isCompleted
                    }
                } catch {
                    assertionFailure(error.localizedDescription)
                }
            }
            if self.context.hasChanges {
                do {
                    try self.context.save()
                } catch {
                    assertionFailure(error.localizedDescription)
                }
            }
 
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func delete(for id: String, completion: @escaping () -> Void) {
        DispatchQueue.global().async {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "NotesItem")
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
            
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try self.context.execute(deleteRequest)
            } catch {
                print(error.localizedDescription)
            }
            
            DispatchQueue.main.async {
                completion()
            }
        }
    }
}

