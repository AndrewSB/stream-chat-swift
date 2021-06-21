---
id: notificationmarkreadevent 
title: NotificationMarkReadEvent
--- 

``` swift
public struct NotificationMarkReadEvent: UserSpecificEvent, ChannelSpecificEvent 
```

## Inheritance

[`UserSpecificEvent`](UserSpecificEvent), [`ChannelSpecificEvent`](ChannelSpecificEvent)

## Properties

### `userId`

``` swift
public let userId: UserId
```

### `cid`

``` swift
public let cid: ChannelId
```

### `readAt`

``` swift
public let readAt: Date
```

### `unreadCount`

``` swift
public let unreadCount: UnreadCount
```