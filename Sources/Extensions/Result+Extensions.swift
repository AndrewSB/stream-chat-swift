//
//  Result+Extensions.swift
//  GetStreamChat
//
//  Created by Alexey Bukhtin on 17/04/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation

extension Result {
    
    /// Get the error from the result if it failed.
    var error: Error? {
        if case .failure(let error) = self {
            return error
        }
        
        return nil
    }
}
