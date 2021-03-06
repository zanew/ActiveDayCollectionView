//
//  ActiveDayCollectionView.swift
//  Sol
//
//  Created by Zane Whitney on 2/3/20.
//  Copyright © 2020 Kitsch. All rights reserved.
//

import UIKit
import SwiftUI

open class ActiveDayCollectionViewBaseWrapper: UICollectionView {
    public class Constants {
        public enum Sizes {
            public static let weekdayIconDimension: CGFloat = 34
            public static let cellSpacing: CGFloat = 10
        }
        
        public enum Identifiers {
            public enum CellReuse {
                public static let genericCell = "genericCell"
                public static let activeDayCollectionViewCell = "weekdayCollectionViewCell"
            }
        }
        
        enum Colors {
            public static var systemGrayLight: UIColor {
                return UIColor(red: (142/255), green: (142/255), blue: (147/255), alpha: 1.0)
            }
        }
    }
    
    public var weekdayLayoutDelegate: DayOfWeekFlowLayoutDelegate? {
        didSet {
            delegate = weekdayLayoutDelegate
        }
    }
    public var weekdayDataSource: DayOfWeekDataSource? {
        didSet {
            dataSource = weekdayDataSource
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        let width = ((Constants.Sizes.weekdayIconDimension * 7) + (Constants.Sizes.cellSpacing * 6)) + 20
        return .init(width: width, height: 60)
    }
    
    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class DayOfWeekDataSource: NSObject, UICollectionViewDataSource {}

extension DayOfWeekDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
}

public class DayOfWeekFlowLayoutDelegate: NSObject, UICollectionViewDelegateFlowLayout {}

extension DayOfWeekFlowLayoutDelegate {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return ActiveDayCollectionView.Constants.Sizes.cellSpacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let cellWidth = ActiveDayCollectionView.Constants.Sizes.weekdayIconDimension
        let cellCount = 7
        let spacing = (collectionViewLayout as! UICollectionViewFlowLayout).minimumInteritemSpacing

        let totalCellWidth = cellWidth * CGFloat(cellCount)
        let totalSpacingWidth = spacing * CGFloat(cellCount - 1)

        let leftInset = (collectionView.intrinsicContentSize.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset

        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: ActiveDayCollectionViewBaseWrapper.Constants.Sizes.weekdayIconDimension, height: ActiveDayCollectionView.Constants.Sizes.weekdayIconDimension)
    }
}

extension DayOfWeekFlowLayoutDelegate {
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let weekdayView = collectionView as! ActiveDayCollectionView
        weekdayView.viewModel?.setDayOfWeekActive(state: true, forIndexPath: indexPath)
        return weekdayView.viewModel?.isDayOfWeekActive(atIndexPath: indexPath) ?? false
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        let weekdayView = collectionView as! ActiveDayCollectionView
        weekdayView.viewModel?.setDayOfWeekActive(state: false, forIndexPath: indexPath)
        return !(weekdayView.viewModel?.isDayOfWeekActive(atIndexPath: indexPath) ?? false)
    }
}

@available(iOS 13.0, *)
public struct ActiveDayView: UIViewRepresentable {
    
    public init(activeDays: Binding<DaysOfWeekActive>) {
        self._activeDays = activeDays
    }
    
    @Binding public var activeDays: DaysOfWeekActive
    
    public typealias UIViewType = ActiveDayCollectionView
    
    @available(iOS 13.0, *)
    public func makeUIView(context: Context) ->  ActiveDayCollectionView {
        return ActiveDayCollectionView()
    }
    
    @available(iOS 13.0, *)
    public func updateUIView(_ uiView: ActiveDayCollectionView, context: Context) {
        uiView.activeDays = activeDays
    }
}

public class ActiveDayCollectionView: ActiveDayCollectionViewBaseWrapper {

    public var viewModel: DayOfWeekViewModel?
    public var badgeSelectionColor: UIColor? {
        didSet {
            reloadData()
        }
    }
    
    public var activeDays: DaysOfWeekActive? {
        get {
            return self.viewModel?.weekdaySetting
        }
        
        set {
            self.viewModel?.weekdaySetting = newValue ?? DaysOfWeekActive(rawValue: 0)
            reloadData()
        }
    }
    
    public convenience init(viewModel: DayOfWeekViewModel, dataSource: DayOfWeekDataSource, flowLayoutDelegate: DayOfWeekFlowLayoutDelegate) {
        let horizontalLayout = UICollectionViewFlowLayout()
        horizontalLayout.scrollDirection = .horizontal
        
        self.init(frame: .zero, collectionViewLayout: horizontalLayout)
        
        register(ActiveDayCollectionViewCell.self, forCellWithReuseIdentifier: ActiveDayCollectionView.Constants.Identifiers.CellReuse.activeDayCollectionViewCell)
        allowsMultipleSelection = true
        
        if #available(iOS 13.0, *) {
            // color of tv cell in light mode
            backgroundColor = .secondarySystemGroupedBackground

        } else {
            // Fallback on earlier versions
            backgroundColor = .white
        }
                
        weekdayLayoutDelegate = flowLayoutDelegate
        weekdayDataSource = dataSource
        
        self.viewModel = viewModel
        frame = .init(origin: .zero, size: intrinsicContentSize)
        
        reloadData()
    }
    
    public convenience init(activeDays: DaysOfWeekActive) {
        let viewModel = DayOfWeekViewModel.init(activeDays: activeDays)
        let dataSource = DayOfWeekDataSource()
        let delegate = DayOfWeekFlowLayoutDelegate()
        self.init(viewModel: viewModel, dataSource: dataSource, flowLayoutDelegate: delegate)
    }
    
    public convenience init() {
        self.init(activeDays: DaysOfWeekActive(rawValue: 0))
    }
}

extension DayOfWeekDataSource {
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let weekdayView = collectionView as? ActiveDayCollectionView,
            let dayOfWeek = weekdayView.viewModel?.dayOfWeekAbbreviated(forIndexPath: indexPath) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ActiveDayCollectionView.Constants.Identifiers.CellReuse.activeDayCollectionViewCell, for: indexPath) as? ActiveDayCollectionViewCell
            cell!.abbrevDayOfWeek = dayOfWeek
            
            let selectedBadge = UIView.init()
            let unselectedBadge = UIView.init()
            
            selectedBadge.layer.cornerRadius = min(ActiveDayCollectionView.Constants.Sizes.weekdayIconDimension, ActiveDayCollectionView.Constants.Sizes.weekdayIconDimension) / 2.0
            unselectedBadge.layer.cornerRadius = min(ActiveDayCollectionView.Constants.Sizes.weekdayIconDimension, ActiveDayCollectionView.Constants.Sizes.weekdayIconDimension) / 2.0
            selectedBadge.clipsToBounds = true
            unselectedBadge.clipsToBounds = true
            
            if let selectionColor = weekdayView.badgeSelectionColor {
                selectedBadge.backgroundColor = selectionColor
            } else {
                selectedBadge.backgroundColor = weekdayView.tintColor
            }
            
            if #available(iOS 13.0, *) {
                unselectedBadge.backgroundColor = .secondarySystemFill
            } else {
                // Fallback on earlier versions
                unselectedBadge.backgroundColor = ActiveDayCollectionView.Constants.Colors.systemGrayLight
            }
            
            cell!.selectedBackgroundView = selectedBadge
            cell!.backgroundView = unselectedBadge
            
            if weekdayView.viewModel?.isDayOfWeekActive(atIndexPath: indexPath) ?? false {
                cell!.isSelected = true
                weekdayView.selectItem(at: indexPath, animated: false, scrollPosition: .left)
            }
            
            return cell!
        } else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: ActiveDayCollectionView.Constants.Identifiers.CellReuse.genericCell, for: indexPath)
        }
    }
}
