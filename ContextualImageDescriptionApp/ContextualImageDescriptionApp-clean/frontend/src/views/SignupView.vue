<template>
  <div>
    <Navbar1 />
    <main class="main">
      <!-- Signup Section -->
      <section id="signup" class="contact section" style="padding-top: 0%;">
        <div class="container section-title" data-aos="fade-up">
          <h2>Create Your Account</h2>
          <p>Join IntelliDoc to manage and analyze documents with AI-powered insights</p>
        </div>
        <div class="container" data-aos="fade-up" data-aos-delay="100">
          <div class="row gy-4 align-items-center">
            <div class="col-lg-6">
              <img src="/assets/img/custom/signup.jpeg" class="signup-image img-fluid" alt="IntelliDoc AI Document Management" data-aos="fade-right" data-aos-delay="200" style="max-width: 80%;">
            </div>
            <div class="col-lg-6">
              <form @submit.prevent="submitForm" class="signup-form" :class="{ 'was-validated': formSubmitted }">
                <div class="row">
                  <div class="col-md-6 form-group">
                    <input type="text" class="form-control" v-model="form.firstName" placeholder="First Name" required>
                    <div class="invalid-feedback" v-if="formSubmitted && !form.firstName">Please enter your first name.</div>
                  </div>
                  <div class="col-md-6 form-group mt-3 mt-md-0">
                    <input type="text" class="form-control" v-model="form.lastName" placeholder="Last Name" required>
                    <div class="invalid-feedback" v-if="formSubmitted && !form.lastName">Please enter your last name.</div>
                  </div>
                </div>
                <div class="form-group mt-3">
                  <input type="text" class="form-control" v-model="form.email" placeholder="Your Email" required>
                  <div class="invalid-feedback" v-if="formSubmitted && !form.email">Please enter a valid email address.</div>
                </div>
                <div class="form-group mt-3">
                  <input type="password" class="form-control" v-model="form.password" placeholder="Password" required>
                  <div class="invalid-feedback" v-if="formSubmitted && !form.password">Please enter a password.</div>
                </div>
                <div class="form-group mt-3">
                  <input type="password" class="form-control" v-model="form.confirmPassword" placeholder="Confirm Password" required>
                  <div class="invalid-feedback" v-if="formSubmitted && (!form.confirmPassword || form.password !== form.confirmPassword)">Passwords do not match.</div>
                </div>
                <div class="text-center mt-4">
                  <button type="submit" class="btn btn-primary">Sign Up</button>
                </div>
                <div class="text-center mt-3">
                  <p>Already have an account? <router-link to="/login" class="login-link">Login here</router-link></p>
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
  name: 'Signup',
  components: {
    Navbar1,
    Footer
  },
  data() {
    return {
      form: {
        firstName: '',
        lastName: '',
        email: '',
        password: '',
        confirmPassword: ''
      },
      formSubmitted: false
    };
  },
  methods: {
    async submitForm() {
      this.formSubmitted = true;
      if (
        this.form.firstName &&
        this.form.lastName &&
        this.form.email &&
        this.form.password &&
        this.form.password === this.form.confirmPassword
      ) {
        try {
          await userService.register({
            email: this.form.email,
            password: this.form.password,
            firstName: this.form.firstName,
            lastName: this.form.lastName
          });
          await Swal.fire({
            title: 'Registration successful!',
            icon: 'success',
            text: 'You can now log in with your new account.'
          });
          this.$router.push('/login');
        } catch (error) {
          let message = 'Something went wrong!';
          if (error.response && error.response.data && error.response.data.Message) {
            message = error.response.data.Message;
          }
          Swal.fire({
            icon: 'error',
            title: 'Registration Failed',
            text: message
          });
        }
      }
    }
  }
};
</script>

<style scoped>
.signup-form {
  background-color: #F8FAFC; 
  padding: 2rem;
  border-radius: 10px;
  box-shadow: 0 0 20px rgba(0, 0, 0, 0.1);
}
.signup-form .form-control {
  border-radius: 50px;
  border: 1px solid #0ea2bd; 
  color: #2D3748; 
}
.signup-form .form-control:focus {
  border-color: #0ea2bd;
  box-shadow: 0 0 0 0.2rem rgba(14, 162, 189, 0.25);
}
.signup-form .btn-primary {
  background-color: #0ea2bd; 
  border-color: #0ea2bd;
  border-radius: 50px;
  padding: 0.5rem 1.5rem;
  transition: background-color 0.3s ease, transform 0.2s ease;
}
.signup-form .btn-primary:hover {
  background-color: #71d1e2; 
  border-color: #71d1e2;
  transform: scale(1.05);
}
.signup-form .login-link {
  color: #0ea2bd; 
}
.signup-form .login-link:hover {
  color: #71d1e2; 
}
.signup-image {
  max-width: 100%;
  height: auto;
  border-radius: 10px;
}
</style>