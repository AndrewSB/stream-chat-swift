//
//  Sorting.swift
//  StreamChat
//
//  Created by Alexey Bukhtin on 25/06/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation

/// Sorting options.
///
/// For example:
/// ```
/// // Sort channels by the last message date:
/// let sorting = Sorting<Channel.DecodingKeys>(.lastMessageDate)
/// ```
public struct Sorting<T: CodingKey>: Encodable {
    /// A sorting field name.
    public let field: String
    /// A sorting direction.
    public let direction: Int
    
    /// Init sorting options.
    ///
    /// - Parameters:
    ///     - key: a key from coding keys.
    ///     - isAscending: a diration of the sorting.
    public init(_ key: T, isAscending: Bool = false) {
        field = key.stringValue
        direction = isAscending ? 1 : -1
    }
}
