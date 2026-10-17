# Firestore kataloqunun seed edilməsi

Seed skripti tətbiqin oxuduğu Firestore quruluşuna yazır:

- `universities/{universityId}`
- `universities/{universityId}/faculties/{facultyId}`
- `universities/{universityId}/faculties/{facultyId}/specialities/{specialityId}`

Hər sənəddə `name`, `order` və `isActive` sahələri olur. Skript `merge` ilə yazdığı üçün mövcud əlavə sahələri saxlayır; kataloqdan çıxarılan sənədləri avtomatik silmir.

## Hazırlıq

1. Firebase Console-da **Project settings → Service accounts → Generate new private key** seçin.
2. Endirilən JSON-u layihənin kök qovluğunda `serviceAccountKey.json` adı ilə saxlayın. Bu faylı GitHub-a yükləməyin; `.gitignore`-a əlavə olunub.
3. Layihənin kök qovluğunda asılılığı quraşdırın:

   ```sh
   npm install firebase-admin
   ```

   Firebase Admin SDK 14 Node.js 22 və ya daha yeni versiya tələb edir.

4. Firestore-a yazmağı qəsdən başlatmaq üçün:

   ```sh
   npm run seed
   ```

Skript service account faylı və Firebase layihə məlumatı olmadıqda Firestore-a qoşulmadan dayanır. Skripti işlətməyincə verilənlər bazasına heç nə yazılmır.

## Məlumat mənbələri və əhatə

- BDU: [bakalavriat səviyyəsi üzrə rəsmi ixtisas siyahısı](https://bdu.info.az/tehsil/bakalavriat-seviyyesi-uzre-ixtisaslarin-siyahisi). Yeni açılan **Regionşünaslıq (Afrika üzrə)** BDU-nun [2026/2027-ci tədris ili barədə məlumatından](https://bdu.info.az/xeberlerr/bdu-da-yeni-tedris-ili-baslayib26) əlavə edilib.
- ADA Universiteti: [rəsmi bakalavr proqramları və məktəblər](https://www.ada.edu.az/en/admission/undergraduate).

Bu ilkin kataloq BDU və ADA-nın bakalavr proqramlarını əhatə edir. BDU siyahısındakı ixtisaslar tətbiqdə seçim rahat olsun deyə fakültələrə qruplaşdırılıb; rəsmi mənbə bütün ixtisasları verir, lakin kataloq API-sində fakültə–ixtisas uyğunluğunu ayrıca təqdim etmir. Yeni proqramlar açıldıqda `seed.js`-də siyahını yeniləyib yenidən işlədin.
