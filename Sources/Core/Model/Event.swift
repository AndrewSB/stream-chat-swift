//
//  Event.swift
//  StreamChatCore
//
//  Created by Alexey Bukhtin on 01/04/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation

/// A web socket event type.
public enum EventType: String, Codable {
    /// When a user status changes, e.g. online, offline, away (when subscribed to the user status 🙋‍♀️).
    case userPresenceChanged = "user.presence.changed"
    /// When a user starts watching a channel (when watching the channel 📺).
    case userStartWatching = "user.watching.start"
    /// When a user stops watching a channel (when watching the channel 📺).
    case userStopWatching = "user.watching.stop"
    /// When a user is updated (when subscribed to the user status 🙋‍♀️).
    case userUpdated = "user.updated"
    /// Sent when a user starts typing (when watching the channel 📺).
    case typingStart = "typing.start"
    /// Sent when a user stops typing (when watching the channel 📺).
    case typingStop = "typing.stop"
    /// When a new message is added on a channel (when watching the channel 📺).
    case messageNew = "message.new"
    /// When a message is updated (when watching the channel 📺).
    case messageUpdated = "message.updated"
    /// When a message is deleted (when watching the channel 📺).
    case messageDeleted = "message.deleted"
    /// When a channel is marked as read (when watching the channel 📺).
    case messageRead = "message.read"
    /// ⚠️ When a message reaction is added or deleted (when watching the channel 📺).
    case messageReaction = "message.reaction"
    /// ⚠️ When a member is added to a channel (when watching the channel 📺).
    case memberAdded = "member.added"
    /// ⚠️ When a member is updated (when watching the channel 📺).
    case memberUpdated = "member.updated"
    /// ⚠️ When a member is removed from a channel (when watching the channel 📺).
    case memberRemoved = "member.removed"
    /// ⚠️ When a channel is updated (when watching the channel 📺).
    case channelUpdated = "channel.updated"
    
    /// Every 30 second to confirm that the client connection is still active (🗼).
    case healthCheck = "health.check"
    /// ⚠️ When the state of the connection changed (🗼).
    case connectionChanged = "connection.changed"
    /// ⚠️ When the connection to chat servers is back online (🗼).
    case connectionRecovered = "connection.recovered"
    
    /// When a message is added to a channel (when clients that are not currently watching the channel ⚡️).
    case notificationMessageNew = "notification.message_new"
    /// When the user mutes someone (🙋‍♀️).
    case notificationMutesUpdated = "notification.mutes_updated"
    /// When the total count of unread messages (across all channels the user is a member) changes
    /// (when clients from the user affected by the change 📺📺).
    case notificationMarkRead = "notification.mark_read"
    
    /// ⚠️ When the user is invited to join a channel (when the user invited 💌).
    case notificationInvited = "notification.invited"
    /// ⚠️ When the user accepts an invite (when the user invited 💌).
    case notificationInviteAccepted = "notification.invite_accepted"
    /// When the user accepts an invite (when the user invited 📺).
    case notificationAddedToChannel = "notification.added_to_channel"
    /// ⚠️ When a user is removed from a channel (when the user invited 📺).
    case notificationRemovedFromChannel = "notification.removed_from_channel"
    
    // Webhook event types❓
    
    /// When a message reaction is added.
    case reactionNew = "reaction.new"
    /// When a message reaction deleted.
    case reactionDeleted = "reaction.deleted"
}

/// A web socket event.
public enum Event: Decodable {
    private enum CodingKeys: String, CodingKey {
        case connectionId = "connection_id"
        case type
        case me
        case user
        case watcherCount = "watcher_count"
        case channel
        case message
        case reaction
        case unreadCount = "unread_count"
        case unreadChannels = "unread_channels"
        case totalUnreadCount = "total_unread_count"
        case created = "created_at"
    }
    
    struct ResponseTypeError: Swift.Error {
        let type: EventType
    }
    
    case healthCheck(_ connectionId: String, User?)
    
    case messageRead(MessageRead, EventType)
    case messageNew(Message, _ unreadCount: Int, _ totalUnreadCount: Int, Channel?, EventType)
    case messageDeleted(Message, EventType)
    case messageUpdated(Message, EventType)
    
    case userUpdated(User, EventType)
    case userPresenceChanged(User, EventType)
    case userStartWatching(User, _ watcherCount: Int, EventType)
    case userStopWatching(User, _ watcherCount: Int, EventType)
    
    case reactionNew(Reaction, Message, User, EventType)
    case reactionDeleted(Reaction, Message, User, EventType)
    
    case typingStart(User, EventType)
    case typingStop(User, EventType)
    
    case notificationMutesUpdated(User, EventType)
    case notificationMarkRead(_ unreadCount: Int, _ totalUnreadCount: Int, _ unreadChannels: Int, EventType)
    case notificationAddedToChannel(Channel, EventType)
    
    /// An event type.
    public var type: EventType {
        switch self {
        case .messageRead(_, let type),
             .messageNew(_, _, _, _, let type),
             .messageDeleted(_, let type),
             .messageUpdated(_, let type),
             
            .userUpdated(_, let type),
            .userPresenceChanged(_, let type),
            .userStartWatching(_, _, let type),
            .userStopWatching(_, _, let type),
            
            .reactionNew(_, _, _, let type),
            .reactionDeleted(_, _, _, let type),
            
            .typingStart(_, let type),
            .typingStop(_, let type),
            
            .notificationMutesUpdated(_, let type),
            .notificationMarkRead(_, _, _, let type),
            .notificationAddedToChannel(_, let type):
            return type
        case .healthCheck:
            return .healthCheck
        }
    }
        
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(EventType.self, forKey: .type)
        
        if type == .healthCheck {
            let connectionId = try container.decode(String.self, forKey: .connectionId)
            let user = try container.decodeIfPresent(User.self, forKey: .me)
            self = .healthCheck(connectionId, user)
            return
        }
        
        func user() throws -> User {
            return try container.decode(User.self, forKey: .user)
        }
        
        func message() throws -> Message {
            return try container.decode(Message.self, forKey: .message)
        }
        
        switch type {
        // Message
        case .messageNew, .notificationMessageNew:
            let channel = try container.decodeIfPresent(Channel.self, forKey: .channel)
            let newMessage = try message()
            let unreadCount = try container.decode(Int.self, forKey: .unreadCount)
            let totalUnreadCount = try container.decode(Int.self, forKey: .totalUnreadCount)
            self = .messageNew(newMessage, unreadCount, totalUnreadCount, channel, type)
        case .messageRead:
            let created = try container.decode(Date.self, forKey: .created)
            self = .messageRead(MessageRead(user: try user(), lastReadDate: created), type)
        case .messageDeleted:
            self = .messageDeleted(try message(), type)
        case .messageUpdated:
            self = .messageUpdated(try message(), type)
            
        // User
        case .userUpdated:
            self = .userUpdated(try user(), type)
        case .userPresenceChanged:
            self = .userPresenceChanged(try user(), type)
        case .userStartWatching:
            let watcherCount = try container.decode(Int.self, forKey: .watcherCount)
            self = .userStartWatching(try user(), watcherCount, type)
        case .userStopWatching:
            let watcherCount = try container.decode(Int.self, forKey: .watcherCount)
            self = .userStopWatching(try user(), watcherCount, type)
            
        // Typing
        case .typingStart:
            self = .typingStart(try user(), type)
        case .typingStop:
            self = .typingStop(try user(), type)
            
        // Reaction
        case .reactionNew:
            let reaction = try container.decode(Reaction.self, forKey: .reaction)
            self = .reactionNew(reaction, try message(), try user(), type)
        case .reactionDeleted:
            let reaction = try container.decode(Reaction.self, forKey: .reaction)
            self = .reactionDeleted(reaction, try message(), try user(), type)
            
        // Notifications
        case .notificationMutesUpdated:
            self = .notificationMutesUpdated(try container.decode(User.self, forKey: .me), type)
        case .notificationMarkRead:
            let unreadCount = try container.decode(Int.self, forKey: .unreadCount)
            let unreadChannels = try container.decode(Int.self, forKey: .unreadChannels)
            let totalUnreadCount = try container.decode(Int.self, forKey: .totalUnreadCount)
            self = .notificationMarkRead(unreadCount, totalUnreadCount, unreadChannels, type)
        case .notificationAddedToChannel:
            let channel = try container.decode(Channel.self, forKey: .channel)
            self = .notificationAddedToChannel(channel, type)
        default:
            throw ResponseTypeError(type: type)
        }
    }
}

extension Event: Equatable {
    public static func == (lhs: Event, rhs: Event) -> Bool {
        switch (lhs, rhs) {
        case (.healthCheck, .healthCheck):
            return true
        case (.messageRead(let messageRead1, _), .messageRead(let messageRead2, _)):
            return messageRead1 == messageRead2
        case (.messageNew(let message1, let unreadCount1, let totalUnreadCount1, let channel1, _),
              .messageNew(let message2, let unreadCount2, let totalUnreadCount2, let channel2, _)):
            return message1 == message2
                && unreadCount1 == unreadCount2
                && totalUnreadCount1 == totalUnreadCount2
                && channel1 == channel2
        case (.messageDeleted(let message1, _), .messageDeleted(let message2, _)):
            return message1 == message2
        case (.messageUpdated(let message1, _), .messageUpdated(let message2, _)):
            return message1 == message2
        case (.userUpdated(let user1, _), .userUpdated(let user2, _)):
            return user1 == user2
        case (.userPresenceChanged(let user1, _), .userPresenceChanged(let user2, _)):
            return user1 == user2
        case (.userStartWatching(let user1, let watcherCount1, _), .userStartWatching(let user2, let watcherCount2, _)):
            return user1 == user2 && watcherCount1 == watcherCount2
        case (.userStopWatching(let user1, let watcherCount1, _), .userStopWatching(let user2, let watcherCount2, _)):
            return user1 == user2 && watcherCount1 == watcherCount2
        case (.reactionNew(let reaction1, let message1, let user1, _), .reactionNew(let reaction2, let message2, let user2, _)):
            return reaction1 == reaction2 && message1 == message2 && user1 == user2
        case (.reactionDeleted(let reaction1, let message1, let user1, _),
              .reactionDeleted(let reaction2, let message2, let user2, _)):
            return reaction1 == reaction2 && message1 == message2 && user1 == user2
        case (.typingStart(let user1, _), .typingStart(let user2, _)):
            return user1 == user2
        case (.typingStop(let user1, _), .typingStop(let user2, _)):
            return user1 == user2
        case (.notificationMarkRead(let unreadCount1, let totalUnreadCount1, let unreadChannels1, _),
              .notificationMarkRead(let unreadCount2, let totalUnreadCount2, let unreadChannels2, _)):
            return unreadCount1 == unreadCount2 && totalUnreadCount1 == totalUnreadCount2 && unreadChannels1 == unreadChannels2
        default:
            return false
        }
    }
}
