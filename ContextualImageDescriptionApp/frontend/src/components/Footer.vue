<template>
  <div>
    <footer id="footer" class="footer dark-background">
      <div class="footer-top">
        <div class="container">
          <div class="row gy-4">
            <div class="col-lg-4 col-md-6 footer-about">
              <router-link to="/" class="logo d-flex align-items-center">
                <span class="sitename">IntelliDoc</span>
              </router-link>
              <div class="footer-contact pt-3">
  <p><i class="bi bi-geo-alt"></i> Tunis, Tunisia</p>
  <p><i class="bi bi-telephone"></i> +216 12345678</p>
  <p class="mt-3"><strong>Email:</strong> <span><i class="bi bi-envelope"></i> support@intellidoc.com</span></p>
</div>
            </div>
            <div class="col-lg-2 col-md-3 footer-links">
  <h4>Connect With Us</h4>
  <ul>
    <li><router-link to="/"><i class="bi bi-instagram"></i> Instagram</router-link></li>
    <li><router-link to="/"><i class="bi bi-facebook"></i> Facebook</router-link></li>
    <li><router-link to="/"><i class="bi bi-twitter"></i> Twitter</router-link></li>
    <li><router-link to="/"><i class="bi bi-linkedin"></i> LinkedIn</router-link></li>
  </ul>
</div>
            <div class="col-lg-2 col-md-3 footer-links">
              <h4>Our Services</h4>
              <ul>
                <li><a href="#">Document Upload</a></li>
                <li><a href="#">AI Analysis</a></li>
                <li><a href="#">User Management</a></li>
              </ul>
            </div>
          </div>
        </div>
      </div>
      <div class="copyright text-center">
        <div class="container d-flex flex-column flex-lg-row justify-content-center justify-content-lg-between align-items-center">
          <div class="d-flex flex-column align-items-center align-items-lg-start">
            <div>
              © Copyright <strong><span>IntelliDoc</span></strong>. All Rights Reserved
            </div>
          </div>
        </div>
      </div>
    </footer>
    <!-- Scroll Top -->
    <a href="#" id="scroll-top" class="scroll-top d-flex align-items-center justify-content-center"><i class="bi bi-arrow-up-short"></i></a>
  </div>
</template>

<script>
export default {
  name: 'Footer'
};
</script>

<style scoped>
.footer {
  background-color: #2D3748; 
  color: #F8FAFC; 
}
.footer a {
  color: #F8FAFC;
  transition: color 0.3s ease;
}
.footer a:hover {
  color: #71d1e2; 
}
.scroll-top {
  background-color: #0ea2bd;
}
.scroll-top:hover {
  background-color: #71d1e2;
}
</style>