//
//  TV.swift
//  ModernCollectionView
//
//  Created by yujaehong on 9/14/24.
//

import Foundation

struct TVListModel: Decodable {
    let page: Int
    let results: [TV]
}

struct TV: Decodable, Hashable {
    let id: Int
    let name: String
    let overview: String
    let posterURL: String
    let vote: String
    let firstAirDate: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case overview
        case posterPath = "poster_path"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case firstAirDate = "first_air_date"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        overview = try container.decode(String.self, forKey: .overview)
        
        let path = try container.decodeIfPresent(String.self, forKey: .posterPath) // // decodeIfPresent 옵셔널하게 값을 받아옴
        if let path = path {
            posterURL = "https://image.tmdb.org/t/p/w500\(path)"
        } else {
            posterURL = ""
        }
                
        let voteAverage = try container.decode(Float.self, forKey: .voteAverage)
        let voteCount = try container.decode(Int.self, forKey: .voteCount)
        vote = "\(voteAverage) (\(voteCount))"
        
        firstAirDate = try container.decode(String.self, forKey: .firstAirDate)
    }
}

