import webSocket from '@ohos.net.webSocket'
import { NetworkService, SyncState } from './NetworkService'

type SyncListener = (state: SyncState, reason: string) => void

export class AlertSyncService {
  private static instance: AlertSyncService = new AlertSyncService()

  private socket: webSocket.WebSocket | null = null
  private listeners: SyncListener[] = []
  private reconnectDelayMs: number = 1000
  private reconnectTimer: number = -1
  private latestRevision: number = -1
  private isConnecting: boolean = false
  private started: boolean = false

  static getInstance(): AlertSyncService {
    return AlertSyncService.instance
  }

  subscribe(listener: SyncListener): void {
    if (this.listeners.indexOf(listener) === -1) {
      this.listeners.push(listener)
    }
  }

  unsubscribe(listener: SyncListener): void {
    this.listeners = this.listeners.filter((item: SyncListener) => item !== listener)
  }

  start(): void {
    this.started = true
    this.connect()
  }

  stop(): void {
    this.started = false
    this.clearReconnectTimer()
    if (this.socket !== null) {
      try {
        this.socket.close()
      } catch (error) {
        console.error('AlertSyncService close error: ' + JSON.stringify(error))
      }
    }
    this.socket = null
    this.isConnecting = false
  }

  async forceRefresh(reason: string = 'manual-refresh'): Promise<void> {
    const state = await NetworkService.fetchSyncState()
    if (state === null) {
      return
    }
    this.publishState(state, reason)
  }

  private connect(): void {
    if (!this.started || this.isConnecting || this.socket !== null) {
      return
    }

    this.isConnecting = true
    this.clearReconnectTimer()
    this.socket = webSocket.createWebSocket()
    this.bindSocket(this.socket)
    this.socket.connect(NetworkService.WS_URL, (err, _value) => {
      this.isConnecting = false
      if (err) {
        console.error('AlertSyncService connect failed: ' + JSON.stringify(err))
        this.scheduleReconnect()
      }
    })
  }

  private bindSocket(socket: webSocket.WebSocket): void {
    socket.on('open', (_err, _value) => {
      this.reconnectDelayMs = 1000
      this.forceRefresh('socket-open')
    })

    socket.on('message', (_err, value: string) => {
      try {
        const payload = JSON.parse(String(value)) as Record<string, Object>
        const state = payload['state'] as SyncState
        const reason = String(payload['reason'] || 'socket-message')
        if (state) {
          this.publishState(state, reason)
        }
      } catch (error) {
        console.error('AlertSyncService message parse error: ' + JSON.stringify(error))
      }
    })

    socket.on('close', (_err, value: Record<string, Object>) => {
      console.error('AlertSyncService socket closed: ' + JSON.stringify(value))
      this.socket = null
      this.isConnecting = false
      this.scheduleReconnect()
    })

    socket.on('error', (err) => {
      console.error('AlertSyncService socket error: ' + JSON.stringify(err))
    })
  }

  private publishState(state: SyncState, reason: string): void {
    if (state.stateRevision <= this.latestRevision) {
      return
    }

    this.latestRevision = state.stateRevision
    this.listeners.forEach((listener: SyncListener) => {
      listener(state, reason)
    })
  }

  private scheduleReconnect(): void {
    if (!this.started || this.reconnectTimer !== -1) {
      return
    }

    this.reconnectTimer = setTimeout(() => {
      this.reconnectTimer = -1
      this.connect()
    }, this.reconnectDelayMs) as number

    if (this.reconnectDelayMs < 10000) {
      this.reconnectDelayMs = this.reconnectDelayMs * 2
    }
  }

  private clearReconnectTimer(): void {
    if (this.reconnectTimer !== -1) {
      clearTimeout(this.reconnectTimer)
      this.reconnectTimer = -1
    }
  }
}
