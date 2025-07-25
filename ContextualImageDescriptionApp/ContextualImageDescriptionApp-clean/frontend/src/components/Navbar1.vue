<template>
  <header id="header" class="header d-flex align-items-center sticky-top">
    <div class="container-fluid position-relative d-flex align-items-center justify-content-between">
      <router-link to="#" class="logo d-flex align-items-center me-auto me-xl-0">
        <h1 class="sitename">IntelliDoc</h1><span>.</span>
      </router-link>
      <nav id="navmenu" class="navmenu">
        <ul>
          <li><router-link to="/" :class="{ active: $route.path === '/' }">Home</router-link></li>
          <li><router-link to="/login" :class="{ active: $route.path === '/login' }">Login</router-link></li>
          <li><router-link to="/signup" :class="{ active: $route.path === '/signup' }">Sign Up</router-link></li>
        </ul>
        <i class="mobile-nav-toggle d-xl-none bi bi-list"></i>
      </nav>
      <router-link class="btn-getstarted" to="/about">About us</router-link>
    </div>
  </header>
</template>

<script>
export default {
  name: 'Navbar1'
};
</script>

<style scoped>
.header {
  background-color: #F8FAFC; 
}
.logo h1 {
  color: #2D3748; 
}
.navmenu a {
  color: #2D3748; 
  transition: color 0.3s ease;
}
.navmenu a:hover,
.navmenu a.active {
  color: #0ea2bd; 
}
.btn-getstarted {
  background-color: #0ea2bd;
  border-color: #0ea2bd;
  color: #fff;
  border-radius: 50px;
  padding: 0.5rem 1.5rem;
  transition: background-color 0.3s ease, transform 0.2s ease;
}
.btn-getstarted:hover {
  background-color: #71d1e2; 
  border-color: #71d1e2;
  transform: scale(1.05);
}
.mobile-nav-toggle {
  color: #2D3748; 
}
</style>