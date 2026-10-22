//
//  MessagesHostingController.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 21.10.26.
//

import SwiftUI
import UIKit

final class MessagesHostingController: UIHostingController<MessagesListView>, SideMenuViewControllerDelegate {

    init() {
        super.init(rootView: MessagesListView())
        rootView.onMenu = { [weak self] in
            guard let self else { return }
            self.presentSideMenu(current: .messages, delegate: self)
        }
        rootView.onNotifications = { [weak self] in
            self?.pushNotificationsScreen(from: .messages)
        }
        rootView.onOpenChat = { [weak self] person in
            self?.openChat(person)
        }
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func openChat(_ person: ChatPerson) {
        let chat = UIHostingController(rootView: ChatView(
            otherUid: person.uid,
            otherName: person.name,
            subtitle: person.subtitle,
            onBack: { [weak self] in self?.navigationController?.popViewControllerWithFade() }
        ))
        chat.hidesBottomBarWhenPushed = true
        navigationController?.pushViewControllerWithFade(chat)
    }

}
