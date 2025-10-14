//
//  Font.swift
//  LockRun
//
//  Created by 전준영 on 10/12/25.
//

import SwiftUI

enum FontType {
    case system(CGFloat, weight: Font.Weight = .regular)
    case custom(name: String, size: CGFloat)
    case predefined(Font)
    
    var swiftUIFont: Font {
        switch self {
        case .system(let size, let weight):
            return .system(size: size, weight: weight)
            
        case .custom(let name, let size):
            return .custom(name, size: size)
            
        case .predefined(let font):
            return font
        }
    }
}

extension FontType {
    //regular
    static let regular12 = FontType
        .system(12,
                weight: .regular)
    static let regular15 = FontType
        .system(15,
                weight: .regular)
    static let regular16 = FontType
        .system(16,
                weight: .regular)
    static let regular20 = FontType
        .system(20,
                weight: .regular)
    static let regular24 = FontType
        .system(24,
                weight: .regular)
    //bold
    static let bold12 = FontType
        .system(12,
                weight: .bold)
    static let bold13 = FontType
        .system(13,
                weight: .bold)
    static let bold18 = FontType
        .system(18,
                weight: .bold)
    static let semibold24 = FontType
        .system(24,
                weight: .semibold)
    // predefined (SwiftUI 기본값)
    static let headline = FontType
        .predefined(.headline)
    static let body = FontType
        .predefined(.body)
    static let title = FontType
        .predefined(.title)
    static let caption = FontType
        .predefined(.caption)
}
