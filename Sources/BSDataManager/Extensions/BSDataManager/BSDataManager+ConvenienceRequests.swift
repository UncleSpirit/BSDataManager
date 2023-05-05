//
//  BSDataManager+ConvenienceRequests.swift
//  
//
//  Created by Armen Sayadyan on 04.05.23.
//

import CoreData

public extension BSDataManager {
    
    func request<T, U>(for type: T.Type) throws -> NSFetchRequest<U> where T: NSManagedObject, U: NSManagedObjectID {
        let retVal: NSFetchRequest<U> = try request(forType: type)
        return retVal
    }
    
    func request<T, U>(for type: T.Type) throws -> NSFetchRequest<U> where T: NSManagedObject, U: NSDictionary {
        let retVal: NSFetchRequest<U> = try request(forType: type)
        return retVal
    }
    
    func request<T, U>(for type: T.Type) throws -> NSFetchRequest<U> where T: NSManagedObject, U: NSNumber {
        let retVal: NSFetchRequest<U> = try request(forType: type)
        return retVal
    }
    
    func request<T: NSManagedObject>() throws -> NSFetchRequest<T> {
        return try request(forType: T.self)
    }
    
}
