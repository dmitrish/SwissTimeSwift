// Wave.swift
import SwiftUI

struct Wave: Identifiable {
    let id = UUID()
    let origin: CGPoint
    let startTime: Float
    let amplitude: Float
    let frequency: Float
    let speed: Float
}
