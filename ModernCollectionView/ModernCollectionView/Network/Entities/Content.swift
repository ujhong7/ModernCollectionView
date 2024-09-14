//
//  Content.swift
//  ModernCollectionView
//
//  Created by yujaehong on 9/14/24.
//

import Foundation

enum ContentType: String, Decodable {
    case tv
    case movie
}

struct Content: Decodable, Hashable {
    let id: Int
    let title: String
    let overview: String
    let posterURL: String
    let vote: String
    let releaseDate: String
    let type: ContentType
    
    init(tv: TV) {
        self.id = tv.id
        self.title = tv.name
        self.overview = tv.overview
        self.posterURL = tv.posterURL
        self.vote = tv.vote
        self.releaseDate = tv.firstAirDate
        self.type = .tv
    }
    
    init(movie: Movie) {
        self.id = movie.id
        self.title = movie.title
        self.overview = movie.overview
        self.posterURL = movie.posterURL
        self.vote = movie.vote
        self.releaseDate = movie.releaseDate
        self.type = .movie
    }
}
