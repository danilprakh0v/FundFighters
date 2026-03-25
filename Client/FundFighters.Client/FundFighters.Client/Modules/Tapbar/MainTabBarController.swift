/*
===============================================================================
Проект: FundFighters (iOS UIKit Client)
Файл: MainTabBarController.swift
Расположение: FundFighters.Client/FundFighters.Client/Modules/Tapbar/
Назначение: Стеклянный таббар (GlassTabBar) по точному дизайн-макету.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 04.02.2026
===============================================================================
*/

import UIKit

final class MainTabBarController: UITabBarController {

    private let glassBar = GlassTabBar()

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.isHidden = true
        setupViewControllers()
        setupGlassBar()
    }

    private func setupViewControllers() {
        // Порядок: transact → dashboard → MAIN (Dashboard) → report → options
        let transactionsVC = UINavigationController(rootViewController: UIViewController())
        let analyticsVC    = UINavigationController(rootViewController: UIViewController())
        let mainVC         = DashboardViewControllerUIKit()
        let reportsVC      = ReportsViewController()
        let profileVC      = UINavigationController(rootViewController: UIViewController())

        viewControllers = [transactionsVC, analyticsVC, mainVC, reportsVC, profileVC]
        selectedIndex   = 2
    }

    private func setupGlassBar() {
        view.addSubview(glassBar)
        glassBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            glassBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            glassBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            glassBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            glassBar.heightAnchor.constraint(equalToConstant: 76)
        ])

        glassBar.onTabSelected = { [weak self] index in
            self?.selectedIndex = index
        }
        glassBar.selectTab(2, animated: false)
    }

    func switchToTab(_ index: Int) {
        selectedIndex = index
        glassBar.selectTab(index, animated: true)
    }
}

// MARK: - Glass Tab Bar View
final class GlassTabBar: UIView {

    var onTabSelected: ((Int) -> Void)?

    // active / inactive / SF-фолбэк / isCenter
    private typealias TabItem = (active: String, inactive: String, sfFallback: String, isCenter: Bool)

    // Порядок: transact, dashboard, MAIN (center), report, options
    private let items: [TabItem] = [
        ("transact_act",  "transact_inact",  "list.bullet.rectangle.portrait", false),
        ("dashboard_act", "dashboard_inact", "chart.bar.fill",                 false),
        ("main_act",      "main_inact",      "dollarsign.circle.fill",         true),
        ("report_act",    "report_inact",    "doc.text.fill",                  false),
        ("options_act",   "options_inact",   "person.2.fill",                  false)
    ]

    private var buttons: [UIButton] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        // Blur
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        blurView.frame = bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.layer.cornerRadius = 38
        blurView.clipsToBounds = true
        addSubview(blurView)

        backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.96, alpha: 0.85)
        layer.cornerRadius = 38
        layer.borderWidth  = 1.1
        layer.borderColor  = UIColor.white.withAlphaComponent(0.55).cgColor

        // Shadow
        layer.shadowColor   = UIColor.black.cgColor
        layer.shadowOpacity = 0.10
        layer.shadowRadius  = 18
        layer.shadowOffset  = CGSize(width: 0, height: 4)

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])

        for (i, item) in items.enumerated() {
            let btn = item.isCenter ? makeCenterButton(item) : makeRegularButton(item)
            btn.tag = i
            btn.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)

            let container = UIView()
            container.addSubview(btn)
            btn.translatesAutoresizingMaskIntoConstraints = false

            // Центральная кнопка крупнее, обычные теперь 48
            let size: CGFloat = item.isCenter ? 68 : 48
            NSLayoutConstraint.activate([
                btn.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                btn.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                btn.widthAnchor.constraint(equalToConstant: size),
                btn.heightAnchor.constraint(equalToConstant: size)
            ])

            stack.addArrangedSubview(container)
            buttons.append(btn)
        }
    }

    private func makeRegularButton(_ item: TabItem) -> UIButton {
        let b = UIButton(type: .custom)

        let activeImg   = (UIImage(named: item.active)   ?? UIImage(systemName: item.sfFallback))?.withRenderingMode(.alwaysOriginal)
        let inactiveImg = (UIImage(named: item.inactive) ?? UIImage(systemName: item.sfFallback))?.withRenderingMode(.alwaysOriginal)

        b.setImage(inactiveImg, for: .normal)
        b.setImage(activeImg,   for: .selected)
        b.imageView?.contentMode = .scaleAspectFit
        b.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        return b
    }

    private func makeCenterButton(_ item: TabItem) -> UIButton {
        let b = UIButton(type: .custom)
        b.backgroundColor = .clear

        // main_inact (серый контур) — неактивный, main_act (зелёный) — активный
        let inactiveImg = (UIImage(named: item.inactive) ?? UIImage(systemName: item.sfFallback))?.withRenderingMode(.alwaysOriginal)
        let activeImg   = (UIImage(named: item.active)   ?? UIImage(systemName: item.sfFallback))?.withRenderingMode(.alwaysOriginal)

        b.setImage(inactiveImg, for: .normal)
        b.setImage(activeImg,   for: .selected)
        b.imageView?.contentMode = .scaleAspectFit
        b.contentEdgeInsets = .zero

        // Тень для центральной кнопки
        b.layer.shadowColor   = UIColor(red: 30/255, green: 140/255, blue: 98/255, alpha: 1).cgColor
        b.layer.shadowOpacity = 0.35
        b.layer.shadowRadius  = 10
        b.layer.shadowOffset  = CGSize(width: 0, height: 4)

        return b
    }

    @objc private func tabTapped(_ sender: UIButton) {
        selectTab(sender.tag)
        onTabSelected?(sender.tag)
    }

    func selectTab(_ index: Int, animated: Bool = true) {
        for (i, btn) in buttons.enumerated() {
            btn.isSelected = (i == index)
        }

        if animated {
            let btn = buttons[index]
            UIView.animate(withDuration: 0.1, animations: {
                btn.transform = CGAffineTransform(scaleX: 0.86, y: 0.86)
            }) { _ in
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5,
                               initialSpringVelocity: 0.5, options: .allowUserInteraction) {
                    btn.transform = .identity
                }
            }
        }
    }
}
