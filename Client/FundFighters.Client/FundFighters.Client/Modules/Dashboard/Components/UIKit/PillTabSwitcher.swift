/*
===============================================================================
Проект: FundFighters (iOS UIKit Client)
Файл: PillTabSwitcher.swift
Расположение: FundFighters.Client/FundFighters.Client/Modules/Dashboard/Components/UIKit/
Назначение: Переключатель вкладок в стиле Pill (таблетка).
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 04.02.2026
===============================================================================
*/

import UIKit

final class PillTabSwitcher: UISegmentedControl {

    var onTabChanged: ((Int) -> Void)?

    init(items: [String]) {
        super.init(items: items)
        setupView()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupView() {
        selectedSegmentIndex = 0
        backgroundColor = UIColor.white.withAlphaComponent(0.52)
        selectedSegmentTintColor = DT.accentGreen
        layer.cornerRadius = 22
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(0.72).cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.06
        layer.shadowRadius = 12
        layer.shadowOffset = CGSize(width: 0, height: 7)

        setTitleTextAttributes([
            .foregroundColor: DS.textPrimary,
            .font: DS.golosMedium(17)
        ], for: .normal)
        setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: DS.golosBold(18)
        ], for: .selected)
        addTarget(self, action: #selector(tabTapped), for: .valueChanged)
    }

    /// Programmatically select a tab. Does NOT fire `onTabChanged`.
    func selectIndex(_ index: Int, animated: Bool = false) {
        guard index >= 0 && index < numberOfSegments else { return }
        selectedSegmentIndex = index
    }

    @objc private func tabTapped() {
        onTabChanged?(selectedSegmentIndex)
    }
}
