//
//  MovieNetwork.swift
//  ModernCollectionView
//
//  Created by yujaehong on 9/14/24.
//

import Foundation
import RxSwift

final class MovieNetwork {
    
    private let network: Network<MovieListModel>
    
    init(network: Network<MovieListModel>) {
        self.network = network
    }
    
    func getNowPlayingList() -> Observable<MovieListModel> {
        return network.getItemList(path: "/movie/now_playing")
    }
    
    func getPopularList() -> Observable<MovieListModel>{
        return network.getItemList(path: "/movie/popular")
    }
    
    func getUpComingList() -> Observable<MovieListModel>{
        return network.getItemList(path: "/movie/upcoming")
    }
}
