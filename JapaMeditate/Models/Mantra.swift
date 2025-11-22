//
//  Mantra.swift
//  Japa108App
//
//  Created by Anilkumar Devisetty on 11/15/25.
//
enum Mantra: String, CaseIterable, Identifiable, Codable {

    case omNamahShivaya = "ॐ नमः शिवाय"
    case hareKrishna = """
        हरे कृष्ण हरे कृष्ण
        कृष्ण कृष्ण हरे हरे
        हरे राम हरे राम
        राम राम हरे हरे
        """
    case gayatri = """
        ॐ भूर् भुवः स्वः
        तत्सवितुर्वरेण्यं
        भर्गो देवस्य धीमहि
        धियो यो नः प्रचोदयात्
        """
    case om = "ॐ"
    case mahaMrityunjaya = """
        ॐ त्र्यम्बकं यजामहे
        सुगन्धिं पुष्टिवर्धनम्
        उर्वारुकमिव बन्धनान्
        मृत्योर्मुक्षीय माऽमृतात्
        """
    case custom = "<custom>"

    var id: String { rawValue }

    // Display title
    var title: String {
        switch self {
        case .omNamahShivaya: return "Om Namah Shivaya"
        case .hareKrishna: return "Hare Krishna Maha Mantra"
        case .gayatri: return "Gayatri Mantra"
        case .om: return "Om"
        case .mahaMrityunjaya: return "Maha Mrityunjaya"
        case .custom: return "Custom Mantra"
        }
    }

    // 🔥 NEW — proper Sanskrit → English transliteration
    var transliteration: String {
        switch self {

        case .omNamahShivaya:
            return "Om Namah Śivāya"

        case .hareKrishna:
            return """
            Hare Kṛṣṇa Hare Kṛṣṇa,
            Kṛṣṇa Kṛṣṇa Hare Hare;
            Hare Rāma Hare Rāma,
            Rāma Rāma Hare Hare
            """

        case .gayatri:
            return """
            Om Bhūr Bhuvaḥ Svaḥ,
            Tat Savitur Vareṇyaṃ,
            Bhargo Devasya Dhīmahi,
            Dhiyo Yo Naḥ Pracodayāt
            """

        case .om:
            return "Om"

        case .mahaMrityunjaya:
            return """
            Om Tryambakaṃ Yajāmahe,
            Sugandhiṃ Puṣṭi-vardhanam,
            Urvārukam iva Bandhanān,
            Mṛtyor Mukṣīya Mā’mṛtāt
            """

        case .custom:
            return ""
        }
    }

    // Existing audio mapping
//    var audioFileName: String? {
//        switch self {
//        case .omNamahShivaya: return "om_namah_shivaya.mp3"
//        case .hareKrishna: return "hare_krishna.mp3"
//        case .gayatri: return "gayatri.mp3"
//        case .om: return "om.mp3"
//        case .mahaMrityunjaya: return "mahamrityunjaya.mp3"
//        case .custom: return nil
//        }
//    }
}
