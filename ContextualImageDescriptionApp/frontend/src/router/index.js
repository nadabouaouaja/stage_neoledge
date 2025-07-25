import { createRouter, createWebHistory } from 'vue-router'
import Documents from '../views/DocumentsView.vue';
import AddDocument from '../views/AddDocumentView.vue';
import Details from '../views/DetailsView.vue';
import Home from '../views/HomeView.vue';
import Login from '../views/LoginView.vue';
import Signup from '../views/SignupView.vue';
import AboutUs from '../views/AboutUsView.vue';
import UpdateDocument from '../views/UpdateDocumentView.vue';
import Profile from '../views/ProfileView.vue';

const routes = [
  { path: '/', name: 'Home', component: Home },
  { path: '/login', name: 'Login', component: Login },
  { path: '/about', name: 'AboutUs', component: AboutUs },
  { path: '/signup', name: 'Signup', component: Signup },
  { path: '/documents', name: 'Documents', component: Documents, meta: { requiresAuth: true } },
  { path: '/add-document', name: 'AddDocument', component: AddDocument, meta: { requiresAuth: true } },
  { path: '/details/:id', name: 'Details', component: Details, meta: { requiresAuth: true } },
  { path: '/update/:id', name: 'UpdateDocument', component: UpdateDocument, meta: { requiresAuth: true } },
  { path: '/profile', name: 'Profile', component: Profile, meta: { requiresAuth: true } }
];

const router = createRouter({
  history: createWebHistory(process.env.BASE_URL),
  routes,
  scrollBehavior(to, from, savedPosition) {
    return { top: 0 }
  }
})

router.beforeEach((to, from, next) => {
  const isAuthenticated = !!localStorage.getItem('token');
  if (to.meta.requiresAuth && !isAuthenticated) {
    next('/login');
  } else {
    next();
  }
});

export default router
