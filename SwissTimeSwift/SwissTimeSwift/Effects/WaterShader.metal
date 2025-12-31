// WaterShader.metal - Match Android exactly
#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

[[ stitchable ]] half4 waterDistortion(
    float2 position,
    SwiftUI::Layer layer,
    float time,
    float2 resolution,
    float globalDamping,
    float minAmplitudeThreshold,
    float numWaves,
    // Wave 0
    float2 origin0, float amp0, float freq0, float speed0, float start0,
    // Wave 1
    float2 origin1, float amp1, float freq1, float speed1, float start1,
    // Wave 2
    float2 origin2, float amp2, float freq2, float speed2, float start2,
    // Wave 3
    float2 origin3, float amp3, float freq3, float speed3, float start3,
    // Wave 4
    float2 origin4, float amp4, float freq4, float speed4, float start4
) {
    float2 totalDisplacement = float2(0.0, 0.0);
    int numWavesInt = int(numWaves);
    
    auto processWave = [&](float2 origin, float amplitude, float frequency, float speed, float startTime) {
        if (amplitude < minAmplitudeThreshold) {
            return;
        }
        
        float2 diff = position - origin;
        float distance = length(diff);
        
        if (distance < 0.001) {
            return;
        }
        
        float elapsedTime = time - startTime;
        
        // Wave radius - how far the wave has traveled
        float waveRadius = speed * elapsedTime;
        
        // Distance from wave front (EXACTLY like Android)
        float radialDist = distance - waveRadius;
        
        // Wave equation (EXACTLY like Android)
        // amplitude is already damped, so use it directly
        float waveValue = amplitude * sin(frequency * radialDist);
        
        // Add envelope to make wave more visible near the front
        // This creates a visible "ring" effect
        float envelope = exp(-abs(radialDist) * 0.02); // Gentle falloff
        waveValue *= envelope;
        
        waveValue *= 2.0;
        
        // Direction vector
        float2 direction = diff / distance;
        
        // Accumulate displacement
        totalDisplacement += direction * waveValue;
    };
    
    if (numWavesInt > 0) processWave(origin0, amp0, freq0, speed0, start0);
    if (numWavesInt > 1) processWave(origin1, amp1, freq1, speed1, start1);
    if (numWavesInt > 2) processWave(origin2, amp2, freq2, speed2, start2);
    if (numWavesInt > 3) processWave(origin3, amp3, freq3, speed3, start3);
    if (numWavesInt > 4) processWave(origin4, amp4, freq4, speed4, start4);
    
    float2 samplingPosition = position + totalDisplacement;
    
    return layer.sample(samplingPosition);
}
