//
//  ChannelsResponse.swift
//  GetStreamChat
//
//  Created by Alexey Bukhtin on 17/05/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation

public struct ChannelsResponse: Decodable {
    let channels: [ChannelQuery]
}
