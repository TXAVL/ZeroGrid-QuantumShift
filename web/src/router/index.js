import { createRouter, createWebHistory } from 'vue-router';
import HomeView from '../views/HomeView.vue';
import PrivacyView from '../views/PrivacyView.vue';
import DeleteAccountView from '../views/DeleteAccountView.vue';
import TermsView from '../views/TermsView.vue';
import LoginView from '../views/LoginView.vue';
import RegisterView from '../views/RegisterView.vue';
import OAuthAuthorizeView from '../views/OAuthAuthorizeView.vue';
import DocsView from '../views/DocsView.vue';
import AdminView from '../views/AdminView.vue';

const routes = [
  {
    path: '/',
    name: 'home',
    component: HomeView,
  },
  {
    path: '/login',
    name: 'login',
    component: LoginView,
  },
  {
    path: '/register',
    name: 'register',
    component: RegisterView,
  },
  {
    path: '/oauth/authorize',
    name: 'oauth-authorize',
    component: OAuthAuthorizeView,
  },
  {
    path: '/docs',
    name: 'docs',
    component: DocsView,
  },
  {
    path: '/admin',
    name: 'admin',
    component: AdminView,
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
