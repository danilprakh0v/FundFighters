/*
===============================================================================
Проект: FundFighters (iOS UIKit Client)
Файл: PaddingLabel.swift
Расположение: FundFighters.Client/FundFighters.Client/Modules/Onboarding/
Назначение: Custom UILabel with internal padding.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 04.02.2026
===============================================================================
*/

import UIKit

final class PaddingLabel: UILabel {
    
    var topInset: CGFloat = 8
    var bottomInset: CGFloat = 8
    var leftInset: CGFloat = 16
    var rightInset: CGFloat = 16
    
    private var insets: UIEdgeInsets {
        return UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + leftInset + rightInset,
            height: size.height + topInset + bottomInset
        )
    }
}
