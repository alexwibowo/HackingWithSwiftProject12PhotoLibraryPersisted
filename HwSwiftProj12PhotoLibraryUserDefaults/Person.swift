//
//  Person.swift
//  HwSwiftProj12PhotoLibraryUserDefaults
//
//  Created by Alex Wibowo on 25/9/21.
//

import Foundation


class Person: Codable {
    
    var name : String
    var image : String
    
    init(name: String, image: String){
        self.name = name
        self.image = image
    }
    
}
