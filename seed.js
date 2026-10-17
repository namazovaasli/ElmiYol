const fs = require("node:fs");
const path = require("node:path");
const { cert, initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");

const serviceAccountPath = path.join(__dirname, "serviceAccountKey.json");

if (!fs.existsSync(serviceAccountPath)) {
  console.error(
    "serviceAccountKey.json tapılmadı. Firebase Console-dan service account açarını layihənin kök qovluğuna əlavə edin."
  );
  process.exit(1);
}

let serviceAccount;
try {
  serviceAccount = JSON.parse(fs.readFileSync(serviceAccountPath, "utf8"));
} catch (error) {
  console.error("serviceAccountKey.json oxunmadı və ya JSON formatı yanlışdır.");
  process.exit(1);
}

if (!serviceAccount.project_id || !serviceAccount.client_email || !serviceAccount.private_key) {
  console.error("Service account faylında tələb olunan Firebase açarları yoxdur.");
  process.exit(1);
}

initializeApp({ credential: cert(serviceAccount) });
const db = getFirestore();

// BDU siyahısı universitetin rəsmi bakalavriat ixtisasları səhifəsinə əsaslanır.
// ADA siyahısı universitetin rəsmi bakalavr proqramları səhifəsinə əsaslanır.
const catalog = [
  {
    id: "bdu",
    name: "Bakı Dövlət Universiteti",
    faculties: [
      {
        id: "mexanika-riyaziyyat",
        name: "Mexanika-riyaziyyat",
        specialities: ["Mexanika", "Riyaziyyat", "Riyaziyyat müəllimliyi"],
      },
      {
        id: "tetbiqi-riyaziyyat-kibernetika",
        name: "Tətbiqi riyaziyyat və kibernetika",
        specialities: [
          "Kompüter elmləri",
          "İnformatika (rəqəmsal bacarıqlar) müəllimliyi",
          "İnformasiya təhlükəsizliyi",
        ],
      },
      {
        id: "fizika",
        name: "Fizika",
        specialities: ["Fizika", "Fizika müəllimliyi", "Mühəndis fizikası"],
      },
      {
        id: "kimya",
        name: "Kimya",
        specialities: ["Kimya", "Kimya müəllimliyi", "Kimya mühəndisliyi", "Qida mühəndisliyi"],
      },
      {
        id: "biologiya",
        name: "Biologiya",
        specialities: ["Biologiya", "Biologiya müəllimliyi", "Biotexnologiya"],
      },
      {
        id: "ekologiya-torpaqshunasliq",
        name: "Ekologiya və torpaqşünaslıq",
        specialities: [
          "Ekologiya",
          "Bitki mühafizəsi",
          "Su bioehtiyatları və akvabitkilər",
          "Torpaqşünaslıq və aqrokimya",
          "Yer quruluşu, torpaq və şəhər kadastrı",
        ],
      },
      {
        id: "cografiya",
        name: "Coğrafiya",
        specialities: [
          "Coğrafiya",
          "Coğrafiya müəllimliyi",
          "Hidrometeorologiya",
          "Geomatika və geodeziya mühəndisliyi",
          "Turizm işinin təşkili",
        ],
      },
      {
        id: "geologiya",
        name: "Geologiya",
        specialities: ["Geologiya", "Geologiya və geofizika mühəndisliyi", "Mədən mühəndisliyi", "Meliorasiya mühəndisliyi"],
      },
      {
        id: "filologiya",
        name: "Filologiya",
        specialities: [
          "Azərbaycan dili və ədəbiyyatı müəllimliyi",
          "Dil və ədəbiyyat müəllimliyi (rus dili və ədəbiyyatı üzrə)",
          "Filologiya: alman dili və ədəbiyyatı",
          "Filologiya: Azərbaycan dili və ədəbiyyatı",
          "Filologiya: çin dili və ədəbiyyatı",
          "Filologiya: ərəb dili və ədəbiyyatı",
          "Filologiya: fars dili və ədəbiyyatı",
          "Filologiya: fransız dili və ədəbiyyatı",
          "Filologiya: ingilis dili və ədəbiyyatı",
          "Filologiya: rus dili və ədəbiyyatı",
          "Filologiya: türk dili və ədəbiyyatı",
        ],
      },
      {
        id: "tarix",
        name: "Tarix",
        specialities: ["Tarix", "Tarix müəllimliyi", "Muzey, arxiv işi və abidələrin qorunması", "Regionşünaslıq (Afrika üzrə)"],
      },
      {
        id: "beynelxalq-munasibetler-iqtisadiyyat",
        name: "Beynəlxalq münasibətlər və iqtisadiyyat",
        specialities: [
          "Beynəlxalq münasibətlər",
          "Beynəlxalq ticarət və logistika",
          "Dövlət və ictimai münasibətlər",
          "Davamlı inkişafın idarə edilməsi",
          "İqtisadiyyat",
          "Biznesin idarə edilməsi",
          "Maliyyə",
          "Menecment",
          "Statistika",
          "Politologiya",
          "Regionşünaslıq (Amerika üzrə)",
          "Regionşünaslıq (Qafqaz üzrə)",
        ],
      },
      {
        id: "huquq",
        name: "Hüquq",
        specialities: ["Hüquqşünaslıq"],
      },
      {
        id: "jurnalistika",
        name: "Jurnalistika",
        specialities: ["Jurnalistika"],
      },
      {
        id: "kitabxanaciliq-informasiya",
        name: "Kitabxanaçılıq-informasiya",
        specialities: ["Kitabxanaçılıq və informasiya"],
      },
      {
        id: "serqshunasliq",
        name: "Şərqşünaslıq",
        specialities: [
          "Regionşünaslıq (Çin üzrə)",
          "Regionşünaslıq (Ərəb ölkələri üzrə)",
          "Regionşünaslıq (İran üzrə)",
          "Regionşünaslıq (İsrail üzrə)",
          "Regionşünaslıq (Koreya üzrə)",
          "Regionşünaslıq (Pakistan üzrə)",
          "Regionşünaslıq (Türkiyə üzrə)",
          "Regionşünaslıq (Yaponiya üzrə)",
          "Tərcümə (ərəb dili üzrə)",
          "Tərcümə (fars dili üzrə)",
        ],
      },
      {
        id: "sosial-elmler-psixologiya",
        name: "Sosial elmlər və psixologiya",
        specialities: [
          "Fəlsəfə",
          "Psixologiya",
          "Sosial iş",
          "Sosiologiya",
          "Təhsildə sosial-psixoloji xidmət",
          "Korreksiyaedici təlim",
        ],
      },
    ],
  },
  {
    id: "ada",
    name: "ADA Universiteti",
    faculties: [
      {
        id: "ictimai-beynelxalq-munasibetler",
        name: "İctimai və beynəlxalq münasibətlər məktəbi",
        specialities: ["Beynəlxalq tədqiqatlar", "Kommunikasiya və rəqəmsal media", "İctimai işlər"],
      },
      {
        id: "biznes",
        name: "Biznes məktəbi",
        specialities: ["Biznesin idarə edilməsi", "İqtisadiyyat", "Maliyyə"],
      },
      {
        id: "it-muhendislik",
        name: "İnformasiya texnologiyaları və mühəndislik məktəbi",
        specialities: [
          "Kompüter elmləri",
          "Kompüter mühəndisliyi",
          "İnformasiya texnologiyaları",
          "Riyaziyyat",
          "Elektrik və elektronika mühəndisliyi",
        ],
      },
      {
        id: "huquq",
        name: "Hüquq məktəbi",
        specialities: ["Hüquq (Legum Baccalaureus)"],
      },
      {
        id: "kend-teserrufati-erzaq-elmleri",
        name: "Kənd təsərrüfatı və qida elmləri məktəbi",
        specialities: ["Aqrar texnologiyalar", "Qida texnologiyaları", "Heyvandarlıq"],
      },
      {
        id: "dizayn-memarliq",
        name: "Dizayn və memarlıq məktəbi",
        specialities: ["Memarlıq", "İnteryer dizaynı", "Şəhərsalma", "Kommunikasiya dizaynı"],
      },
    ],
  },
];

function slugify(value) {
  return value
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/[ıİ]/g, "i")
    .replace(/[əƏ]/g, "e")
    .replace(/[ğĞ]/g, "g")
    .replace(/[şŞ]/g, "s")
    .replace(/[çÇ]/g, "c")
    .replace(/[öÖ]/g, "o")
    .replace(/[üÜ]/g, "u")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-|-$/g, "");
}

function buildWrites() {
  const writes = [];

  catalog.forEach((university, universityOrder) => {
    const universityRef = db.collection("universities").doc(university.id);
    writes.push({
      ref: universityRef,
      data: { name: university.name, order: universityOrder, isActive: true },
    });

    university.faculties.forEach((faculty, facultyOrder) => {
      const facultyRef = universityRef.collection("faculties").doc(faculty.id);
      writes.push({
        ref: facultyRef,
        data: { name: faculty.name, order: facultyOrder, isActive: true },
      });

      faculty.specialities.forEach((speciality, specialityOrder) => {
        writes.push({
          ref: facultyRef.collection("specialities").doc(slugify(speciality)),
          data: { name: speciality, order: specialityOrder, isActive: true },
        });
      });
    });
  });

  return writes;
}

async function run() {
  const writes = buildWrites();
  const batchLimit = 450;

  for (let start = 0; start < writes.length; start += batchLimit) {
    const batch = db.batch();
    writes.slice(start, start + batchLimit).forEach(({ ref, data }) => {
      batch.set(ref, data, { merge: true });
    });
    await batch.commit();
  }

  console.log(`Kataloq yazıldı: ${catalog.length} universitet, ${writes.length} sənəd.`);
}

run().catch((error) => {
  console.error("Kataloq Firestore-a yazılmadı:", error.message);
  process.exitCode = 1;
});
