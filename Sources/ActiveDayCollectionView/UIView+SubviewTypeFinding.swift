//
//  UIView+SubviewTypeFinding.swift
//  Sol
//
//  Created by Zane Whitney on 3/11/20.
//  Copyright © 2020 Kitsch. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func hasSubview<O>(ofType: O.Type) -> Bool where O : UIView {
        return firstOccuringSubview(ofType: O.self) != nil
    }
    
    func firstOccuringSubview<T>(ofType: T.Type) -> T? where T : UIView {
        return self.subviews.filter{ $0 is T }.first as? T
    }
}
