//
//  Array+Extensions.swift
//
//  Created by Dedecube on 22/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

/**
Array utilities
*/
public extension Array where Element: Equatable
{
    /**
     This method remove an object from an array
     - Parameter object: object to be removed
     */
    public mutating func remove(_ object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
}
