//
//  ProfilePhotoCoordinator.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 28.10.26.
//

import PhotosUI
import UIKit

@MainActor
final class ProfilePhotoCoordinator: NSObject, PHPickerViewControllerDelegate {
    private weak var presenter: UIViewController?

    init(presenter: UIViewController) {
        self.presenter = presenter
    }

    func showOptions(sourceView: UIView) {
        let sheet = UIAlertController(title: "Profil şəkli", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Qalereyadan seç", style: .default) { [weak self] _ in
            self?.pick()
        })
        if AvatarStore.shared.image != nil {
            sheet.addAction(UIAlertAction(title: "Şəkli sil", style: .destructive) { [weak self] _ in
                self?.remove()
            })
        }
        sheet.addAction(UIAlertAction(title: "Ləğv et", style: .cancel))
        sheet.popoverPresentationController?.sourceView = sourceView
        sheet.popoverPresentationController?.sourceRect = sourceView.bounds
        presenter?.present(sheet, animated: true)
    }

    private func pick() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        presenter?.present(picker, animated: true)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else { return }

        provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let self, let image = object as? UIImage else { return }
            Task { @MainActor in
                do {
                    try await AvatarStore.shared.upload(image)
                } catch {
                    self.presenter?.presentAuthError(error)
                }
            }
        }
    }

    private func remove() {
        Task { @MainActor in
            do {
                try await AvatarStore.shared.remove()
            } catch {
                presenter?.presentAuthError(error)
            }
        }
    }
}
