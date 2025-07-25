<template>
  <div class="index-page">
    <Navbar1 />
    <main class="main">
      <!-- Hero Section -->
      <section id="hero" class="hero section" style="padding: 0%;">
        <div class="container d-flex flex-column justify-content-center align-items-center text-center position-relative" data-aos="zoom-out">
          <img src="/assets/img/custom/home3.jpeg" class="img-fluid animated" style="width: 100%; height: 500px;" alt="IntelliDoc Platform">
          <h1>Welcome to <span>IntelliDoc</span></h1>
          <p>Transform your documents with AI-powered contextual image description and management</p>
          
        </div>
      </section>

      <!-- Featured Services Section -->
      <section id="features" class="featured-services section">
        <div class="container">
          <div class="section-title" data-aos="fade-up">
            <h2>Our Features</h2>
            <p>Discover the power of IntelliDoc for seamless document management</p>
          </div>
          <div class="row gy-4">
            <div class="col-xl-4 col-md-6 d-flex" data-aos="fade-up" data-aos-delay="100">
              <div class="service-item position-relative">
                <div class="icon"><i class="bi bi-upload icon"></i></div>
                <h4><router-link to="/signup" class="stretched-link">Document Upload</router-link></h4>
                <p>Easily upload your documents for instant AI-powered analysis and organization</p>
              </div>
            </div>
            <div class="col-xl-4 col-md-6 d-flex" data-aos="fade-up" data-aos-delay="200">
              <div class="service-item position-relative">
                <div class="icon"><i class="bi bi-gear icon"></i></div>
                <h4><router-link to="/signup" class="stretched-link">AI Analysis</router-link></h4>
                <p>Leverage advanced AI to extract insights and context from images and documents</p>
              </div>
            </div>
            <div class="col-xl-4 col-md-6 d-flex" data-aos="fade-up" data-aos-delay="300">
              <div class="service-item position-relative">
                <div class="icon"><i class="bi bi-person icon"></i></div>
                <h4><router-link to="/signup" class="stretched-link">User Management</router-link></h4>
                <p>Manage your profile and documents with a secure, user-friendly dashboard</p>
              </div>
            </div>
          </div>
        </div>
      </section>
    </main>
    <Footer />
  </div>
</template>

<script>
import Navbar1 from '../components/Navbar1.vue';
import Footer from '../components/Footer.vue';

export default {
  name: 'Home',
  components: {
    Navbar1,
    Footer
  }
};
</script>

<style scoped>
.hero h1 span {
  color: #0dcaf0; 
}
.service-item {
  transition: transform 0.3s ease;
  background-color: #F8FAFC; 
  padding: 1.5rem;
  border-radius: 10px;
  box-shadow: 0 0 15px rgba(0, 0, 0, 0.1);
}
.service-item:hover {
  transform: translateY(-10px);
}
.service-item .icon {
  color: #0ea2bd;
}
.service-item h4 a {
  color: #2D3748; 
}
.service-item h4 a:hover {
  color: #71d1e2; 
}
.btn-get-started {
  background-color: #0ea2bd;
  border-color: #0ea2bd;
  color: #fff;
}
.btn-get-started:hover {
  background-color: #71d1e2; 
  border-color: #71d1e2;
}
.btn-watch-video {
  color: #2D3748; 
}
.btn-watch-video:hover {
  color: #71d1e2;
}
</style>