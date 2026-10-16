// Dynamic Chart.js Loader with zero build dependencies
let chartLoaderPromise = null;

export async function loadChartJs() {
  if (typeof window !== 'undefined' && window.Chart) {
    return window.Chart;
  }
  if (chartLoaderPromise) return chartLoaderPromise;

  chartLoaderPromise = new Promise((resolve, reject) => {
    if (typeof window === 'undefined') return reject(new Error('Window not available'));
    if (window.Chart) return resolve(window.Chart);

    const existing = document.querySelector('script[data-chartjs-cdn]');
    if (existing) {
      existing.addEventListener('load', () => resolve(window.Chart));
      existing.addEventListener('error', (e) => reject(e));
      return;
    }

    const script = document.createElement('script');
    script.src = 'https://cdn.jsdelivr.net/npm/chart.js@4.4.8/dist/chart.umd.min.js';
    script.setAttribute('data-chartjs-cdn', 'true');
    script.async = true;
    script.onload = () => {
      if (window.Chart) {
        resolve(window.Chart);
      } else {
        reject(new Error('Chart.js loaded but window.Chart is missing'));
      }
    };
    script.onerror = (err) => reject(new Error('Failed to load Chart.js CDN script: ' + err));
    document.head.appendChild(script);
  });

  return chartLoaderPromise;
}
