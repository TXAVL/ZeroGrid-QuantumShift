// Web Audio API sci-fi sound effects synthesis (Zero dependencies)
class CyberSoundService {
  constructor() {
    this.ctx = null;
    this.muted = localStorage.getItem('txa_audio_muted') === 'true';
  }

  init() {
    if (!this.ctx && typeof window !== 'undefined') {
      const AudioContext = window.AudioContext || window.webkitAudioContext;
      if (AudioContext) {
        this.ctx = new AudioContext();
      }
    }
  }

  isMuted() {
    return this.muted;
  }

  toggleMute() {
    this.muted = !this.muted;
    localStorage.setItem('txa_audio_muted', this.muted ? 'true' : 'false');
    if (!this.muted) {
      this.playBeep(880, 0.08, 'sine');
    }
    return this.muted;
  }

  playHover() {
    if (this.muted) return;
    this.playTone(520, 0.03, 'sine', 0.05);
  }

  playClick() {
    if (this.muted) return;
    this.playTone(800, 0.05, 'triangle', 0.08);
  }

  playSuccess() {
    if (this.muted) return;
    this.init();
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    [523.25, 659.25, 783.99, 1046.50].forEach((freq, i) => {
      const osc = this.ctx.createOscillator();
      const gain = this.ctx.createGain();
      osc.type = 'sine';
      osc.frequency.setValueAtTime(freq, now + i * 0.06);
      gain.gain.setValueAtTime(0.08, now + i * 0.06);
      gain.gain.exponentialRampToValueAtTime(0.001, now + i * 0.06 + 0.12);
      osc.connect(gain);
      gain.connect(this.ctx.destination);
      osc.start(now + i * 0.06);
      osc.stop(now + i * 0.06 + 0.12);
    });
  }

  playTone(frequency, duration, type = 'sine', volume = 0.08) {
    try {
      this.init();
      if (!this.ctx) return;
      if (this.ctx.state === 'suspended') {
        this.ctx.resume();
      }
      const osc = this.ctx.createOscillator();
      const gain = this.ctx.createGain();
      osc.type = type;
      osc.frequency.setValueAtTime(frequency, this.ctx.currentTime);
      gain.gain.setValueAtTime(volume, this.ctx.currentTime);
      gain.gain.exponentialRampToValueAtTime(0.001, this.ctx.currentTime + duration);
      osc.connect(gain);
      gain.connect(this.ctx.destination);
      osc.start();
      osc.stop(this.ctx.currentTime + duration);
    } catch (e) {
      // Audio context may be restricted by browser policy before first user gesture
    }
  }

  playBeep(freq = 600, duration = 0.06, type = 'sine') {
    this.playTone(freq, duration, type, 0.08);
  }
}

export const sound = new CyberSoundService();
