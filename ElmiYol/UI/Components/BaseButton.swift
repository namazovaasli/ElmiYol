//
//  BaseButton.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 15.07.26.
//

import UIKit
import SnapKit

final class BaseButton: UIButton {

    enum Style {
        case primary
        case secondary
    }

    private var style: Style = .primary

    init(title: String, style: Style = .primary, showsArrow: Bool = false) {
        super.init(frame: .zero)
        self.style = style
        configureAppearance(title: title, showsArrow: showsArrow)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureAppearance(title: String, showsArrow: Bool) {
        var config = UIButton.Configuration.filled()
        config.title = title
        if showsArrow {
            config.image = UIImage(systemName: "arrow.right")
            config.imagePlacement = .trailing
            config.imagePadding = 8
        }
        config.cornerStyle = .capsule

        switch style {
        case .primary:
            config.baseBackgroundColor = AppColors.primary
            config.baseForegroundColor = .white
        case .secondary:
            config.baseBackgroundColor = UIColor(red: 0.94, green: 0.95, blue: 0.97, alpha: 1)
            config.baseForegroundColor = UIColor(red: 0.13, green: 0.16, blue: 0.24, alpha: 1)
        }

        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 17, weight: .semibold)
            return outgoing
        }

        self.configuration = config
    }

    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        alpha = enabled ? 1.0 : 0.5
    }
}
