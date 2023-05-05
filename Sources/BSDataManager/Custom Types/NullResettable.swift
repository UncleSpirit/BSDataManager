//
//  NullResettable.swift
//  
//
//  Created by Armen Sayadyan on 04.05.23.
//

import Foundation

@propertyWrapper
public class NullResettable<T> {
    private var innerValue: T?
    private var defaultValue: T?
    
    public var wrappedValue: T? {
        get {
            return innerValue ?? defaultValue
        }
        set {
            innerValue = newValue
        }
    }
    
    public init(wrappedValue: T? = nil, defaultValue: T) {
        innerValue = wrappedValue
        self.defaultValue = defaultValue
    }
}
