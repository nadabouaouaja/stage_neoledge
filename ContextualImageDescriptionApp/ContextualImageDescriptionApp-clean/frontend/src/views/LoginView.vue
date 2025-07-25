<template>
  <div>
    <Navbar1 />
    <main class="main">
      <!-- Login Section -->
      <section id="login" class="contact section" style="padding-top: 0%;">
        <div class="container section-title" data-aos="fade-up">
          <h2>Log In to Your Account</h2>
          <p>Access IntelliDoc to manage and analyze your documents with AI-powered insights</p>
        </div>
        <div class="container" data-aos="fade-up" data-aos-delay="100">
          <div class="row gy-4 align-items-center">
            <div class="col-lg-6">
              <img src="/assets/img/custom/signup2.jpeg" class="login-image img-fluid" alt="IntelliDoc AI Document Management" data-aos="fade-right" data-aos-delay="200" style="max-width: 80%;">
            </div>
            <div class="col-lg-6">
              <form @submit.prevent="submitForm" class="login-form" :class="{ 'was-validated': formSubmitted }" >
                <div class="form-group mt-3">
                  <input type="text" class="form-control" v-model="form.email" placeholder="Your Email" required>
                  <div class="invalid-feedback" v-if="formSubmitted && !form.email">Please enter a valid email address.</div>
                </div>
                <div class="form-group mt-3">
                  <input type="password" class="form-control" v-model="form.password" placeholder="Password" required>
                  <div class="invalid-feedback" v-if="formSubmitted && !form.password">Please enter your password.</div>
                </div>
                <div class="text-center mt-4">
                  <button type="submit" class="btn btn-primary">Log In</button>
                </div>
                <div class="text-center mt-3">
                  <p>Don't have an account? <router-link to="/signup" class="signup-link">Sign up here</router-link></p>
                </div>
              </form>
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
import userService from '@/api/userService';
import Swal from 'sweetalert2';

export default {
  name: 'Login',
  components: {
    Navbar1,
    Footer
  },
  data() {
    return {
      form: {
        email: '',
        password: ''
      },
      formSubmitted: false
    };
  },
  methods: {
    async submitForm() {
      this.formSubmitted = true;
      if (this.form.email && this.form.password) {
        try {
          const response = await userService.login({
            email: this.form.email,
            password: this.form.password
          });
          localStorage.setItem('token', response.data.token);
          await Swal.fire({
            title: 'Welcome Back!',
            icon: 'success',
            draggable: true
          });
          this.$router.push('/documents');
        } catch (error) {
          let message = 'Invalid email or password.';
          if (error.response && error.response.data && error.response.data.Message) {
            message = error.response.data.Message;
          }
          this.form.password = ''; // Only clear password
          // Keep form visible, do not redirect
          Swal.fire({
            icon: 'error',
            title: 'Login Failed',
            text: message
          });
        }
      }
    }
  }
};
</script>

<style scoped>
.login-form {
  background-color: #F8FAFC; 
  padding: 2rem;
  border-radius: 10px;
  box-shadow: 0 0 20px rgba(0, 0, 0, 0.1);
}
.login-form .form-control {
  border-radius: 50px;
  border: 1px solid #0ea2bd; 
  color: #2D3748; 
}
.login-form .form-control:focus {
  border-color: #0ea2bd; /* Deep Teal */
  box-shadow: 0 0 0 0.2rem rgba(14, 162, 189, 0.25);
}
.login-form .btn-primary {
  background-color: #0ea2bd; 
  border-color: #0ea2bd;
  border-radius: 50px;
  padding: 0.5rem 1.5rem;
  transition: background-color 0.3s ease, transform 0.2s ease;
}
.login-form .btn-primary:hover {
  background-color: #71d1e2; 
  border-color: #71d1e2;
  transform: scale(1.05);
}
.login-form .signup-link {
  color: #0ea2bd; 
}
.login-form .signup-link:hover {
  color: #71d1e2;
}
.login-image {
  max-width: 100%;
  height: auto;
  border-radius: 10px;
}
</style>