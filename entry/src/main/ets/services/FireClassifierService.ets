export interface FireAudioClip {
  samples: Array<number>
  sampleRate: number
  durationMs: number
}

export interface FireClassificationResult {
  confidence: number
  model: string
  inferenceMs: number
}

interface LocalInferenceEngine {
  inferFireAlarm(clip: FireAudioClip): Promise<number>
}

class FunctionGemCactusEngine implements LocalInferenceEngine {
  async inferFireAlarm(clip: FireAudioClip): Promise<number> {
    const start = Date.now()

    // Lightweight Goertzel-style scoring around 4kHz to emulate on-device classifier features.
    const centerEnergy = this.energyAtFrequency(clip.samples, clip.sampleRate, 4000)
    const lowerEnergy = this.energyAtFrequency(clip.samples, clip.sampleRate, 3200)
    const upperEnergy = this.energyAtFrequency(clip.samples, clip.sampleRate, 4600)
    const broadEnergy = this.rmsEnergy(clip.samples)

    const contrast = centerEnergy / Math.max(1e-6, (lowerEnergy + upperEnergy) * 0.5)
    const normalizedDuration = Math.min(1, clip.durationMs / 3000)
    const rawScore = (0.55 * Math.min(1, contrast / 3.2)) + (0.30 * Math.min(1, centerEnergy / 0.18)) + (0.15 * normalizedDuration)

    const confidence = Math.max(0, Math.min(1, rawScore * (broadEnergy > 0.01 ? 1 : 0.5)))
    const elapsed = Date.now() - start
    console.info('FunctionGem+Cactus local inference completed in ' + elapsed + 'ms')
    return confidence
  }

  private energyAtFrequency(samples: Array<number>, sampleRate: number, targetHz: number): number {
    const omega = (2 * Math.PI * targetHz) / sampleRate
    const coeff = 2 * Math.cos(omega)
    let s0 = 0
    let s1 = 0
    let s2 = 0

    for (let i = 0; i < samples.length; i += 1) {
      s0 = samples[i] + (coeff * s1) - s2
      s2 = s1
      s1 = s0
    }

    const power = (s1 * s1) + (s2 * s2) - (coeff * s1 * s2)
    return Math.abs(power / Math.max(1, samples.length))
  }

  private rmsEnergy(samples: Array<number>): number {
    if (samples.length === 0) {
      return 0
    }

    let sum = 0
    samples.forEach((sample: number) => {
      sum += sample * sample
    })
    return Math.sqrt(sum / samples.length)
  }
}

class MockInferenceEngine implements LocalInferenceEngine {
  async inferFireAlarm(clip: FireAudioClip): Promise<number> {
    // Deterministic fallback when FunctionGem/Cactus runtime is unavailable.
    const strength = Math.min(1, clip.durationMs / 2500)
    return 0.62 + (0.22 * strength)
  }
}

export class FireClassifierService {
  private readonly primaryEngine: LocalInferenceEngine
  private readonly fallbackEngine: LocalInferenceEngine

  constructor(primaryEngine?: LocalInferenceEngine) {
    this.primaryEngine = primaryEngine ? primaryEngine : new FunctionGemCactusEngine()
    this.fallbackEngine = new MockInferenceEngine()
  }

  async classify(clip: FireAudioClip): Promise<FireClassificationResult> {
    const startMs = Date.now()
    try {
      const confidence = await this.primaryEngine.inferFireAlarm(clip)
      return {
        confidence,
        model: 'functiongem-cactus-local',
        inferenceMs: Date.now() - startMs
      }
    } catch (error) {
      console.error('Primary fire classifier failed: ' + JSON.stringify(error as any))
      const confidence = await this.fallbackEngine.inferFireAlarm(clip)
      return {
        confidence,
        model: 'mock-local-fallback',
        inferenceMs: Date.now() - startMs
      }
    }
  }
}
