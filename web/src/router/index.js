import { createRouter, createWebHistory } from 'vue-router';
import HomeView from '../views/HomeView.vue';
import PrivacyView from '../views/PrivacyView.vue';
import DeleteAccountView from '../views/DeleteAccountView.vue';
import TermsView from '../views/TermsView.vue';

const routes = [
  {
    path: '/',
    name: 'home',
    component: HomeView,
  },
  {
    path: '/privacy/:gameSlug?',
    name: 'privacy',
    component: PrivacyView,
  },
  {
    path: '/delete-account/:gameSlug?',
    name: 'delete-account',
    component: DeleteAccountView,
  },
  {
    path: '/delete/:gameSlug?',
    redirect: to => {
      const slug = to.params.gameSlug || '';
      return slug ? `/delete-account/${slug}` : '/delete-account';
    },
  },
  {
    path: '/terms/:gameSlug?',
    name: 'terms',
    component: TermsView,
  },
  {
    path: '/support',
    redirect: '/privacy',
  },
  {
    path: '/:pathMatch(.*)*',
    redirect: '/',
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior(to, from, savedPosition) {
    if (savedPosition) {
      return savedPosition;
    }
    if (to.hash) {
      return { el: to.hash, behavior: 'smooth' };
    }
    return { top: 0, behavior: 'smooth' };
  },
});

export default router;
