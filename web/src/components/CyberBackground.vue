<template>
  <div class="fixed inset-0 pointer-events-none z-0 overflow-hidden">
    <!-- Matrix/Cyber Canvas -->
    <canvas ref="canvasRef" class="w-full h-full opacity-60"></canvas>

    <!-- Radial glowing ambient lights -->
    <div class="absolute -top-40 -left-40 w-96 h-96 bg-cyan-500/10 rounded-full blur-3xl pointer-events-none"></div>
    <div class="absolute top-1/3 -right-40 w-[500px] h-[500px] bg-pink-500/10 rounded-full blur-3xl pointer-events-none"></div>
    <div class="absolute -bottom-40 left-1/3 w-[600px] h-[600px] bg-purple-600/10 rounded-full blur-3xl pointer-events-none"></div>

    <!-- Cyber Scanlines -->
    <div class="absolute inset-0 cyber-scanlines opacity-40 pointer-events-none"></div>
  </div>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount } from 'vue';

const canvasRef = ref(null);
let animationFrameId = null;
let particles = [];
let mouse = { x: null, y: null, radius: 150 };

class Particle {
  constructor(w, h) {
    this.reset(w, h);
  }

  reset(w, h) {
    this.x = Math.random() * w;
    this.y = Math.random() * h;
    this.size = Math.random() * 2 + 0.8;
    this.baseX = this.x;
    this.baseY = this.y;
    this.speedX = (Math.random() - 0.5) * 0.4;
    this.speedY = (Math.random() - 0.5) * 0.4;
    this.color = Math.random() > 0.4 ? '#00f0ff' : (Math.random() > 0.5 ? '#ff007f' : '#00ffa3');
    this.alpha = Math.random() * 0.6 + 0.2;
  }

  update(w, h) {
    this.x += this.speedX;
    this.y += this.speedY;

    if (this.x < 0 || this.x > w) this.speedX *= -1;
    if (this.y < 0 || this.y > h) this.speedY *= -1;

    // Mouse interaction
    if (mouse.x !== null && mouse.y !== null) {
      const dx = mouse.x - this.x;
      const dy = mouse.y - this.y;
      const distance = Math.sqrt(dx * dx + dy * dy);
      if (distance < mouse.radius) {
        const force = (mouse.radius - distance) / mouse.radius;
        this.x -= (dx / distance) * force * 3;
        this.y -= (dy / distance) * force * 3;
      }
    }
  }

  draw(ctx) {
    ctx.save();
    ctx.globalAlpha = this.alpha;
    ctx.fillStyle = this.color;
    ctx.shadowBlur = 8;
    ctx.shadowColor = this.color;
    ctx.beginPath();
    ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
    ctx.fill();
    ctx.restore();
  }
}

onMounted(() => {
  const canvas = canvasRef.value;
  if (!canvas) return;
  const ctx = canvas.getContext('2d');

  const resize = () => {
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
    initParticles(canvas.width, canvas.height);
  };

  const initParticles = (w, h) => {
    particles = [];
    const count = Math.floor((w * h) / 12000);
    for (let i = 0; i < Math.min(count, 120); i++) {
      particles.push(new Particle(w, h));
    }
  };

  const handleMouseMove = (e) => {
    mouse.x = e.clientX;
    mouse.y = e.clientY;
  };

  const handleMouseLeave = () => {
    mouse.x = null;
    mouse.y = null;
  };

  window.addEventListener('resize', resize);
  window.addEventListener('mousemove', handleMouseMove);
  window.addEventListener('mouseleave', handleMouseLeave);

  resize();

  // Grid animation offset
  let gridOffset = 0;

  const animate = () => {
    ctx.clearRect(0, 0, canvas.width, canvas.height);

    // Draw Subtle Cyber Perspective Grid
    ctx.save();
    ctx.strokeStyle = 'rgba(0, 240, 255, 0.04)';
    ctx.lineWidth = 1;

    const gridSize = 48;
    gridOffset = (gridOffset + 0.2) % gridSize;

    // Vertical lines
    for (let x = 0; x < canvas.width; x += gridSize) {
      ctx.beginPath();
      ctx.moveTo(x, 0);
      ctx.lineTo(x, canvas.height);
      ctx.stroke();
    }

    // Horizontal lines
    for (let y = gridOffset; y < canvas.height; y += gridSize) {
      ctx.beginPath();
      ctx.moveTo(0, y);
      ctx.lineTo(canvas.width, y);
      ctx.stroke();
    }
    ctx.restore();

    // Draw connection lines between near particles
    for (let i = 0; i < particles.length; i++) {
      particles[i].update(canvas.width, canvas.height);
      particles[i].draw(ctx);

      for (let j = i + 1; j < particles.length; j++) {
        const dx = particles[i].x - particles[j].x;
        const dy = particles[i].y - particles[j].y;
        const dist = Math.sqrt(dx * dx + dy * dy);
        if (dist < 100) {
          ctx.save();
          ctx.globalAlpha = (1 - dist / 100) * 0.15;
          ctx.strokeStyle = '#00f0ff';
          ctx.lineWidth = 0.5;
          ctx.beginPath();
          ctx.moveTo(particles[i].x, particles[i].y);
          ctx.lineTo(particles[j].x, particles[j].y);
          ctx.stroke();
          ctx.restore();
        }
      }
    }

    animationFrameId = requestAnimationFrame(animate);
  };

  animate();

  onBeforeUnmount(() => {
    cancelAnimationFrame(animationFrameId);
    window.removeEventListener('resize', resize);
    window.removeEventListener('mousemove', handleMouseMove);
    window.removeEventListener('mouseleave', handleMouseLeave);
  });
});
</script>
