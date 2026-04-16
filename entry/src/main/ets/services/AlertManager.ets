import { FireAudioService, AudioFrame } from './FireAudioService'
import { FrequencyAnalyzer, FrequencyAnalysisResult } from './FrequencyAnalyzer'
import { PatternDetector, PatternDetectionResult } from './PatternDetector'
import { FireClassifierService, FireAudioClip, FireClassificationResult } from './FireClassifierService'
import { DeviceCommService } from './DeviceCommService'
import { AlertStorageService, FireAlertRecord } from './AlertStorageService'
import { VibrationService } from './VibrationService'

export interface MonitoringSnapshot {
  running: boolean
  framesProcessed: number
  frequencyCandidate: boolean
  patternConfidence: number
  aiConfidence: number
  pendingAi: boolean
  lastDecision: string
  lastFrameAt: string
}

export interface FireDetectionAlert {
  timestamp: string
  confidence: number
  method: string
}

export class AlertManager {
  private readonly audioService: FireAudioService
  private readonly analyzer: FrequencyAnalyzer
  private readonly patternDetector: PatternDetector
  private readonly classifier: FireClassifierService
  private readonly deviceCommService: DeviceCommService
  private readonly vibrationService: VibrationService

  private unsubscribeFrame: (() => void) | null = null
  private clipBuffer: Array<number> = []
  private clipMaxSamples: number = 48000
  private classificationInFlight: boolean = false
  private lastAlertEpochMs: number = 0
  private readonly cooldownMs: number = 15000

  private snapshot: MonitoringSnapshot = {
    running: false,
    framesProcessed: 0,
    frequencyCandidate: false,
    patternConfidence: 0,
    aiConfidence: 0,
    pendingAi: false,
    lastDecision: 'Monitoring idle',
    lastFrameAt: '-'
  }

  onAlert: (alert: FireDetectionAlert) => void = () => {}
  onSnapshot: (snapshot: MonitoringSnapshot) => void = () => {}

  constructor(
    audioService?: FireAudioService,
    analyzer?: FrequencyAnalyzer,
    patternDetector?: PatternDetector,
    classifier?: FireClassifierService,
    deviceCommService?: DeviceCommService,
    vibrationService?: VibrationService
  ) {
    this.audioService = audioService ? audioService : new FireAudioService()
    this.analyzer = analyzer ? analyzer : new FrequencyAnalyzer()
    this.patternDetector = patternDetector ? patternDetector : new PatternDetector(9000)
    this.classifier = classifier ? classifier : new FireClassifierService()
    this.deviceCommService = deviceCommService ? deviceCommService : new DeviceCommService()
    this.vibrationService = vibrationService ? vibrationService : new VibrationService()
  }

  async start(): Promise<void> {
    if (this.snapshot.running) {
      return
    }

    this.unsubscribeFrame = this.audioService.onFrame((frame: AudioFrame) => {
      this.handleAudioFrame(frame)
    })

    await this.audioService.start()
    this.snapshot.running = true
    this.snapshot.lastDecision = 'Live monitoring active'
    this.emitSnapshot()
  }

  async stop(): Promise<void> {
    if (!this.snapshot.running) {
      return
    }

    if (this.unsubscribeFrame !== null) {
      this.unsubscribeFrame()
      this.unsubscribeFrame = null
    }

    await this.audioService.stop()
    this.snapshot.running = false
    this.snapshot.pendingAi = false
    this.snapshot.lastDecision = 'Monitoring paused'
    this.emitSnapshot()
  }

  getSnapshot(): MonitoringSnapshot {
    // ArkTS can reject object spread in some contexts; copy fields explicitly.
    return {
      running: this.snapshot.running,
      framesProcessed: this.snapshot.framesProcessed,
      frequencyCandidate: this.snapshot.frequencyCandidate,
      patternConfidence: this.snapshot.patternConfidence,
      aiConfidence: this.snapshot.aiConfidence,
      pendingAi: this.snapshot.pendingAi,
      lastDecision: this.snapshot.lastDecision,
      lastFrameAt: this.snapshot.lastFrameAt
    }
  }

  private async handleAudioFrame(frame: AudioFrame): Promise<void> {
    this.snapshot.framesProcessed += 1
    this.snapshot.lastFrameAt = new Date(frame.capturedAtMs).toISOString()

    this.appendClipSamples(frame.samples, frame.sampleRate)

    const frequencyResult: FrequencyAnalysisResult = this.analyzer.analyze(frame.samples, frame.sampleRate)
    this.snapshot.frequencyCandidate = frequencyResult.candidate

    let patternResult: PatternDetectionResult
    if (frequencyResult.candidate) {
      patternResult = this.patternDetector.ingestCandidate(frame.capturedAtMs)
    } else {
      patternResult = this.patternDetector.peekState(frame.capturedAtMs)
    }

    this.snapshot.patternConfidence = patternResult.confidence
    this.snapshot.lastDecision = frequencyResult.candidate
      ? 'Strong 3k-4.5kHz peak detected'
      : 'No high-confidence alarm tone in latest frame'

    this.emitSnapshot()

    if (patternResult.consistent) {
      await this.evaluateWithClassifier(frame.sampleRate)
    }
  }

  private appendClipSamples(samples: Array<number>, sampleRate: number): void {
    this.clipMaxSamples = Math.floor((sampleRate * 3000) / 1000)
    this.clipBuffer = [...this.clipBuffer, ...samples]
    if (this.clipBuffer.length > this.clipMaxSamples) {
      this.clipBuffer = this.clipBuffer.slice(this.clipBuffer.length - this.clipMaxSamples)
    }
  }

  private async evaluateWithClassifier(sampleRate: number): Promise<void> {
    const now = Date.now()
    if (this.classificationInFlight || now - this.lastAlertEpochMs < this.cooldownMs) {
      return
    }

    this.classificationInFlight = true
    this.snapshot.pendingAi = true
    this.snapshot.lastDecision = 'Temporal pattern matched. Running local AI classification.'
    this.emitSnapshot()

    try {
      const clip = this.getClip(sampleRate)
      const firstResult = await this.classifier.classify(clip)
      await this.handleClassificationResult(firstResult, sampleRate, false)
    } catch (error) {
      console.error('AlertManager classifier error: ' + JSON.stringify(error as any))
      this.snapshot.lastDecision = 'AI classification failed for this cycle'
    } finally {
      this.snapshot.pendingAi = false
      this.classificationInFlight = false
      this.emitSnapshot()
    }
  }

  private async handleClassificationResult(
    result: FireClassificationResult,
    sampleRate: number,
    isRetry: boolean
  ): Promise<void> {
    this.snapshot.aiConfidence = result.confidence

    if (result.confidence > 0.85) {
      await this.triggerConfirmedAlert(result.confidence, 'frequency+pattern+ai')
      this.snapshot.lastDecision = 'Fire alarm confirmed (' + result.model + ')'
      return
    }

    if (result.confidence >= 0.6 && result.confidence <= 0.85 && !isRetry) {
      this.snapshot.lastDecision = 'AI confidence uncertain. Retrying with new 3s clip.'
      this.emitSnapshot()
      await this.delay(700)
      const retryClip = this.getClip(sampleRate)
      const retryResult = await this.classifier.classify(retryClip)
      await this.handleClassificationResult(retryResult, sampleRate, true)
      return
    }

    this.snapshot.lastDecision = 'Pattern rejected by AI (' + result.confidence.toFixed(2) + ')'
  }

  private async triggerConfirmedAlert(confidence: number, method: string): Promise<void> {
    this.lastAlertEpochMs = Date.now()

    this.vibrationService.triggerFireAlarm()
    await this.deviceCommService.sendFireAlert(confidence)
    const saved: FireAlertRecord = await AlertStorageService.saveAlert(confidence, method)

    this.onAlert({
      timestamp: saved.timestamp,
      confidence,
      method
    })
  }

  private getClip(sampleRate: number): FireAudioClip {
    return {
      samples: [...this.clipBuffer],
      sampleRate,
      durationMs: Math.floor((this.clipBuffer.length * 1000) / sampleRate)
    }
  }

  private emitSnapshot(): void {
    this.onSnapshot(this.getSnapshot())
  }

  private delay(ms: number): Promise<void> {
    return new Promise((resolve: () => void) => {
      setTimeout(() => resolve(), ms)
    })
  }
}
