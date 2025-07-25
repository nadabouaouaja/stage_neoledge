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
                    <div class="input-error-container">
                      <input type="text" v-model="form.firstName" placeholder="First Name" required
                        :class="['form-control', inputClass(firstNameValid), { 'is-invalid': formTouched.firstName && firstNameError }]"
                        @blur="formTouched.firstName = true">
                      <div class="error-message-box" v-if="formTouched.firstName && firstNameError">{{ firstNameError }}</div>
                    </div>
                  </div>
                  <div class="col-md-6 form-group mt-3 mt-md-0">
                    <div class="input-error-container">
                      <input type="text" v-model="form.lastName" placeholder="Last Name" required
                        :class="['form-control', inputClass(lastNameValid), { 'is-invalid': formTouched.lastName && lastNameError }]"
                        @blur="formTouched.lastName = true">
                      <div class="error-message-box" v-if="formTouched.lastName && lastNameError">{{ lastNameError }}</div>
                    </div>
                  </div>
                </div>
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
                <div class="form-group mt-3">
                  <div class="input-error-container">
                    <input type="password" v-model="form.confirmPassword" placeholder="Confirm Password" required
                      :class="['form-control', inputClass(confirmPasswordValid), { 'is-invalid': formTouched.confirmPassword && confirmPasswordError }]"
                      @blur="formTouched.confirmPassword = true">
                    <div class="error-message-box" v-if="formTouched.confirmPassword && confirmPasswordError">{{ confirmPasswordError }}</div>
                  </div>
                </div>
                <div class="text-center mt-4">
                  <button type="submit" class="btn btn-primary" :disabled="!formIsValid">Sign Up</button>
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
      formSubmitted: false,
      formTouched: {
        firstName: false,
        lastName: false,
        email: false,
        password: false,
        confirmPassword: false
      }
    };
  },
  computed: {
    firstNameValid() {
      if (!this.formTouched.firstName) return null;
      return /^[A-Za-z\s]+$/.test(this.form.firstName) && this.form.firstName.length > 0;
    },
    lastNameValid() {
      if (!this.formTouched.lastName) return null;
      return /^[A-Za-z\s]+$/.test(this.form.lastName) && this.form.lastName.length > 0;
    },
    emailValid() {
      if (!this.formTouched.email) return null;
      return /^\S+@\S+\.\S+$/.test(this.form.email);
    },
    passwordValid() {
      if (!this.formTouched.password) return null;
      const val = this.form.password;
      return (
        val.length >= 6 &&
        /[a-z]/.test(val) &&
        /[A-Z]/.test(val) &&
        (val.match(/\d/g) || []).length >= 3
      );
    },
    confirmPasswordValid() {
      if (!this.formTouched.confirmPassword) return null;
      return this.form.password && this.form.confirmPassword && this.form.password === this.form.confirmPassword;
    },
    firstNameError() {
      if (!this.formTouched.firstName) return '';
      if (!this.form.firstName) return 'First name is required.';
      if (!/^[A-Za-z\s]+$/.test(this.form.firstName)) return 'First name can only contain letters and spaces.';
      return '';
    },
    lastNameError() {
      if (!this.formTouched.lastName) return '';
      if (!this.form.lastName) return 'Last name is required.';
      if (!/^[A-Za-z\s]+$/.test(this.form.lastName)) return 'Last name can only contain letters and spaces.';
      return '';
    },
    emailError() {
      if (!this.formTouched.email) return '';
      if (!this.form.email) return 'Email is required.';
      if (!/^\S+@\S+\.\S+$/.test(this.form.email)) return 'Please enter a valid email address.';
      return '';
    },
    passwordError() {
      if (!this.formTouched.password) return '';
      const val = this.form.password;
      if (!val) return 'Password is required.';
      if (val.length < 6) return 'Password must be at least 6 characters.';
      if (!/[a-z]/.test(val)) return 'Password must contain at least one lowercase letter.';
      if (!/[A-Z]/.test(val)) return 'Password must contain at least one uppercase letter.';
      if ((val.match(/\d/g) || []).length < 3) return 'Password must contain at least 3 digits.';
      return '';
    },
    confirmPasswordError() {
      if (!this.formTouched.confirmPassword) return '';
      if (!this.form.confirmPassword) return 'Please confirm your password.';
      if (this.form.password !== this.form.confirmPassword) return "Passwords don't match.";
      return '';
    },
    formIsValid() {
      return (
        this.firstNameValid &&
        this.lastNameValid &&
        this.emailValid &&
        this.passwordValid &&
        this.confirmPasswordValid
      );
    }
  },
  methods: {
    inputClass(valid) {
      if (valid === null) return '';
      return valid ? 'input-valid' : 'input-invalid';
    },
    async submitForm() {
      this.formSubmitted = true;
      if (
        this.firstNameValid &&
        this.lastNameValid &&
        this.emailValid &&
        this.passwordValid &&
        this.confirmPasswordValid
      ) {
        try {
          await userService.register({
            email: this.form.email,
            password: this.form.password,
            firstName: this.form.firstName,
            lastName: this.form.lastName
          });
          Swal.fire({
            title: 'Registration successful!',
            icon: 'success',
            text: 'You can now log in with your new account.',
            showConfirmButton: false,
            timer: 2000,
            timerProgressBar: true,
            allowOutsideClick: false,
            allowEscapeKey: false
          });
          setTimeout(() => {
            this.$router.push('/login');
          }, 2000);
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
  border: 2px solid #0ea2bd; /* blue by default */
  color: #2D3748; 
  transition: border-color 0.3s;
}
.signup-form .form-control.input-valid {
  border-color: #0ea2bd; /* blue */
}
.signup-form .form-control.input-invalid {
  border-color:rgb(248, 103, 98); /* red */
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
.error-message {
  color:rgb(247, 95, 89);
  font-weight: bold;
  margin-top: 0.25rem;
  font-size: 0.95em;
  animation: shake 0.2s 1;
}
.input-error-container {
  position: relative;
  /* Remove margin-bottom if not needed, or keep a small one for spacing */
  margin-bottom: 0.5em;
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