//
//  ActiveDayCollectionViewCell.swift
//  Sol
//
//  Created by Zane Whitney on 3/10/20.
//  Copyright © 2020 Kitsch. All rights reserved.
//

import Foundation
import UIKit

public class ActiveDayCollectionViewCell: UICollectionViewCell {
    fileprivate var dayAbbrevLabel: UILabel?
    var selectedBadge: UIView?
    var unselectedBadge: UIView?
    
    public var abbrevDayOfWeek: String? {
        didSet {
            if !contentView.hasSubview(ofType: UILabel.self) {
                dayAbbrevLabel = .init(frame: bounds)
                dayAbbrevLabel?.textAlignment = .center
                contentView.addSubview(dayAbbrevLabel!)
            }
            
            dayAbbrevLabel!.text = abbrevDayOfWeek
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
