//
//  ChannelsQuery.swift
//  StreamChat
//
//  Created by Alexey Bukhtin on 17/05/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation

/// A channels query.
public struct ChannelsQuery: Encodable {
    private enum CodingKeys: String, CodingKey {
        case filter = "filter_conditions"
        case sort
        case user = "user_details"
        case state
        case watch
        case presence
        case pagination
        case messageLimit = "message_limit"
    }
    
    /// A filter for the query (see `Filter`).
    let filter: Filter<Channel.DecodingKeys>
    /// A sorting for the query (see `Filter`).
    let sort: [Sorting<Channel.DecodingKeys>]
    /// A current user (see `Client.shread.user`).
    let user: User
    /// A pagination.
    let pagination: Pagination
    /// A number of messages inside each channel.
    let messageLimit = Pagination.messagesPageSize
    let state = true
    let watch = true
    let presence = false
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(filter, forKey: .filter)
        try container.encode(sort, forKey: .sort)
        try container.encode(user, forKey: .user)
        try container.encode(state, forKey: .state)
        try container.encode(watch, forKey: .watch)
        try container.encode(presence, forKey: .presence)
        try container.encode(messageLimit.limit, forKey: .messageLimit)
        try pagination.encode(to: encoder)
    }
}

// MARK: - Channels Response

/// A channels query response.
public struct ChannelsResponse: Decodable {
    let channels: [ChannelQuery]
}
