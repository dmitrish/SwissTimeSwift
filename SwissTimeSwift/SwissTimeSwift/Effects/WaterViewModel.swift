// WaterViewModel.swift
import SwiftUI
import Combine

@Observable
class WaterViewModel {
    private let damping: Float = 0.55
    private let minValueToRemoveWave: Float = 0.3
    private let minAmplitudeThresholdForShader: Float = 2.0
    
    private(set) var waves: [Wave] = []
    
    private var lastEmissionMap: [Int: Float] = [:]
    private let emissionCooldownSeconds: Float = 0.05
    private let initialAmplitude: Float = 80.0
    private let initialFrequency: Float = 3.0
    private let initialSpeed: Float = 400.0
    
    private var lastPositions: [Int: CGPoint] = [:]
    
    func cleanupWaves(currentTimeSeconds: Float) {
        waves = waves.filter { wave in
            let elapsedSeconds = currentTimeSeconds - wave.startTime
            let currentAmplitude = wave.amplitude * pow(damping, elapsedSeconds)
            return currentAmplitude >= minValueToRemoveWave
        }
    }
    
    func addWave(position: CGPoint, pointerId: Int, currentTimeSeconds: Float) {
        let lastEmission = lastEmissionMap[pointerId] ?? 0
        let lastPos = lastPositions[pointerId]
        let minDistance: Float = 15.0
        
        let shouldEmit: Bool
        if let lastPos = lastPos {
            let distance = sqrt(pow(Float(position.x - lastPos.x), 2) +
                              pow(Float(position.y - lastPos.y), 2))
            shouldEmit = currentTimeSeconds - lastEmission >= emissionCooldownSeconds &&
                        distance > minDistance
        } else {
            shouldEmit = currentTimeSeconds - lastEmission >= emissionCooldownSeconds
        }
        
        if shouldEmit {
            let newWave = Wave(
                origin: position,
                startTime: currentTimeSeconds,
                amplitude: initialAmplitude,
                frequency: initialFrequency,
                speed: initialSpeed
            )
            
            var currentWaves = waves
            
            // Limit to 5 waves (our shader max)
            if currentWaves.count >= WaveShaderParams.maxWaves {
                if let weakestIndex = currentWaves.enumerated().min(by: { a, b in
                    let elapsedA = currentTimeSeconds - a.element.startTime
                    let elapsedB = currentTimeSeconds - b.element.startTime
                    let ampA = a.element.amplitude * pow(damping, elapsedA)
                    let ampB = b.element.amplitude * pow(damping, elapsedB)
                    return ampA < ampB
                })?.offset {
                    currentWaves.remove(at: weakestIndex)
                }
            }
            
            currentWaves.append(newWave)
            waves = currentWaves
            
            lastEmissionMap[pointerId] = currentTimeSeconds
            lastPositions[pointerId] = position
        }
    }
    
    func getShaderUniforms(currentTimeSeconds: Float) -> WaveShaderParams {
        let maxWaves = WaveShaderParams.maxWaves
        
        var waveParams: [WaveShaderParams.WaveParams] = []
        
        for wave in waves.prefix(maxWaves) {
            let elapsedSeconds = currentTimeSeconds - wave.startTime
            let currentAmplitude = wave.amplitude * pow(damping, elapsedSeconds)
            
            waveParams.append(WaveShaderParams.WaveParams(
                origin: wave.origin,
                amplitude: currentAmplitude,
                frequency: wave.frequency,
                speed: wave.speed,
                startTime: wave.startTime
            ))
        }
        
        // Fill remaining slots with empty waves
        while waveParams.count < maxWaves {
            waveParams.append(.empty)
        }
        
        return WaveShaderParams(
            numWaves: min(waves.count, maxWaves),
            wave0: waveParams[0],
            wave1: waveParams[1],
            wave2: waveParams[2],
            wave3: waveParams[3],
            wave4: waveParams[4],
            globalDamping: damping,
            minAmplitudeThreshold: minAmplitudeThresholdForShader
        )
    }
}
