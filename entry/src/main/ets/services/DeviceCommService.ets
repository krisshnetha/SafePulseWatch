export interface FireAlertPayload {
  type: string
  timestamp: string
  confidence: number
}

interface DistributedAlertSender {
  send(payload: FireAlertPayload): Promise<boolean>
}

class HarmonyDistributedSender implements DistributedAlertSender {
  async send(payload: FireAlertPayload): Promise<boolean> {
    try {
      // In production this should call HarmonyOS distributed communication APIs.
      const bus = (globalThis as Record<string, Object>)['SafePulseDistributedBus'] as Record<string, (message: string) => void> | undefined
      if (bus && bus['publish']) {
        bus['publish'](JSON.stringify(payload))
        return true
      }

      console.info('Distributed send fallback payload: ' + JSON.stringify(payload))
      return true
    } catch (error: Object) {
      console.error('DeviceCommService send failed: ' + JSON.stringify(error))
      return false
    }
  }
}

export class DeviceCommService {
  private readonly sender: DistributedAlertSender

  constructor(sender?: DistributedAlertSender) {
    this.sender = sender ? sender : new HarmonyDistributedSender()
  }

  async sendFireAlert(confidence: number): Promise<boolean> {
    const payload: FireAlertPayload = {
      type: 'FIRE_ALERT',
      timestamp: new Date().toISOString(),
      confidence
    }
    return this.sender.send(payload)
  }
}
