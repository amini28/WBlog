//
//  Model.swift
//  Blog
//
//  Created by Amini on 20/11/22.
//

import Foundation
import UIKit

struct Author : Decodable {
    let ID: Int
    let login: String
    let name: String?
    let first_name: String?
    let last_name: String?
    let nice_name: String?
    let avatar_URL: String?
    let porfile_URL: String?
}
