//
//  Bundle.swift
//  
//
//  Created by Armen Sayadyan on 04.05.23.
//

import Foundation

public extension Bundle {
    
    var name: String {
        return self.bundleURL.deletingPathExtension().lastPathComponent
    }
    
    var isMainBundle: Bool {
        return Bundle.main.bundlePath == bundlePath
    }
    
}
