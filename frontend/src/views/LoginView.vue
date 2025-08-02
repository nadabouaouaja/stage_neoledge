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
                  <div class="input-error-container">
                    <input type="text" v-model="form.email" placeholder="Your Email" required
                      :class="['form-control', inputClass(emailValid), { 'is-invalid': formTouched.email && emailError }]"
                      @blur="formTouched.email = true">
                    <div class="error-message-box" v-if="formTouched.email && emailError">{{ emailError }}</div>
                  </div>
                </div>
                <div class="form-group mt-3">
                  <div class="input-error-container">
                    <input type="password" v-model="form.password" placeholder="Password" required
                      :class="['form-control', inputClass(passwordValid), { 'is-invalid': formTouched.password && passwordError }]"
                      @blur="formTouched.password = true">
                    <div class="error-message-box" v-if="formTouched.password && passwordError">{{ passwordError }}</div>
                  </div>
                </div>
                <div class="text-center mt-4">
                  <button type="submit" class="btn btn-primary" :disabled="!formIsValid">Log In</button>
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
      formSubmitted: false,
      formTouched: {
        email: false,
        password: false
      }
    };
  },
  computed: {
    emailValid() {
      if (!this.formTouched.email) return null;
      return /^\S+@\S+\.\S+$/.test(this.form.email);
    },
    passwordValid() {
      if (!this.formTouched.password) return null;
      return !!this.form.password;
    },
    emailError() {
      if (!this.formTouched.email) return '';
      if (!this.form.email) return 'Email is required.';
      if (!/^\S+@\S+\.\S+$/.test(this.form.email)) return 'Please enter a valid email address.';
      return '';
    },
    passwordError() {
      if (!this.formTouched.password) return '';
      if (!this.form.password) return 'Password is required.';
      return '';
    },
    formIsValid() {
      return this.emailValid && this.passwordValid;
    }
  },
  methods: {
    inputClass(valid) {
      if (valid === null) return '';
      return valid ? 'input-valid' : 'input-invalid';
    },
    async submitForm() {
      this.formSubmitted = true;
      this.formTouched.email = true;
      this.formTouched.password = true;
      if (this.emailValid && this.passwordValid) {
        try {
          const response = await userService.login({
            email: this.form.email,
            password: this.form.password
          });
          localStorage.setItem('token', response.data.token);
          Swal.fire({
            title: 'Welcome Back!',
            icon: 'success',
            showConfirmButton: false,
            timer: 2000,
            timerProgressBar: true,
            allowOutsideClick: false,
            allowEscapeKey: false
          });
          setTimeout(() => {
            this.$router.push('/documents');
          }, 2000);
        } catch (error) {
          let message = 'Invalid email or password.';
          if (error.response && error.response.data && error.response.data.Message) {
            message = error.response.data.Message;
          }
          this.form.password = '';
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
.input-error-container {
  position: relative;
  margin-bottom: 0.5em;
}
.login-form .form-control.input-valid {
  border-color: #0ea2bd;
}
.login-form .form-control.input-invalid {
  border-color: rgb(248, 103, 98);
}
.error-message-box {
  background: rgba(247, 95, 89, 0.12);
  border: 1.5px solid rgb(247, 95, 89);
  color: rgb(247, 95, 89);
  border-radius: 8px;
  padding: 0.5em 1em;
  margin-top: 0.35rem;
  font-size: 0.97em;
  font-weight: 500;
  box-shadow: 0 2px 8px rgba(247, 95, 89, 0.07);
  display: inline-block;
  animation: shake 0.2s 1;
  position: relative;
  left: 0;
  top: 0;
  z-index: 1;
}
.error-message-box::before {
  content: '';
  position: absolute;
  top: -8px;
  left: 18px;
  width: 0;
  height: 0;
  border-left: 8px solid transparent;
  border-right: 8px solid transparent;
  border-bottom: 8px solid rgb(247, 95, 89);
  filter: drop-shadow(0 1px 1px rgba(247, 95, 89, 0.07));
}
@keyframes shake {
  0% { transform: translateX(0); }
  25% { transform: translateX(-4px); }
  50% { transform: translateX(4px); }
  75% { transform: translateX(-4px); }
  100% { transform: translateX(0); }
}
</style>