//
//  Def.swift
//  Private Reader
//
//  Created by Tun Lan on 6/14/16.
//  Copyright © 2016 Tun Lan. All rights reserved.
//

// 全局的一些定议
import Foundation

func log(item: Any, _ file: String = #file, _ line: Int = #line, _ function: String = #function) {
    print(file + ":\(line):" + function, item)
}