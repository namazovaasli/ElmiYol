//
//  PillTabButton.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 19.07.26.
//

import UIKit
import SnapKit

final class PillTabButton: UIButton {

    init(title: String) {
        super.init(frame: .zero)
        configureAppearance(title: title)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureAppearance(title: String) {
        var config = UIButton.Configuration.filled()
        config.attributedTitle = AttributedString(title, attributes: AttributeContainer([
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ]))
        config.cornerStyle = .capsule
        config.baseBackgroundColor = .white
        config.baseForegroundColor = AppColors.textPrimary
        configuration = config
    }

    func setSelected(_ selected: Bool) {
        var config = configuration
        config?.baseBackgroundColor = selected ? AppColors.primary : .white
        config?.baseForegroundColor = selected ? .white : AppColors.textPrimary
        configuration = config
    }
}
