//
//  UIView+Circular.swift
//  Sol
//
//  Created by Zane Whitney on 3/11/20.
//  Copyright © 2020 Kitsch. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func makeCircular() {
        self.layer.cornerRadius = min(self.frame.size.height, self.frame.size.width) / 2.0
        self.clipsToBounds = true
    }
}
