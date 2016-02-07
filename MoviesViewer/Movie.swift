//
//  Movie.swift
//  MoviesViewer
//
//  Created by YiHuang on 2/6/16.
//  Copyright © 2016 c2fun. All rights reserved.
//

import Foundation
import UIKit

class Movie {
    var id: Int
    var title: String
    var overview: String
    var rating: Double?
    var runtime: Int?
    var posterUrl: String?
    var backdropUrl: String?
    var releaseDate: String?

    
    init(id: Int, title: String, overview: String, rating: Double?, runtime: Int?, posterUrl: String?, backdropUrl: String?, releaseDate: String?) {
        self.id = id
        self.title = title
        self.overview = overview
        self.rating = rating
        self.runtime = runtime
        self.posterUrl = posterUrl
        self.backdropUrl = backdropUrl
        self.releaseDate = releaseDate
    }
    
}