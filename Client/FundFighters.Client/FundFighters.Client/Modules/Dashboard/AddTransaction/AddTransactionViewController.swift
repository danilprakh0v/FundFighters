/*
===============================================================================
Проект: FundFighters (iOS UIKit [Client/Backend Service])
Файл: AddTransactionViewController.swift
Расположение: Client/FundFighters.Client/FundFighters.Client/Modules/Dashboard/AddTransaction/
Назначение: Контроллер добавления новой транзакции
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 04.02.2026
===============================================================================
*/

import UIKit

final class AddTransactionViewController: UIViewController {

    // MARK: - Свойства (Properties)

    var onTransactionAdded: (() -> Void)?
    private var selectedCategory: String = "Other"
    private var isExpense: Bool = true

    // MARK: - UI Элементы: Фон и Контейнер

    // View для затемнения фона
    private let backdropView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 28
        v.layer.cornerCurve = .continuous
        v.layer.shadowColor  = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.18
        v.layer.shadowOffset  = CGSize(width: 0, height: 12)
        v.layer.shadowRadius  = 24
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // MARK: - UI Элементы: Заголовок

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "New transaction"
        l.font = DS.golosBold(26)
        l.textColor = DS.textPrimary
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private lazy var closeButton: UIButton = {
        let b = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold)
        b.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: cfg), for: .normal)
        b.tintColor = .systemGray3
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return b
    }()

    // MARK: - UI Элементы: Сумма

    private let amountContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.systemGray6
        v.layer.cornerRadius = 14
        v.layer.cornerCurve = .continuous
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let amountField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "0.00"
        tf.keyboardType = .decimalPad
        tf.textColor = DS.textPrimary
        tf.font = DS.golosBold(36)
        tf.textAlignment = .right
        tf.setContentHuggingPriority(.required, for: .horizontal)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let currencyLabel: UILabel = {
        let l = UILabel()
        l.text = "₽"
        l.font = DS.golosBold(36)
        l.textColor = DT.accentGreen
        l.isHidden = true
        l.alpha = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // MARK: - UI Элементы: Переключатель типа

    private lazy var expenseBtn: LiquidGlassActionButton = {
        let b = LiquidGlassActionButton(title: "Expense", color: DT.expenseRed)
        b.tag = 0
        b.addTarget(self, action: #selector(typeTapped(_:)), for: .touchUpInside)
        return b
    }()

    private lazy var incomeBtn: LiquidGlassActionButton = {
        let b = LiquidGlassActionButton(title: "Income", color: DT.accentGreen)
        b.tag = 1
        b.addTarget(self, action: #selector(typeTapped(_:)), for: .touchUpInside)
        return b
    }()

    private lazy var typeStack: UIStackView = {
        let s = UIStackView(arrangedSubviews: [expenseBtn, incomeBtn])
        s.axis = .horizontal
        s.spacing = 12
        s.distribution = .fillEqually
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    // MARK: - UI Элементы: Поля ввода

    private let descriptionField: UITextField = {
        AddTransactionViewController.styledField(
            placeholder: "Description (e.g. Spotify)",
            iconName: "text.alignleft"
        )
    }()

    private lazy var categoryButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "Category: Other"
        config.baseForegroundColor = DS.textPrimary
        config.image = UIImage(systemName: "bag.fill")
        config.imagePadding = 12
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)

        let b = UIButton(configuration: config)
        b.backgroundColor = UIColor.systemGray6
        b.layer.cornerRadius = 14
        b.layer.cornerCurve = .continuous
        b.contentHorizontalAlignment = .leading
        b.showsMenuAsPrimaryAction = true
        b.translatesAutoresizingMaskIntoConstraints = false

        let categories: [(String, String)] = [
            ("Subscriptions", "play.circle.fill"),
            ("Food",          "cart.fill"),
            ("Rent",          "house.fill"),
            ("Income",        "briefcase.fill"),
            ("Entertainment", "tv.fill"),
            ("Tech",          "laptopcomputer"),
            ("Transport",     "car.fill"),
            ("Health",        "heart.fill"),
            ("Other",         "bag.fill")
        ]
        let actions = categories.map { cat in
            UIAction(title: cat.0,
                     image: UIImage(systemName: cat.1)) { [weak self] _ in
                guard let self else { return }
                self.selectedCategory = cat.0
                var cfg = self.categoryButton.configuration
                cfg?.title = "Category: \(cat.0)"
                cfg?.image = UIImage(systemName: cat.1)
                self.categoryButton.configuration = cfg
            }
        }
        b.menu = UIMenu(title: "Select category", children: actions)
        return b
    }()

    // MARK: - UI Элементы: Кнопка сохранения

    private lazy var saveButton: LiquidGlassActionButton = {
        let b = LiquidGlassActionButton(title: "Add transaction",
                                        color: DT.deepContrastGreen)
        b.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        return b
    }()

    // MARK: - Жизненный цикл (Lifecycle)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupLayout()

        // Установка начального состояния переключателя
        expenseBtn.setActive(true,  activeColor: DT.expenseRed)
        incomeBtn.setActive(false,  activeColor: DT.accentGreen)

        amountField.addTarget(self, action: #selector(amountChanged), for: .editingChanged)

        let backdropTap = UITapGestureRecognizer(target: self, action: #selector(backdropTapped))
        backdropView.addGestureRecognizer(backdropTap)
    }

    // MARK: - Настройка верстки (Layout)

    private func setupLayout() {
        view.addSubview(backdropView)
        view.addSubview(containerView)

        let amountRow = UIStackView(arrangedSubviews: [amountField, currencyLabel])
        amountRow.axis      = .horizontal
        amountRow.spacing   = 6
        amountRow.alignment = .center
        amountRow.translatesAutoresizingMaskIntoConstraints = false
        amountContainer.addSubview(amountRow)

        [titleLabel, closeButton,
         amountContainer,
         typeStack,
         descriptionField,
         categoryButton,
         saveButton].forEach { containerView.addSubview($0) }

        NSLayoutConstraint.activate([
            // Фон (Backdrop)
            backdropView.topAnchor.constraint(equalTo: view.topAnchor),
            backdropView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backdropView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backdropView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // Карточка (Card)
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40),

            // Кнопка закрытия
            closeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),

            // Заголовок
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 36),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),

            // Контейнер суммы
            amountContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            amountContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            amountContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            amountContainer.heightAnchor.constraint(equalToConstant: 76),

            amountRow.centerXAnchor.constraint(equalTo: amountContainer.centerXAnchor),
            amountRow.centerYAnchor.constraint(equalTo: amountContainer.centerYAnchor),
            amountField.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),

            // Переключатель типа
            typeStack.topAnchor.constraint(equalTo: amountContainer.bottomAnchor, constant: 16),
            typeStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            typeStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            typeStack.heightAnchor.constraint(equalToConstant: 56),

            // Описание
            descriptionField.topAnchor.constraint(equalTo: typeStack.bottomAnchor, constant: 14),
            descriptionField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            descriptionField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            descriptionField.heightAnchor.constraint(equalToConstant: 54),

            // Кнопка выбора категории
            categoryButton.topAnchor.constraint(equalTo: descriptionField.bottomAnchor, constant: 10),
            categoryButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            categoryButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            categoryButton.heightAnchor.constraint(equalToConstant: 54),

            // Кнопка сохранения
            saveButton.topAnchor.constraint(equalTo: categoryButton.bottomAnchor, constant: 24),
            saveButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            saveButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            saveButton.heightAnchor.constraint(equalToConstant: 56),

            containerView.bottomAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 28)
        ])
    }

    // MARK: - Переключение типа (Type Toggle)

    @objc private func typeTapped(_ sender: UIControl) {
        let selectExpense = (sender.tag == 0)
        guard selectExpense != isExpense else { return }
        isExpense = selectExpense
        animateToggle(toExpense: selectExpense)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func animateToggle(toExpense: Bool) {
        UIView.animate(
            withDuration: 0.35,
            delay: 0,
            usingSpringWithDamping: 0.72,
            initialSpringVelocity: 0.4,
            options: [.allowUserInteraction, .curveEaseInOut]
        ) {
            self.expenseBtn.setActive( toExpense, activeColor: DT.expenseRed)
            self.incomeBtn.setActive(!toExpense,  activeColor: DT.accentGreen)
            self.typeStack.layoutIfNeeded()
        }
    }

    // MARK: - Поле ввода суммы (Amount Field)

    @objc private func amountChanged() {
        let hasText = !(amountField.text?.isEmpty ?? true)

        if hasText && currencyLabel.isHidden {
            currencyLabel.alpha  = 0
            currencyLabel.isHidden = false
            UIView.animate(withDuration: 0.3, delay: 0,
                           usingSpringWithDamping: 0.65, initialSpringVelocity: 0.5) {
                self.currencyLabel.alpha = 1
                self.view.layoutIfNeeded()
            }
        } else if !hasText && !currencyLabel.isHidden {
            UIView.animate(withDuration: 0.2) {
                self.currencyLabel.alpha = 0
            } completion: { _ in
                self.currencyLabel.isHidden = true
            }
        }
    }

    // MARK: - Сохранение (Save)

    @objc private func saveTapped() {
        view.endEditing(true)

        // Валидация введенной суммы
        let rawText = amountField.text ?? ""
        let cleaned = rawText
            .filter { "0123456789.,".contains($0) }
            .replacingOccurrences(of: ",", with: ".")

        guard let amount = Double(cleaned), amount > 0 else {
            shake(amountContainer); return
        }

        // Валидация описания
        let titleText = (descriptionField.text ?? "").trimmingCharacters(in: .whitespaces)
        guard !titleText.isEmpty else {
            shake(descriptionField); return
        }

        // Подготовка и отправка запроса к API
        let request = ProcessTransactionRequest(
            amount:   Decimal(amount),
            type:     isExpense ? 0 : 1,
            title:    titleText,
            category: selectedCategory
        )

        saveButton.isEnabled = false
        saveButton.showLoading(true)

        APIService.shared.addTransaction(request: request) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.saveButton.showLoading(false)
                self.saveButton.isEnabled = true

                switch result {
                case .success:
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    self.onTransactionAdded?()
                    self.dismiss(animated: true)

                case .failure(let error):
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                    self.shake(self.saveButton)
                    let alert = UIAlertController(
                        title:   "Error",
                        message: error.localizedDescription,
                        preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }

    // MARK: - Действия (Actions)

    @objc private func closeTapped()   { dismiss(animated: true) }
    @objc private func backdropTapped() { view.endEditing(true) }

    // MARK: - Вспомогательные методы (Helpers)

    private func shake(_ target: UIView) {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        let anim = CAKeyframeAnimation(keyPath: "transform.translation.x")
        anim.timingFunction = CAMediaTimingFunction(name: .linear)
        anim.duration = 0.4
        anim.values   = [-10, 10, -8, 8, -5, 5, 0]
        target.layer.add(anim, forKey: "shake")
    }

    private static func styledField(placeholder: String,
                                    iconName: String) -> UITextField {
        let tf = UITextField()
        tf.placeholder       = placeholder
        tf.backgroundColor   = UIColor.systemGray6
        tf.layer.cornerRadius  = 14
        tf.layer.cornerCurve   = .continuous
        tf.textColor         = DS.textPrimary
        tf.font              = DS.golosMedium(16)

        let iconView = UIImageView(image: UIImage(systemName: iconName))
        iconView.tintColor   = DS.textSecondary
        iconView.contentMode = .scaleAspectFit
        iconView.frame       = CGRect(x: 16, y: 0, width: 20, height: 20)

        let padding = UIView(frame: CGRect(x: 0, y: 0, width: 48, height: 20))
        padding.addSubview(iconView)
        tf.leftView     = padding
        tf.leftViewMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }
}
