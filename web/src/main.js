import { createApp } from 'vue';
import { inject } from '@vercel/analytics';
import App from './App.vue';
import router from './router';
import './style.css';

// Initialize Vercel Analytics (auto detects dev vs prod)
inject();

const app = createApp(App);
app.use(router);
app.mount('#app');

