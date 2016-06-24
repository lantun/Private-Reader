//
//  Def.swift
//  Private Reader
//
//  Created by Tun Lan on 6/14/16.
//  Copyright © 2016 Tun Lan. All rights reserved.
//

// 全局的一些定议
import Foundation
import UIKit

func log(item: Any, _ file: String = #file, _ line: Int = #line, _ function: String = #function) {
    print(file + ":\(line):" + function, item)
}

func UIColorFromHex(hex hex: UInt) -> UIColor {
    return UIColor.init(red: CGFloat((hex & 0xFF0000) >> 16)/255.0, green: CGFloat((hex & 0xFF00) >> 8)/255.0, blue: CGFloat(hex & 0xFF)/255.0, alpha: 1.0)
}

func RGBA(r r: UInt, g: UInt, b: UInt, a: Float) -> UIColor {
    return UIColor.init(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: CGFloat(a))
}

func RGB(r r: UInt, g: UInt, b: UInt) -> UIColor {
    return RGBA(r: r, g: g, b: b, a: 1.0)
}


        