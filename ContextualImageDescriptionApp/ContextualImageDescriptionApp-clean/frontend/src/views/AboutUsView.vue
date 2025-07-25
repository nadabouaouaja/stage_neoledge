<template>
  <div>
    <Navbar1 />
    <main class="main">
      <!-- About Section -->
      <section id="about" class="about section" style="padding-top: 50px;">
        <!-- General Info -->
        <div class="container section-title" data-aos="fade-up">
          <h2>About IntelliDoc</h2>
          <p>Empowering smarter document management with AI</p>
        </div>
        <div class="container" data-aos="fade-up" data-aos-delay="100">
          <div class="row gy-3 align-items-center">
            <div class="col-lg-4">
              <div class="content" data-aos="fade-right" data-aos-delay="200" style="padding: 1rem;">
                <h3>Our Mission</h3>
                <p>
                  At IntelliDoc, we aim to revolutionize document management by leveraging artificial intelligence to streamline workflows, enhance accuracy, and unlock actionable insights for businesses and individuals.
                </p>
              </div>
            </div>
            <div class="col-lg-4 text-center">
              <img src="/assets/img/custom/home2.jpeg" class="img-fluid" alt="IntelliDoc Team" data-aos="fade-up" data-aos-delay="200" style="max-width: 80%; border-radius: 1rem;">
            </div>
            <div class="col-lg-4">
              <div class="content" data-aos="fade-left" data-aos-delay="200" style="padding: 1rem;">
                <h3>Our Vision</h3>
                <p>
                  To create a world where managing documents is effortless, secure, and intelligent, empowering users to focus on what truly matters.
                </p>
              </div>
            </div>
          </div>
        </div>

        <br> <br>
        <!-- Team Section -->
        <div class="container section-title" data-aos="fade-up" style="margin-bottom: 1rem; padding: 0;">
          <h2>Our Team</h2>
          <p>Meet the innovators behind IntelliDoc</p>
        </div>
        <br> <br>
        <div class="container" data-aos="fade-up" data-aos-delay="100">
          <div class="row justify-content-center gy-3">
            <div class="col-lg-4 col-md-6 d-flex justify-content-center" data-aos="fade-up" data-aos-delay="200">
              <div class="team-member text-center" style="padding: 1rem;">
                <img src="/assets/img/custom/leila.jpg" class="img-fluid rounded-rectangle" alt="Team Member" style="max-width: 80%;">
                <br><br>
                <h4>Leila Ben Abdallah</h4>
                <p>CEO & Co-Founder</p>
                <p>Driving IntelliDoc's vision with 10+ years in AI and tech innovation.</p>
                <div class="social-links">
                  <a href="#" class="mx-1"><i class="bi bi-linkedin"></i></a>
                  <a href="#" class="mx-1"><i class="bi bi-twitter"></i></a>
                </div>
              </div>
            </div>
            <div class="col-lg-4 col-md-6 d-flex justify-content-center" data-aos="fade-up" data-aos-delay="300">
              <div class="team-member text-center" style="padding: 1rem;">
                <img src="/assets/img/custom/nada.jpeg" class="img-fluid rounded-rectangle" alt="Team Member" style="max-width: 80%;">
                
                <h4>Nada Bouaouaja</h4>
                <p>CEO & Co-Founder</p>
                <p style="font-size: 0.85rem;">Leading technical development with expertise in AI and cloud solutions.</p>
                <div class="social-links">
                  <a href="#" class="mx-1"><i class="bi bi-linkedin"></i></a>
                  <a href="#" class="mx-1"><i class="bi bi-github"></i></a>
                </div>
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
import Footer from '../components/Footer.vue';
import Navbar1 from '../components/Navbar1.vue';

export default {
  name: 'AboutUs',
  components: {
    Footer,
    Navbar1
  }
};
</script>

<style scoped>
.team-member {
  background: #f7f7f9;
  border-radius: 1.5rem;
  padding: 2rem 1rem 1.5rem 1rem;
  box-shadow: 0 4px 16px rgba(0,0,0,0.07);
  transition: box-shadow 0.2s;
}
.team-member:hover {
  box-shadow: 0 8px 24px rgba(0,0,0,0.12);
}

</style>