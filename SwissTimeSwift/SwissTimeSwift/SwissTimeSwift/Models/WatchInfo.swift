import SwiftUI
import Foundation

// Core model representing a watch face
struct WatchInfo: Identifiable, Codable, Hashable {
    let id = UUID()
    let name: String
    let description: String
    let watchFaceType: WatchFaceType
    
    // Custom coding keys to exclude non-codable properties
    private enum CodingKeys: String, CodingKey {
        case name, description, watchFaceType
    }
    
    // Hash only the name for Set operations
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs: WatchInfo, rhs: WatchInfo) -> Bool {
        return lhs.name == rhs.name
    }
}

// Enum to identify different watch face types
enum WatchFaceType: String, CaseIterable, Codable {
    case valentinianus = "Valentinianus Classique"
    case concordia = "Concordia Felicitas"
    case jurgsen = "Jurgsen Zenithor"
    case horologia = "Horologia Romanum"
    case leonard = "Leonard Automatic Collection"
    case yamaNoToki = "山の時"
    case constantinus = "Constantinus Aureus Marine Chronometer"
    case romaMarina = "Roma Marina"
    case kandinsky = "Kandinsky Evening"
    case pontifex = "Pontifex Chronometra"
    case knotUrushi = "Knot Urushi"
    case centurio = "Centurio Luminor"
    case chronomagus = "Chronomagus Regum"
    case aventinus = "Aventinus Classique"
    case lucerna = "Lucerna Roma"
    case chantDuTemps = "Chant du Temps"
    case edgeOfSecond = "Грань Секунды"
    case zeitwerk = "Alpenglühen Zeitwerk"
    case vostok = "Vostok Military"
    
    var displayName: String {
        return self.rawValue
    }
}

// MARK: - Watch Collection
extension WatchInfo {
    static let allWatches: [WatchInfo] = [
        WatchInfo(
            name: "Valentinianus Classique",
            description: "The Valentinianus Classique embodies the essence of pure style with its minimalist design and exceptional craftsmanship. Founded in 1755, Valentinianus is one of the oldest watch manufacturers in the world, known for its elegant timepieces.",
            watchFaceType: .valentinianus
        ),
        WatchInfo(
            name: "Concordia Felicitas",
            description: "The Concordia Felicitas features a unique reversible case originally designed for polo players in the 1930s. This Art Deco masterpiece combines technical innovation with timeless elegance, showcasing the brand's commitment to precision and craftsmanship.",
            watchFaceType: .concordia
        ),
        WatchInfo(
            name: "Jurgsen Zenithor",
            description: "The Jurgsen Zenithor, introduced in 1947, was one of the first modern diving watches. With its distinctive black dial and luminous markers, it set the standard for dive watches with features like water resistance, rotating bezel, and excellent legibility.",
            watchFaceType: .jurgsen
        ),
        WatchInfo(
            name: "Horologia Romanum",
            description: "The Horologia Romanum features a clean dial design inspired by precision marine chronometers. Known for its large case size and elegant simplicity, it represents HR's commitment to technical excellence and timeless design.",
            watchFaceType: .horologia
        ),
        WatchInfo(
            name: "Leonard Automatic Collection",
            description: "The Leonard Automaic showcases the brand's heritage of elegance and precision. With its classic design featuring roman numerals and a moonphase display, it represents Leonards' commitment to traditional watchmaking values and timeless aesthetics.",
            watchFaceType: .leonard
        ),
        WatchInfo(
            name: "山の時",
            description: "The 山の時 (Yama-no-Toki) collection, named after founder 山の時, represents the pinnacle of the brand's watchmaking expertise. Featuring in-house movements and exquisite finishing, these timepieces combine technical innovation with elegant design.",
            watchFaceType: .yamaNoToki
        ),
        WatchInfo(
            name: "Constantinus Aureus Marine Chronometer",
            description: "The Constantinus Aureus Chronometer continues the brand's heritage of producing precise marine chronometers for navigation. With its distinctive power reserve indicator and date display, it combines traditional craftsmanship with modern innovation.",
            watchFaceType: .constantinus
        ),
        WatchInfo(
            name: "Roma Marina",
            description: "The Roma Marina, first introduced in 1975, features an integrated bracelet and octagonal bezel. With its distinctive hobnail pattern dial, it represents the brand's ability to combine technical excellence with distinctive design elements.",
            watchFaceType: .romaMarina
        ),
        WatchInfo(
            name: "Kandinsky Evening",
            description: "The Kandinsky Evening watch face is inspired by Wassily Kandinsky's famous 'Circles in a Circle' painting. It features a light background with multiple colored circles of various sizes and intersecting lines, creating a vibrant and artistic timepiece that celebrates the abstract art movement.",
            watchFaceType: .kandinsky
        ),
        WatchInfo(
            name: "Pontifex Chronometra",
            description: "The Pontifex Chronometra combines distinctive design elements with exceptional craftsmanship. Founded in 1996, this independent Swiss manufacturer draws on traditional techniques while incorporating modern innovations, resulting in watches with unique teardrop lugs and meticulously finished movements.",
            watchFaceType: .pontifex
        ),
        WatchInfo(
            name: "Knot Urushi",
            description: "The Knot Urushi is a collaboration between modern watchmaking and traditional Japanese craftsmanship. Its deep jet black dial is created through the meticulous Urushi lacquer technique, involving repeated painting, drying, and sharpening by skilled artisans. The dial is adorned with gold powder scraped from gold ingots, creating a subtle shimmer effect as light plays across the surface.",
            watchFaceType: .knotUrushi
        ),
        WatchInfo(
            name: "Centurio Luminor",
            description: "The Centurio Luminor is renowned for its minimalist design and signature fumé dial that gradually darkens from center to edge. Founded in 1848, this independent Swiss manufacturer creates timepieces that combine traditional craftsmanship with contemporary aesthetics and innovative complications.",
            watchFaceType: .centurio
        ),
        WatchInfo(
            name: "Chronomagus Regum",
            description: "The Chronomagus Regum is celebrated for its ultra-thin profile and minimalist design. Since the 1950s, Chronomagus has been a pioneer in creating incredibly slim watches, with the Regum line showcasing the brand's expertise in producing elegant timepieces that combine technical innovation with refined aesthetics.",
            watchFaceType: .chronomagus
        ),
        WatchInfo(
            name: "Aventinus Classique",
            description: "The Aventinus Classique embodies the timeless elegance of Jean-Louis Aventinus's original designs. With its coin-edge case, guilloche dial, and distinctive Aventins hands with hollow moon tips, it represents the pinnacle of traditional Swiss watchmaking and horological heritage.",
            watchFaceType: .aventinus
        ),
        WatchInfo(
            name: "Lucerna Roma",
            description: "The Lucerna Roma features a distinctive tonneau (barrel) shape case and bold, colorful numerals. Known as the 'Master of Inventions', Lucerna Roma combines avant-garde design with traditional Swiss watchmaking expertise to create timepieces that are both technically impressive and visually striking.",
            watchFaceType: .lucerna
        ),
        WatchInfo(
            name: "Chant du Temps",
            description: "The Chant Du Temps exemplifies pure, minimalist elegance with its slim profile and clean dial. As one of the oldest continuously operating watch manufacturers, Chant Du Temps combines centuries of tradition with contemporary refinement in this timeless dress watch.",
            watchFaceType: .chantDuTemps
        ),
        WatchInfo(
            name: "Грань Секунды",
            description: "The Грань Секунды combines classic design with sophisticated complications like power reserve indicators and chronographs. Founded in St. Petersburg in 1888, Грань Секунды represents Russian watchmaking tradition with its elegant aesthetics and technical excellence.",
            watchFaceType: .edgeOfSecond
        ),
        WatchInfo(
            name: "Alpenglühen Zeitwerk",
            description: "The Alpenglühen Zeitwerk features a deep blue dial inspired by the Atlantic Ocean, combining artistry with functionality. This German-made timepiece combines Bauhaus minimalism with dive watch functionality, featuring a waterproof design, luminous markers, and the distinctive red seconds hand.",
            watchFaceType: .zeitwerk
        ),
        WatchInfo(
            name: "Vostok Military",
            description: "Vostok Military pays tribute to the rugged Amphibia watches produced for the Soviet and Russian armed forces. Known for their durable cases, ingenious Amphibia waterproofing with a self‑sealing caseback, and bold utilitarian dials, these mechanical timepieces are built to withstand harsh conditions.",
            watchFaceType: .vostok
        )
    ]
}