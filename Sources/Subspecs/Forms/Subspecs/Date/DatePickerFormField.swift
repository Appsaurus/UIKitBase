//
//  DatePickerFormField.swift
//  Pods
//
//  Created by Brian Strobach on 8/8/17.
//
//

import Foundation
import SwiftDate

open class DatePickerFormField<ContentView: UIView>: FormTextField<ContentView, Date> where ContentView: FormFieldViewProtocol {
    //	//Avoids UX trap where default date is close to min or max and makes it hard to pick
    //	//dates within other years that are technically valid without changing the year first.
    //	open var smartPadsDefaultDates: Bool = true
    public var minDate: Date? {
        didSet {
            setDefaultValue()
        }
    }

    public var maxDate: Date? {
        didSet {
            setDefaultValue()
        }
    }

    open override var inputView: UIView? {
        return picker
    }

    open override var canBecomeFirstResponder: Bool {
        return true
    }

    open override func textDescription(for value: Date?) -> String? {
        guard let value = value else { return nil }
        return "\(value.monthName(.short)) \(value.day), \(value.year)"
    }

    open func setDefaultValue() {
        if let date = value ?? maxDate ?? minDate {
            picker.date = date
        }
    }

    lazy var picker: UIDatePicker = {
        let picker = UIDatePicker(frame: CGRect.zero)
        picker.datePickerMode = .date
        setDefaultValue()
        picker.add(event: .valueChanged, action: { [weak self] in
            guard let self = self else { return }
            if let maxDate = self.maxDate, picker.date > maxDate {
                if picker.date.year == maxDate.year {
                    picker.date = (picker.date - 1.years)
                } else {
                    picker.date = maxDate
                }
                return
            }
            if let minDate = self.minDate, picker.date < minDate {
                if picker.date.year == minDate.year {
                    picker.date = (picker.date + 1.years)
                } else {
                    picker.date = minDate
                }
                return
            }
            self.value = picker.date
        })
        return picker
    }()
}
