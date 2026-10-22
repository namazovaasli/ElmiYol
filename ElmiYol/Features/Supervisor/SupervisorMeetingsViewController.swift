//
//  SupervisorMeetingsViewController.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 19.07.26.
//

import UIKit

final class SupervisorMeetingsViewController: StudentMeetingsViewController {
    override var notificationsOrigin: NotificationsOrigin {
        get { .meetings }
        set { }
    }
}
