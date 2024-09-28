//
//  ReviewViewModel.swift
//  ModernCollectionView
//
//  Created by yujaehong on 9/27/24.
//

import UIKit
import RxSwift

final class ReviewViewModel {
    private let reviewNetwork: ReviewNetwork
    private let id: Int, contentType: ContentType
    
    init(id: Int, contentType: ContentType) {
        let provider = NetworkProvider()
        self.reviewNetwork = provider.makeReviewNetwork()
        self.id = id
        self.contentType = contentType
    }
    
    struct Input {
        
    }
    
    struct Output {
        let reviewResult: Observable<Result<[ReviewModel],Error>>
    }
    
    func transform(input: Input) -> Output {
        let reviewResult: Observable<Result<[ReviewModel],Error>> = reviewNetwork.getReviewList(id: id, contentType: contentType).map { reviewResult in
            return .success(reviewResult.results)
        }.catchError { error in
            return Observable.just(.failure(error))
        }
        return Output(reviewResult: reviewResult)
    }
    
}
