//
//  ViewModel.swift
//  ModernCollectionView
//
//  Created by yujaehong on 9/14/24.
//

import Foundation
import RxSwift

class ViewModel {
    
    let disposeBag = DisposeBag()
    
    private let tvNetwork: TVNetwork
    private let movieNetwork: MovieNetwork
    
    private var currentContentType: ContentType = .tv
    private var currentTVList: [TV] = []
    
    init() {
        let provider = NetworkProvider()
        tvNetwork = provider.makeTVNetwork()
        movieNetwork = provider.makeMovieNetwork()
    }
    
    struct Input {
        let keyword: Observable<String>
        let tvTrigger: Observable<Int>
        let movieTrigger: Observable<Void>
    }
    
    struct Output {
        let tvList: Observable<[TV]>
        let movieList: Observable<Result<MovieResult, Error>>
    }
    
    func transtorm(input: Input) -> Output {
        
        let tvList = Observable.combineLatest(input.tvTrigger, input.keyword)
            .flatMapLatest { [unowned self] page, keyword in
                if page == 1 { currentTVList = [] }
                self.currentContentType = .tv
                if keyword.isEmpty {
                    return self.tvNetwork.getTopRatedList(page: page)
                } else {
                    return self.tvNetwork.getQueriedList(page: page, query: keyword)
                }
            }.map { $0.results }
            .map { tvList in
                self.currentTVList += tvList
                return self.currentTVList
            }
        
        let movieResult = input.movieTrigger.flatMap { [unowned self] _ -> Observable<Result<MovieResult, Error>> in
            return Observable.combineLatest(<#T##source1: ObservableType##ObservableType#>, <#T##source2: ObservableType##ObservableType#>, <#T##source3: ObservableType##ObservableType#>) {
                
            }.catchError { error in
                print(error)
                return Observable.just(.failure(error))
            }
        }
        
        return Output(tvList: <#T##Observable<[TV]>#>, movieList: <#T##Observable<Result<MovieResult, any Error>>#>)
    }
    
}
