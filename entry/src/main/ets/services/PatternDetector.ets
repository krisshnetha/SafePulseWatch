export interface PatternDetectionResult {
  consistent: boolean
  confidence: number
  peakCount: number
  shortIntervalCount: number
  pauseIntervalCount: number
}

interface PeakEvent {
  tsMs: number
}

export class PatternDetector {
  private readonly windowMs: number
  private readonly shortMinMs: number
  private readonly shortMaxMs: number
  private readonly pauseMinMs: number
  private readonly pauseMaxMs: number
  private peaks: Array<PeakEvent> = []

  constructor(
    windowMs: number = 8000,
    shortMinMs: number = 180,
    shortMaxMs: number = 900,
    pauseMinMs: number = 1100,
    pauseMaxMs: number = 3200
  ) {
    this.windowMs = windowMs
    this.shortMinMs = shortMinMs
    this.shortMaxMs = shortMaxMs
    this.pauseMinMs = pauseMinMs
    this.pauseMaxMs = pauseMaxMs
  }

  ingestCandidate(tsMs: number): PatternDetectionResult {
    this.peaks.push({ tsMs })
    this.compact(tsMs)
    return this.evaluate()
  }

  peekState(nowMs: number): PatternDetectionResult {
    this.compact(nowMs)
    return this.evaluate()
  }

  private compact(nowMs: number): void {
    this.peaks = this.peaks.filter((peak: PeakEvent) => nowMs - peak.tsMs <= this.windowMs)
  }

  private evaluate(): PatternDetectionResult {
    if (this.peaks.length < 4) {
      return {
        consistent: false,
        confidence: 0,
        peakCount: this.peaks.length,
        shortIntervalCount: 0,
        pauseIntervalCount: 0
      }
    }

    let shortIntervalCount = 0
    let pauseIntervalCount = 0

    for (let i = 1; i < this.peaks.length; i += 1) {
      const delta = this.peaks[i].tsMs - this.peaks[i - 1].tsMs
      if (delta >= this.shortMinMs && delta <= this.shortMaxMs) {
        shortIntervalCount += 1
      } else if (delta >= this.pauseMinMs && delta <= this.pauseMaxMs) {
        pauseIntervalCount += 1
      }
    }

    const enoughBeeps = shortIntervalCount >= 3
    const hasPause = pauseIntervalCount >= 1
    const densityScore = Math.min(1, this.peaks.length / 8)
    const cadenceScore = Math.min(1, shortIntervalCount / 4)
    const pauseScore = hasPause ? 1 : 0
    const confidence = (0.45 * cadenceScore) + (0.35 * pauseScore) + (0.20 * densityScore)

    return {
      consistent: enoughBeeps && hasPause && confidence >= 0.72,
      confidence,
      peakCount: this.peaks.length,
      shortIntervalCount,
      pauseIntervalCount
    }
  }
}
