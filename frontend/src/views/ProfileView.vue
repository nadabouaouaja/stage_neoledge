<template>
  <div>
    <Navbar />
    <br>
    <section id="profile" class="contact section" style="padding-top: 0%;">
      <div class="container section-title" data-aos="fade-up">
        <h2>User Profile</h2>
        <p>Consult and update your profile information</p>
      </div>
      <div class="container" data-aos="fade-up" data-aos-delay="100">
        <div class="row justify-content-center">
          <div class="col-lg-6">
            <div class="add-document-card text-center">
              <div class="profile-avatar mb-3 mx-auto">
                <span class="avatar-initials">{{ avatarInitials }}</span>
              </div>
              <form @submit.prevent="saveProfile" class="add-document-form text-start">
                <div class="mb-3 row align-items-center">
                  <div class="col-4 fw-bold">First Name:</div>
                  <div class="col-8">
                    <span v-if="!isEditing">{{ form.firstName }}</span>
                    <div v-else class="input-error-container">
                      <input type="text" class="form-control" v-model="form.firstName" required
                        :class="[inputClass(firstNameValid), { 'is-invalid': formTouched.firstName && firstNameError }]"
                        @blur="formTouched.firstName = true">
                      <div class="error-message-box" v-if="formTouched.firstName && firstNameError">{{ firstNameError }}</div>
                    </div>
                  </div>
                </div>
                <div class="mb-3 row align-items-center">
                  <div class="col-4 fw-bold">Last Name:</div>
                  <div class="col-8">
                    <span v-if="!isEditing">{{ form.lastName }}</span>
                    <div v-else class="input-error-container">
                      <input type="text" class="form-control" v-model="form.lastName" required
                        :class="[inputClass(lastNameValid), { 'is-invalid': formTouched.lastName && lastNameError }]"
                        @blur="formTouched.lastName = true">
                      <div class="error-message-box" v-if="formTouched.lastName && lastNameError">{{ lastNameError }}</div>
                    </div>
                  </div>
                </div>
                <div class="mb-3 row align-items-center">
                  <div class="col-4 fw-bold">Email:</div>
                  <div class="col-8">
                    <span v-if="!isEditing">{{ form.email }}</span>
                    <div v-else class="input-error-container">
                      <input type="text" class="form-control" v-model="form.email" required
                        :class="[inputClass(emailValid), { 'is-invalid': formTouched.email && emailError }]"
                        @blur="formTouched.email = true">
                      <div class="error-message-box" v-if="formTouched.email && emailError">{{ emailError }}</div>
                    </div>
                  </div>
                </div>
                <div class="mb-3 row align-items-center">
                  <div class="col-4 fw-bold">Profile Created On:</div>
                  <div class="col-8">
                    <span>{{ form.createdOn }}</span>
                  </div>
                </div>
                <div class="mb-3 row align-items-center">
                  <div class="col-4 fw-bold">Last Login:</div>
                  <div class="col-8">
                    <span>{{ form.lastLogin }}</span>
                  </div>
                </div>
              
                <div v-if="isEditing" class="mb-3 row align-items-center">
                  <div class="col-4 fw-bold">New Password:</div>
                  <div class="col-8">
                    <input type="password" class="form-control" v-model="form.password" placeholder="Leave blank to keep current password">
                  </div>
                </div>
                <div class="text-center mt-4">
                  <button v-if="!isEditing" type="button" class="btn btn-primary" @click="isEditing = true">Edit</button>
                  <div v-else>
                    <button type="submit" class="btn btn-primary me-2" :disabled="!formIsValid">Save</button>
                    <button type="button" class="btn btn-secondary" @click="cancelEdit">Cancel</button>
                  </div>
                </div>
              </form>
            </div>
          </div>
        </div>
      </div>
    </section>
    <Footer />
  </div>
</template>

<script>
import Navbar from '../components/Navbar.vue';
import Footer from '../components/Footer.vue';
import userService from '@/api/userService';
import Swal from 'sweetalert2';
import { jwtDecode } from 'jwt-decode';

export default {
  name: 'Profile',
  components: { Navbar, Footer },
  data() {
    return {
      isEditing: false,
      form: {
        firstName: '',
        lastName: '',
        email: '',
        password: '',
        createdOn: '',
        lastLogin: ''
      },
      originalForm: {},
      userId: null,
      formTouched: {
        firstName: false,
        lastName: false,
        email: false
      }
    };
  },
  computed: {
    avatarInitials() {
      const first = this.form.firstName ? this.form.firstName[0].toUpperCase() : '';
      const last = this.form.lastName ? this.form.lastName[0].toUpperCase() : '';
      return first + last;
    },
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
    formIsValid() {
      return this.firstNameValid && this.lastNameValid && this.emailValid;
    }
  },
  async created() {
    const token = localStorage.getItem('token');
    if (token) {
      const decoded = jwtDecode(token);
      this.userId = decoded.sub ? parseInt(decoded.sub) : null;
      if (this.userId) {
        try {
          const res = await userService.getUserDetails(this.userId);
          this.form.firstName = res.data.firstName || res.data.FirstName;
          this.form.lastName = res.data.lastName || res.data.LastName;
          this.form.email = res.data.email || res.data.Email;
          this.form.createdOn = res.data.createdAt
            ? new Date(res.data.createdAt).toLocaleDateString()
            : '';
          this.form.lastLogin = res.data.lastLogin
            ? new Date(res.data.lastLogin).toLocaleString()
            : '';
          this.originalForm = { ...this.form };
        } catch (err) {
          Swal.fire({ icon: 'error', title: 'Error', text: 'Failed to load profile.' });
        }
      }
    }
  },
  methods: {
    inputClass(valid) {
      if (valid === null) return '';
      return valid ? 'input-valid' : 'input-invalid';
    },
    async saveProfile() {
      this.formTouched.firstName = true;
      this.formTouched.lastName = true;
      this.formTouched.email = true;
      if (!this.formIsValid) return;
      try {
        await userService.updateProfile(this.userId, {
          email: this.form.email,
          firstName: this.form.firstName,
          lastName: this.form.lastName
        });
        Swal.fire({
          icon: 'success',
          title: 'Profile updated!',
          showConfirmButton: false,
          timer: 2000,
          timerProgressBar: true,
          allowOutsideClick: false,
          allowEscapeKey: false
        });
        this.isEditing = false;
        this.originalForm = { ...this.form, password: '' };
        this.form.password = '';
      } catch (err) {
        Swal.fire({ icon: 'error', title: 'Error', text: 'Failed to update profile.' });
      }
    },
    cancelEdit() {
      this.form = { ...this.originalForm, password: '' };
      this.isEditing = false;
      this.formTouched.firstName = false;
      this.formTouched.lastName = false;
      this.formTouched.email = false;
    }
  }
};
</script>

<style scoped>
.add-document-card {
  background-color: #F8FAFC;
  padding: 1.5rem;
  border-radius: 10px;
  box-shadow: 0 0 15px rgba(0, 0, 0, 0.1);
  transition: transform 0.3s ease;
}
.add-document-card:hover {
  transform: translateY(-5px);
}
.add-document-form .form-control,
.add-document-form .form-select {
  border-radius: 50px;
  border: 1px solid #0ea2bd;
  background-color: #F8FAFC;
  color: #2D3748;
  padding: 0.5rem 1.5rem;
  transition: border-color 0.3s ease, box-shadow 0.3s ease;
}
.add-document-form .form-control:focus,
.add-document-form .form-select:focus {
  border-color: #0ea2bd;
  box-shadow: 0 0 0 0.2rem rgba(14, 162, 189, 0.25);
}
.add-document-form .btn-primary {
  background-color: #0ea2bd;
  border-color: #0ea2bd;
  color: #fff;
  border-radius: 50px;
  padding: 0.5rem 1.5rem;
  transition: background-color 0.3s ease, transform 0.2s ease;
}
.add-document-form .btn-primary:hover {
  background-color: #71d1e2;
  border-color: #71d1e2;
  transform: scale(1.05);
}
.add-document-form .btn-secondary {
  border-radius: 50px;
  padding: 0.5rem 1.5rem;
  background: #e0f7fa;
  color: #0ea2bd;
  border: 1px solid #0ea2bd;
  margin-left: 0.5rem;
}
.profile-avatar {
  width: 70px;
  height: 70px;
  border-radius: 50%;
  background: #e0f7fa;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 2rem;
  color: #0ea2bd;
  margin-bottom: 1rem;
  box-shadow: 0 2px 8px rgba(0,0,0,0.07);
}
.avatar-initials {
  font-weight: 600;
}
.input-error-container {
  position: relative;
  margin-bottom: 0.5em;
}
.add-document-form .form-control.input-valid {
  border-color: #0ea2bd;
}
.add-document-form .form-control.input-invalid {
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