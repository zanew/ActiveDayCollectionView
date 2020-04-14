//
//  DayOfWeekCollectionView.swift
//  Sol
//
//  Created by Zane Whitney on 2/3/20.
//  Copyright © 2020 Kitsch. All rights reserved.
//

import UIKit

// MARK: shared functionality
protocol IndexedControl {
    var indexPath: IndexPath? { get set }
}

public class DayOfWeekCollectionViewBaseWrapper: UICollectionView {
    internal class Constants {
        enum Spacings {
            static let weekdayIconDimension: CGFloat = 39
        }
        
        enum Identifiers {
            enum CellReuse {
                static let genericCell = "genericCell"
                static let activeDayCollectionViewCell = "weekdayCollectionViewCell"
            }
        }
        
        enum Colors {
            public static var systemGrayLight: UIColor {
                return UIColor(red: (142/255), green: (142/255), blue: (147/255), alpha: 1.0)
            }
        }
    }
    
    var weekdayLayoutDelegate: DayOfWeekFlowLayoutDelegate? {
        didSet {
            delegate = weekdayLayoutDelegate
        }
    }
    var weekdayDataSource: DayOfWeekDataSource? {
        didSet {
            dataSource = weekdayDataSource
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        return .init(width: 414, height: 60)
    }
    
    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class DayOfWeekDataSource: NSObject, UICollectionViewDataSource {
    
}

extension DayOfWeekDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
}

public class DayOfWeekFlowLayoutDelegate: NSObject, UICollectionViewDelegateFlowLayout {
    
}

extension DayOfWeekFlowLayoutDelegate {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: ActiveDayCollectionView.Constants.Spacings.weekdayIconDimension, height: ActiveDayCollectionView.Constants.Spacings.weekdayIconDimension)
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

// MARK: full picker
#if FULL_WEEKDAY_PICKER
extension ActiveDayCollectionView: IndexedControl {
    var indexPath: IndexPath? {
        get {
            return self.ip
        }

        set {
            self.ip = newValue
        }
    }
    
    
}

public class ActiveDayCollectionView: DayOfWeekCollectionViewBaseWrapper, InterfaceCreating {
    var ip: IndexPath?
    
    func addSubviews() {
    }
    
    func constrainElements() {
    }

    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        register(ActiveDayCollectionViewCell.self, forCellWithReuseIdentifier: ActiveDayCollectionView.Constants.Identifiers.CellReuse.activeDayCollectionViewCell)
        allowsMultipleSelection = true
        backgroundColor = .white
        initializeViewUpdaters()
    }
            
    var styleWithTheme: ((Theme?) -> Void)?
    
    var viewModel: DayOfWeekViewModel?
    
    var cachedDayOfWeekViewCellStyle: ActiveDayCollectionViewCellStyle?
    
    public convenience init(viewModel: DayOfWeekViewModel, dataSource: DayOfWeekDataSource, flowLayoutDelegate: DayOfWeekFlowLayoutDelegate) {
        let horizontalLayout = UICollectionViewFlowLayout()
        horizontalLayout.scrollDirection = .horizontal
        self.init(frame: .zero, collectionViewLayout: horizontalLayout)
        initializeViewUpdaters()
        configure(withViewModel: viewModel)
        weekdayLayoutDelegate = flowLayoutDelegate
        weekdayDataSource = dataSource
    }
    
    func initializeViewUpdaters() {
        styleWithTheme = {
            [weak self] (theme: Theme?) in
            guard let weakSelf = self, let theme = theme else {
                return
            }
            
            weakSelf.applyStandardStyles()
            switch (theme) {
            case .sunrise:
                weakSelf.applyLightStyles()
            case .morning:
                weakSelf.applyLightStyles()
            case .solarNoon:
                weakSelf.applyLightStyles()
            case .afternoon:
                weakSelf.applyLightStyles()
            case .sunset:
                weakSelf.applyDarkStyles()
            case .night:
                weakSelf.applyDarkStyles()
            case .nightLight:
                weakSelf.applyDarkStyles()
                weakSelf.applyNightLightStyles()
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ActiveDayCollectionView {
    fileprivate func applyStandardStyles() {
        self.apply(style: ActiveDayCollectionViewStyle.light)
    }
    
    fileprivate func applyLightStyles() {
        self.apply(style: ActiveDayCollectionViewStyle.light)
        cachedDayOfWeekViewCellStyle = .light
    }
    
    fileprivate func applyDarkStyles() {
        self.apply(style: ActiveDayCollectionViewStyle.night)
        cachedDayOfWeekViewCellStyle = .night
    }
    
    fileprivate func applyNightLightStyles() {
        self.apply(style: ActiveDayCollectionViewStyle.nightLight)
        cachedDayOfWeekViewCellStyle = .nightLight
    }
}

extension ActiveDayCollectionView: ViewModelConfigurable {
    func configure(withViewModel viewModel: DayOfWeekViewModel) {
        self.viewModel = viewModel
        self.viewModel?.updateTheme = styleWithTheme
        styleWithTheme!(self.viewModel!.theme)
        reloadData()
    }
}

extension DayOfWeekDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let weekdayView = collectionView as? ActiveDayCollectionView,
            let dayOfWeek = weekdayView.viewModel?.dayOfWeekAbbreviated(forIndexPath: indexPath) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ActiveDayCollectionView.Constants.Identifiers.CellReuse.activeDayCollectionViewCell, for: indexPath) as? ActiveDayCollectionViewCell
            cell!.abbrevDayOfWeek = dayOfWeek
            
            let selectedBadge = UIView.init()
            let unselectedBadge = UIView.init()
            
            selectedBadge.layer.cornerRadius = min(ActiveDayCollectionView.Constants.Spacings.weekdayIconDimension, ActiveDayCollectionView.Constants.Spacings.weekdayIconDimension) / 2.0
            unselectedBadge.layer.cornerRadius = min(ActiveDayCollectionView.Constants.Spacings.weekdayIconDimension, ActiveDayCollectionView.Constants.Spacings.weekdayIconDimension) / 2.0
            selectedBadge.clipsToBounds = true
            unselectedBadge.clipsToBounds = true
            selectedBadge.backgroundColor = weekdayView.cachedDayOfWeekViewCellStyle?.selectedBadgeColor
            unselectedBadge.backgroundColor = weekdayView.cachedDayOfWeekViewCellStyle?.unselectedBadgeColor
            
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

// MARK: library picker
#else
public class ActiveDayCollectionView: DayOfWeekCollectionViewBaseWrapper {
    var viewModel: DayOfWeekViewModel?
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
            
            selectedBadge.layer.cornerRadius = min(ActiveDayCollectionView.Constants.Spacings.weekdayIconDimension, ActiveDayCollectionView.Constants.Spacings.weekdayIconDimension) / 2.0
            unselectedBadge.layer.cornerRadius = min(ActiveDayCollectionView.Constants.Spacings.weekdayIconDimension, ActiveDayCollectionView.Constants.Spacings.weekdayIconDimension) / 2.0
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
#endif