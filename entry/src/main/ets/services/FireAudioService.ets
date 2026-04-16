export interface AudioFrame {
  samples: Array<number>
  sampleRate: number
  capturedAtMs: number
}

export type AudioFrameListener = (frame: AudioFrame) => void

export interface AudioSourceAdapter {
  start(sampleRate: number): Promise<void>
  stop(): Promise<void>
  pullFrame(frameSize: number): Promise<Array<number>>
}

interface RuntimeCapturer {
  start(sampleRate: number): Promise<void>
  stop(): Promise<void>
  read(frameSize: number): Promise<Array<number>>
}

declare const SafePulseAudioCapturer: RuntimeCapturer | undefined

class HarmonyMicrophoneAdapter implements AudioSourceAdapter {
  private capturer: RuntimeCapturer | null = null

  async start(sampleRate: number): Promise<void> {
    const runtime = SafePulseAudioCapturer
    if (!runtime) {
      throw new Error('SafePulseAudioCapturer runtime is not available')
    }

    this.capturer = runtime
    await this.capturer.start(sampleRate)
  }

  async stop(): Promise<void> {
    if (this.capturer !== null) {
      await this.capturer.stop()
    }
  }

  async pullFrame(frameSize: number): Promise<Array<number>> {
    if (this.capturer === null) {
      return []
    }
    return this.capturer.read(frameSize)
  }
}

class SimulatedMicrophoneAdapter implements AudioSourceAdapter {
  private phase: number = 0
  private readonly toneFrequencyHz: number = 3980
  private readonly toneDutyCycleMs: number = 240
  private readonly toneSpacingMs: number = 360
  private readonly groupPauseMs: number = 1500

  async start(_sampleRate: number): Promise<void> {
    return
  }

  async stop(): Promise<void> {
    return
  }

  async pullFrame(frameSize: number): Promise<Array<number>> {
    const frame: Array<number> = []
    const sampleRate = 16000
    const groupWindowMs = (this.toneDutyCycleMs * 3) + (this.toneSpacingMs * 2) + this.groupPauseMs
    const nowMs = Date.now()
    const inGroupMs = nowMs % groupWindowMs
    const inTone = inGroupMs < this.toneDutyCycleMs ||
      (inGroupMs > this.toneDutyCycleMs + this.toneSpacingMs && inGroupMs < (this.toneDutyCycleMs * 2) + this.toneSpacingMs) ||
      (inGroupMs > (this.toneDutyCycleMs * 2) + (this.toneSpacingMs * 2) && inGroupMs < (this.toneDutyCycleMs * 3) + (this.toneSpacingMs * 2))

    for (let i = 0; i < frameSize; i += 1) {
      const tone = inTone
        ? Math.sin((2 * Math.PI * this.toneFrequencyHz * this.phase) / sampleRate) * 0.75
        : 0
      const noise = (Math.random() - 0.5) * 0.06
      frame.push(tone + noise)
      this.phase += 1
    }
    return frame
  }
}

export class FireAudioService {
  private readonly sampleRate: number
  private readonly frameWindowMs: number
  private readonly processEveryMs: number
  private source: AudioSourceAdapter
  private listeners: Array<AudioFrameListener> = []
  private isRunning: boolean = false
  private isProcessing: boolean = false
  private timerId: number = -1

  constructor(
    source?: AudioSourceAdapter,
    sampleRate: number = 16000,
    frameWindowMs: number = 200,
    processEveryMs: number = 500
  ) {
    this.source = source ? source : this.createDefaultSource()
    this.sampleRate = sampleRate
    this.frameWindowMs = frameWindowMs
    this.processEveryMs = processEveryMs
  }

  onFrame(listener: AudioFrameListener): () => void {
    this.listeners.push(listener)
    return () => {
      this.listeners = this.listeners.filter((item: AudioFrameListener) => item !== listener)
    }
  }

  async start(): Promise<void> {
    if (this.isRunning) {
      return
    }

    try {
      await this.source.start(this.sampleRate)
    } catch (error) {
      console.warn(
        'Realtime microphone unavailable, using simulated adapter: ' + JSON.stringify(error as Object)
      )
      this.source = new SimulatedMicrophoneAdapter()
      await this.source.start(this.sampleRate)
    }
    this.isRunning = true
    this.timerId = setInterval(() => {
      this.processTick()
    }, this.processEveryMs)
  }

  async stop(): Promise<void> {
    if (!this.isRunning) {
      return
    }

    this.isRunning = false
    if (this.timerId !== -1) {
      clearInterval(this.timerId)
      this.timerId = -1
    }
    await this.source.stop()
  }

  getIsRunning(): boolean {
    return this.isRunning
  }

  private async processTick(): Promise<void> {
    if (!this.isRunning || this.isProcessing) {
      return
    }

    this.isProcessing = true
    try {
      const frameSize = Math.floor((this.sampleRate * this.frameWindowMs) / 1000)
      const samples = await this.source.pullFrame(frameSize)
      const frame: AudioFrame = {
        samples,
        sampleRate: this.sampleRate,
        capturedAtMs: Date.now()
      }

      this.listeners.forEach((listener: AudioFrameListener) => {
        listener(frame)
      })
    } catch (error) {
      console.error('FireAudioService processTick error: ' + JSON.stringify(error as Object))
    } finally {
      this.isProcessing = false
    }
  }

  private createDefaultSource(): AudioSourceAdapter {
    return new HarmonyMicrophoneAdapter()
  }
}
