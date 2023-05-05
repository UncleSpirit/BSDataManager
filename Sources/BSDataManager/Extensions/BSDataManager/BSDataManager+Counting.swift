//
//  BSDataManager+Counting.swift
//  
//
//  Created by Armen Sayadyan on 04.05.23.
//

import CoreData

public extension BSDataManager {
    
    // MARK: - NSNumber result
    
    func count<U>(
        for entity: NSEntityDescription,
        where predicate: NSPredicate? = nil,
        distinctResults: Bool = false
    ) throws -> U where U: NSNumber {
        let request: NSFetchRequest<U> = try request(entity: entity, predicate: predicate, distinctResults: distinctResults)
        
        return try BSDataManager.fetch(request: request, context: container.viewContext)[0]
    }
    
    func count<U>(
        for entityName: String,
        where predicate: NSPredicate? = nil,
        distinctResults: Bool = false
    ) throws -> U where U: NSNumber {
        let request: NSFetchRequest<U> = try request(entityName: entityName, predicate: predicate, distinctResults: distinctResults)
        
        return try BSDataManager.fetch(request: request, context: container.viewContext)[0]
    }
    
    func count<T, U>(
        for type: T.Type,
        where predicate: NSPredicate? = nil,
        distinctResults: Bool = false
    ) throws -> U where T: NSManagedObject, U: NSNumber {
        let request: NSFetchRequest<U> = try request(entity: T.entity(), predicate: predicate, distinctResults: distinctResults)
        
        return try BSDataManager.fetch(request: request, context: container.viewContext)[0]
    }
    
    
    // MARK: - Int result
    
    func count(
        for entity: NSEntityDescription,
        where predicate: NSPredicate? = nil,
        distinctResults: Bool = false
    ) throws -> Int {
        let result: NSNumber = try count(for: entity, where: predicate, distinctResults: distinctResults)
        
        return (result as? Int) ?? 0
    }
    
    func count(
        for entityName: String,
        where predicate: NSPredicate? = nil,
        distinctResults: Bool = false
    ) throws -> Int {
        let entity = try entity(named: entityName, in: nil /* container.viewContext */)
        
        return try count(for: entity, where: predicate, distinctResults: distinctResults)
    }
    
    func count<T>(
        for type: T.Type,
        where predicate: NSPredicate? = nil,
        distinctResults: Bool = false
    ) throws -> Int where T: NSManagedObject {
        return try count(for: T.entity(), where: predicate, distinctResults: distinctResults)
    }
    
}
