//
//  Card.swift
//  Set
//
//  Created by Wangshu Zhu on 2018/7/18.
//  Copyright © 2018年 Wangshu Zhu. All rights reserved.
//

import Foundation

struct Card: CustomStringConvertible, Equatable {
    /*
     This is the fundamental element of this game, It represents the card in the set game,
     It has four properties: the Number, the Shading, the Color and the Symbol, which are
     all enums in the aproach. It implements "CustomStringConvertible" so that it prints
     like this: 1 Blue Solid ● , 2 Blue Solid ▲ , 3 Blue Solid ■ ...etc
     */
    
    var description: String { return "\(number) \(color) \(shading) \(symbol) "}
    
    var symbol:Symbol
    var number:Number
    var shading:Shading
    var color:Color
    
    enum Symbol: String, CustomStringConvertible {
        var description: String {
            return self.rawValue
        }
        
        case triangle = "▲"
        case square = "■"
        case circle = "●"
        
        static let all = [Symbol.triangle, .square, .circle]
    }
    
    enum Number: Int, CustomStringConvertible {
        var description: String {
            return "\(self.rawValue)"
        }
        
        case one = 1
        case two = 2
        case three = 3
        
        static let all = [Number.one, .two, .three]
        
        
    }
    
    enum Shading: String, CustomStringConvertible {
        var description: String {
            return self.rawValue
        }
        
        case striped = "Striped"
        case solid = "Solid"
        case open = "Open"
        
        static let all = [Shading.striped, .solid, .open]
    }
    
    enum Color: String, CustomStringConvertible {
        var description: String{
            return self.rawValue
        }
        
        case red = "Red"
        case blue = "Blue"
        case black = "Black"
        
        static let all = [Color.red, .blue, .black]
    }
}

extension Card {
    static func match(for cardArray: Array<Card>) -> Bool {
        
        let colorCount = Set(cardArray.map{ $0.color }).count
        let shadingCount = Set(cardArray.map {$0.shading}).count
        let symbolCount = Set(cardArray.map {$0.symbol}).count
        let numberCount = Set(cardArray.map {$0.number}).count
        
        return colorCount != 2 && shadingCount != 2 && symbolCount != 2 && numberCount != 2
    }
    
}

