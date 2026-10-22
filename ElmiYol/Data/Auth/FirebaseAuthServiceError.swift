//
//  FirebaseAuthServiceError.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 22.10.26.
//
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import Foundation

enum FirebaseAuthServiceError: LocalizedError {
    case firebaseNotConfigured
    case missingCurrentUser
    case missingProjectID
    case emailDoesNotMatchCurrentAccount
    case googleSignInNotConfigured

    var errorDescription: String? {
        switch self {
        case .firebaseNotConfigured:
            return "Firebase konfiqurasiyası tapılmadı. GoogleService-Info.plist faylını tətbiqə əlavə edin."
        case .missingCurrentUser:
            return "Aktiv istifadəçi hesabı tapılmadı."
        case .missingProjectID:
            return "Firebase layihəsinin ID-si tapılmadı."
        case .emailDoesNotMatchCurrentAccount:
            return "Daxil edilmiş e-poçt aktiv hesabla uyğun gəlmir."
        case .googleSignInNotConfigured:
            return "Google girişi hələ sazlanmayıb. Firebase Console-da Google provayderini aktiv edin və yenilənmiş GoogleService-Info.plist faylını layihəyə əlavə edin."
        }
    }
}
