//
//  Client+RxRequest.swift
//  GetStreamChat
//
//  Created by Alexey Bukhtin on 24/04/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation
import RxSwift

extension Client: ReactiveCompatible {}

extension Reactive where Base == Client {
    func request<T: Decodable>(endpoint: EndpointProtocol, connectionId: String) -> Observable<T> {
        return .create { observer in
            let task = self.base.request(endpoint: endpoint, connectionId: connectionId) { (result: Result<T, ClientError>) in
                switch result {
                case .success(let value):
                    observer.onNext(value)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create(with: task.cancel)
        }
    }
}
