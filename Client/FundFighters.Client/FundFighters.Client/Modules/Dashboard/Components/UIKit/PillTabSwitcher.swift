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

final class PillTabSwitcher: UIView {

    var onTabChanged: ((Int) -> Void)?

    private let items: [String]
    private var buttons: [UIButton] = []
    private let activePill = UIView()
    private var activePillLeading: NSLayoutConstraint?
    private var activePillWidth: NSLayoutConstraint?

    private(set) var selectedIndex: Int = 0 {
        didSet { animatePill(to: selectedIndex) }
    }

    private let accentGreen = UIColor(red: 30/255, green: 140/255, blue: 98/255, alpha: 1)
    private let pillInactive = UIColor(red: 215/255, green: 215/255, blue: 210/255, alpha: 1)

    init(items: [String]) {
        self.items = items
        super.init(frame: .zero)
        setupView()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupView() {
        backgroundColor = pillInactive
        layer.cornerRadius = 22
        clipsToBounds = true

        activePill.backgroundColor = accentGreen
        activePill.layer.cornerRadius = 20
        activePill.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activePill)

        activePillLeading = activePill.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2)
        activePillLeading?.isActive = true
        activePill.topAnchor.constraint(equalTo: topAnchor, constant: 2).isActive = true
        activePill.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2).isActive = true
        activePillWidth = activePill.widthAnchor.constraint(equalToConstant: 100)
        activePillWidth?.isActive = true

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        for (i, title) in items.enumerated() {
            let btn = UIButton(type: .system)
            btn.setTitle(title, for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
            btn.tag = i
            btn.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
            stack.addArrangedSubview(btn)
            buttons.append(btn)
        }
        updateButtonColors(activeIndex: 0, animated: false)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard !bounds.isEmpty, items.count > 0 else { return }
        let segW = bounds.width / CGFloat(items.count)
        activePillWidth?.constant = segW - 4
        activePillLeading?.constant = CGFloat(selectedIndex) * segW + 2
    }

    @objc private func tabTapped(_ sender: UIButton) {
        selectedIndex = sender.tag
        onTabChanged?(selectedIndex)
    }

    private func animatePill(to index: Int) {
        guard !bounds.isEmpty, items.count > 0 else { return }
        let segW = bounds.width / CGFloat(items.count)
        activePillLeading?.constant = CGFloat(index) * segW + 2
        updateButtonColors(activeIndex: index, animated: true)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.4, options: .curveEaseInOut) {
            self.layoutIfNeeded()
        }
    }

    private func updateButtonColors(activeIndex: Int, animated: Bool) {
        let change = {
            for (i, btn) in self.buttons.enumerated() {
                btn.setTitleColor(i == activeIndex ? .white : UIColor(white: 0.45, alpha: 1), for: .normal)
            }
        }
        if animated { UIView.animate(withDuration: 0.2, animations: change) } else { change() }
    }
}
