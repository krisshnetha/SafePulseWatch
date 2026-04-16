export interface FrequencyAnalysisResult {
  dominantFrequencyHz: number
  dominantMagnitude: number
  bandPeakFrequencyHz: number
  bandPeakMagnitude: number
  smoothedBandMagnitude: number
  noiseFloor: number
  snr: number
  candidate: boolean
}

export class FrequencyAnalyzer {
  private readonly bandMinHz: number
  private readonly bandMaxHz: number
  private readonly targetHz: number
  private readonly emaAlpha: number
  private smoothedBandMagnitude: number = 0

  constructor(
    bandMinHz: number = 3000,
    bandMaxHz: number = 4500,
    targetHz: number = 4000,
    emaAlpha: number = 0.35
  ) {
    this.bandMinHz = bandMinHz
    this.bandMaxHz = bandMaxHz
    this.targetHz = targetHz
    this.emaAlpha = emaAlpha
  }

  analyze(samples: Array<number>, sampleRate: number): FrequencyAnalysisResult {
    const fftSize = this.nextPowerOfTwo(samples.length)
    const real: Array<number> = new Array(fftSize).fill(0)
    const imag: Array<number> = new Array(fftSize).fill(0)

    for (let i = 0; i < samples.length; i += 1) {
      // Hanning window reduces spectral leakage in short rolling frames.
      const w = 0.5 - 0.5 * Math.cos((2 * Math.PI * i) / (samples.length - 1))
      real[i] = samples[i] * w
    }

    this.fftInPlace(real, imag)

    const half = Math.floor(fftSize / 2)
    let dominantIndex = 0
    let dominantMagnitude = 0
    let bandPeakIndex = 0
    let bandPeakMagnitude = 0
    let magnitudeSum = 0

    for (let i = 1; i < half; i += 1) {
      const magnitude = Math.sqrt((real[i] * real[i]) + (imag[i] * imag[i]))
      magnitudeSum += magnitude

      if (magnitude > dominantMagnitude) {
        dominantMagnitude = magnitude
        dominantIndex = i
      }

      const freq = (i * sampleRate) / fftSize
      if (freq >= this.bandMinHz && freq <= this.bandMaxHz && magnitude > bandPeakMagnitude) {
        bandPeakMagnitude = magnitude
        bandPeakIndex = i
      }
    }

    const noiseFloor = magnitudeSum / Math.max(1, half - 1)
    this.smoothedBandMagnitude =
      (this.emaAlpha * bandPeakMagnitude) + ((1 - this.emaAlpha) * this.smoothedBandMagnitude)

    const snr = noiseFloor > 0 ? this.smoothedBandMagnitude / noiseFloor : 0
    const bandPeakFrequencyHz = (bandPeakIndex * sampleRate) / fftSize
    const nearTarget = Math.abs(bandPeakFrequencyHz - this.targetHz) <= 280
    const strongPeak = snr >= 3.0 && this.smoothedBandMagnitude > 7

    return {
      dominantFrequencyHz: (dominantIndex * sampleRate) / fftSize,
      dominantMagnitude,
      bandPeakFrequencyHz,
      bandPeakMagnitude,
      smoothedBandMagnitude: this.smoothedBandMagnitude,
      noiseFloor,
      snr,
      candidate: nearTarget && strongPeak
    }
  }

  private nextPowerOfTwo(value: number): number {
    let n = 1
    while (n < value) {
      n *= 2
    }
    return n
  }

  private fftInPlace(real: Array<number>, imag: Array<number>): void {
    const n = real.length
    let j = 0

    for (let i = 1; i < n; i += 1) {
      let bit = n >> 1
      while ((j & bit) !== 0) {
        j ^= bit
        bit >>= 1
      }
      j ^= bit

      if (i < j) {
        const tr = real[i]
        const ti = imag[i]
        real[i] = real[j]
        imag[i] = imag[j]
        real[j] = tr
        imag[j] = ti
      }
    }

    for (let len = 2; len <= n; len <<= 1) {
      const angle = (-2 * Math.PI) / len
      const wLenR = Math.cos(angle)
      const wLenI = Math.sin(angle)

      for (let i = 0; i < n; i += len) {
        let wr = 1
        let wi = 0

        for (let k = 0; k < (len >> 1); k += 1) {
          const uR = real[i + k]
          const uI = imag[i + k]
          const vR = (real[i + k + (len >> 1)] * wr) - (imag[i + k + (len >> 1)] * wi)
          const vI = (real[i + k + (len >> 1)] * wi) + (imag[i + k + (len >> 1)] * wr)

          real[i + k] = uR + vR
          imag[i + k] = uI + vI
          real[i + k + (len >> 1)] = uR - vR
          imag[i + k + (len >> 1)] = uI - vI

          const nextWr = (wr * wLenR) - (wi * wLenI)
          wi = (wr * wLenI) + (wi * wLenR)
          wr = nextWr
        }
      }
    }
  }
}
