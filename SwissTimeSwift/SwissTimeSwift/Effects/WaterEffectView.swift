// WaterEffectView.swift
import SwiftUI

@available(iOS 17.0, *)
struct WaterEffectView: View {
    let image: Image
    @State private var viewModel = WaterViewModel()
    @State private var currentTimeSeconds: Float = 0
    @State private var startTime: CFTimeInterval = 0
    @State private var currentPointerId: Int = 0
    
    var body: some View {
        GeometryReader { geometry in
            TimelineView(.animation) { timeline in
                let shaderParams = viewModel.getShaderUniforms(currentTimeSeconds: currentTimeSeconds)
                let w0 = shaderParams.wave0
                let w1 = shaderParams.wave1
                let w2 = shaderParams.wave2
                let w3 = shaderParams.wave3
                let w4 = shaderParams.wave4
                
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .layerEffect(
                        ShaderLibrary.waterDistortion(
                            .float(currentTimeSeconds),
                            .float2(geometry.size),
                            .float(shaderParams.globalDamping),
                            .float(shaderParams.minAmplitudeThreshold),
                            .float(Float(shaderParams.numWaves)),
                            // Wave 0
                            .float2(w0.origin),
                            .float(w0.amplitude),
                            .float(w0.frequency),
                            .float(w0.speed),
                            .float(w0.startTime),
                            // Wave 1
                            .float2(w1.origin),
                            .float(w1.amplitude),
                            .float(w1.frequency),
                            .float(w1.speed),
                            .float(w1.startTime),
                            // Wave 2
                            .float2(w2.origin),
                            .float(w2.amplitude),
                            .float(w2.frequency),
                            .float(w2.speed),
                            .float(w2.startTime),
                            // Wave 3
                            .float2(w3.origin),
                            .float(w3.amplitude),
                            .float(w3.frequency),
                            .float(w3.speed),
                            .float(w3.startTime),
                            // Wave 4
                            .float2(w4.origin),
                            .float(w4.amplitude),
                            .float(w4.frequency),
                            .float(w4.speed),
                            .float(w4.startTime)
                        ),
                        maxSampleOffset: .zero
                    )
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                viewModel.addWave(
                                    position: value.location,
                                    pointerId: currentPointerId,
                                    currentTimeSeconds: currentTimeSeconds
                                )
                            }
                            .onEnded { _ in
                                currentPointerId += 1
                            }
                    )
                    .onChange(of: timeline.date) { _, newDate in
                        if startTime == 0 {
                            startTime = newDate.timeIntervalSince1970
                        }
                        currentTimeSeconds = Float(newDate.timeIntervalSince1970 - startTime)
                        viewModel.cleanupWaves(currentTimeSeconds: currentTimeSeconds)
                    }
            }
        }
    }
}
