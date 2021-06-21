---
id: messagetype 
title: MessageType
--- 

A type of the message.

``` swift
public enum MessageType: String, Codable 
```

## Inheritance

`Codable`, `String`

## Enumeration Cases

### `regular`

A regular message created in the channel.

``` swift
case regular
```

### `ephemeral`

A temporary message which is only delivered to one user. It is not stored in the channel history. Ephemeral messages
are normally used by commands (e.g. /giphy) to prompt messages or request for actions.

``` swift
case ephemeral
```

### `error`

An error message generated as a result of a failed command. It is also ephemeral, as it is not stored in the channel
history and is only delivered to one user.

``` swift
case error
```

### `reply`

The message is a reply to another message. Use the `parentMessageId` variable of the message to get the parent
message data.

``` swift
case reply
```

### `system`

A message generated by a system event, like updating the channel or muting a user.

``` swift
case system
```

### `deleted`

A deleted message.

``` swift
case deleted
```