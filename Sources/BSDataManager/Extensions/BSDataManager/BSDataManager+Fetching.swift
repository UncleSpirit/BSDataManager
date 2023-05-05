//
//  BSDataManager+Fetching.swift
//  
//
//  Created by Armen Sayadyan on 04.05.23.
//

import CoreData

public extension BSDataManager {
    
    // MARK: - NSManagedObject
    
    func fetch<T>(
        for entity: NSEntityDescription,
        asFaults: Bool = true,
        where predicate: NSPredicate? = nil,
        sortBy sortDescriptors: [NSSortDescriptor]? = nil
    ) throws -> [T] where T: NSManagedObject {
        let request: NSFetchRequest<T> = try request(entity: entity, asFaults: asFaults, predicate: predicate, sortDescriptors: sortDescriptors)
        
        return try BSDataManager.fetch(request: request, context: container.viewContext)
    }
    
    func fetch<T>(
        for entityName: String,
        asFaults: Bool = true,
        where predicate: NSPredicate? = nil,
        sortBy sortDescriptors: [NSSortDescriptor]? = nil
    ) throws -> [T] where T: NSManagedObject {
        let request: NSFetchRequest<T> = try request(entityName: entityName, asFaults: asFaults, predicate: predicate, sortDescriptors: sortDescriptors)
        
        return try BSDataManager.fetch(request: request, context: container.viewContext)
    }
    
    func fetch<T>(
        asFaults: Bool = true,
        where predicate: NSPredicate? = nil,
        sortBy sortDescriptors: [NSSortDescriptor]? = nil
    ) throws -> [T] where T: NSManagedObject {
        let request: NSFetchRequest<T> = try request(forType: T.self, asFaults: asFaults, predicate: predicate, sortDescriptors: sortDescriptors)
        
        return try BSDataManager.fetch(request: request, context: container.viewContext)
    }
    
    
    
    // MARK: - NSManagedObjectID
    
    func fetch<U>(
        for entity: NSEntityDescription,
        asFaults: Bool = true,
        where predicate: NSPredicate? = nil,
        sortBy sortDescriptors: [NSSortDescriptor]? = nil
    ) throws -> [U] where U: NSManagedObjectID {
        let request: NSFetchRequest<U> = try request(entity: entity, asFaults: asFaults, predicate: predicate, sortDescriptors: sortDescriptors)
        
        return try BSDataManager.fetch(request: request, context: container.viewContext)
    }
    
    func fetch<U>(
        for entityName: String,
        asFaults: Bool = true,
        where predicate: NSPredicate? = nil,
        sortBy sortDescriptors: [NSSortDescriptor]? = nil
    ) throws -> [U] where U: NSManagedObjectID {
        let request: NSFetchRequest<U> = try request(entityName: entityName, asFaults: asFaults, predicate: predicate, sortDescriptors: sortDescriptors)
        
        return try BSDataManager.fetch(request: request, context: container.viewContext)
    }
    
    func fetch<T, U>(
        for type: T.Type,
        asFaults: Bool = true,
        where predicate: NSPredicate? = nil,
        sortBy sortDescriptors: [NSSortDescriptor]? = nil
    ) throws -> [U] where T: NSManagedObject, U: NSManagedObjectID {
        let request: NSFetchRequest<U> = try request(forType: T.self, asFaults: asFaults, predicate: predicate, sortDescriptors: sortDescriptors)
        
        return try BSDataManager.fetch(request: request, context: container.viewContext)
    }
    
    
    
    // MARK: - NSDictionary
    
    func fetch<U>(
        for entity: NSEntityDescription,
        where predicate: NSPredicate? = nil,
        sortBy sortDescriptors: [NSSortDescriptor]? = nil,
        fields: [String]? = nil,
        distinctResults: Bool = false,
        groupBy: [String]? = nil,
        havingPredicate: NSPredicate? = nil
    ) throws -> [U] where U: NSDictionary {
        let request: NSFetchRequest<U> = try request(entity: entity, asFaults: false, predicate: predicate, sortDescriptors: sortDescriptors, fields: fields, distinctResults: distinctResults, groupBy: groupBy, havingPredicate: havingPredicate)
        
        return try BSDataManager.fetch(request: request, context: container.viewContext)
    }
    
    func fetch<U>(
        for entityName: String,
        where predicate: NSPredicate? = nil,
        sortBy sortDescriptors: [NSSortDescriptor]? = nil,
        fields: [String]? = nil,
        distinctResults: Bool = false,
        groupBy: [String]? = nil,
        havingPredicate: NSPredicate? = nil
    ) throws -> [U] where U: NSDictionary {
        let request: NSFetchRequest<U> = try request(entityName: entityName, asFaults: false, predicate: predicate, sortDescriptors: sortDescriptors, fields: fields, distinctResults: distinctResults, groupBy: groupBy, havingPredicate: havingPredicate)
        
        return try BSDataManager.fetch(request: request, context: container.viewContext)
    }
    
    func fetch<T, U>(
        for type: T.Type,
        where predicate: NSPredicate? = nil,
        sortBy sortDescriptors: [NSSortDescriptor]? = nil,
        fields: [String]? = nil,
        distinctResults: Bool = false,
        groupBy: [String]? = nil,
        havingPredicate: NSPredicate? = nil
    ) throws -> [U] where T: NSManagedObject, U: NSDictionary {
        let request: NSFetchRequest<U> = try request(forType: T.self, asFaults: false, predicate: predicate, sortDescriptors: sortDescriptors, fields: fields, distinctResults: distinctResults, groupBy: groupBy, havingPredicate: havingPredicate)
        
        return try BSDataManager.fetch(request: request, context: container.viewContext)
    }
    
    
    
    // MARK: - Swift Dictionary
    
    func fetchDict(
        for entity: NSEntityDescription,
        where predicate: NSPredicate? = nil,
        sortBy sortDescriptors: [NSSortDescriptor]? = nil,
        fields: [String]? = nil,
        distinctResults: Bool = false,
        groupBy: [String]? = nil,
        havingPredicate: NSPredicate? = nil
    ) throws -> [[String : Any]] {
        let result: [NSDictionary] = try fetch(for: entity, where: predicate, sortBy: sortDescriptors, fields: fields, distinctResults: distinctResults, groupBy: groupBy, havingPredicate: havingPredicate)
        
        return result.lazy.map {
            $0 as! [String : Any]
        }
    }
    
    func fetchDict(
        for entityName: String,
        where predicate: NSPredicate? = nil,
        sortBy sortDescriptors: [NSSortDescriptor]? = nil,
        fields: [String]? = nil,
        distinctResults: Bool = false,
        groupBy: [String]? = nil,
        havingPredicate: NSPredicate? = nil
    ) throws -> [[String : Any]] {
        let result: [NSDictionary] = try fetch(for: entityName, where: predicate, sortBy: sortDescriptors, fields: fields, distinctResults: distinctResults, groupBy: groupBy, havingPredicate: havingPredicate)
        
        return result.lazy.map {
            $0 as! [String : Any]
        }
    }
    
    func fetchDict<T>(
        for type: T.Type,
        where predicate: NSPredicate? = nil,
        sortBy sortDescriptors: [NSSortDescriptor]? = nil,
        fields: [String]? = nil,
        distinctResults: Bool = false,
        groupBy: [String]? = nil,
        havingPredicate: NSPredicate? = nil
    ) throws -> [[String : Any]] where T: NSManagedObject {
        let result: [NSDictionary] = try fetch(for: type.entity(), where: predicate, sortBy: sortDescriptors, fields: fields, distinctResults: distinctResults, groupBy: groupBy, havingPredicate: havingPredicate)
        
        return result.lazy.map {
            $0 as! [String : Any]
        }
    }
    
}
