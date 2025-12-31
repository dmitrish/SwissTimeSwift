// WaveShaderParams.swift
import CoreGraphics

struct WaveShaderParams {
    let numWaves: Int
    let wave0: WaveParams
    let wave1: WaveParams
    let wave2: WaveParams
    let wave3: WaveParams
    let wave4: WaveParams
    let globalDamping: Float
    let minAmplitudeThreshold: Float
    
    struct WaveParams {
        let origin: CGPoint
        let amplitude: Float
        let frequency: Float
        let speed: Float
        let startTime: Float
        
        static let empty = WaveParams(
            origin: .zero,
            amplitude: 0,
            frequency: 0,
            speed: 0,
            startTime: 0
        )
    }
    
    static let maxWaves = 5
}
