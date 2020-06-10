//
//  HelperXPCProtocol.swift
//  Helper
//
//  Created by Gregory Ling on 6/9/20.
//  Copyright © 2020 Gregory Ling. All rights reserved.
//

import Foundation

@objc public protocol HelperXPCProtocol {
    func helloWorld(_ callback: @escaping (String) -> Void)
    func getVersion(_ callback: @escaping (String) -> Void)
    func ping(_ callback: @escaping () -> Void)
    
}
