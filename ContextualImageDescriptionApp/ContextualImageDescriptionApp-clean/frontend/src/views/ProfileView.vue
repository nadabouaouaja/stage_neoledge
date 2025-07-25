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
                    <input v-else type="text" class="form-control" v-model="form.firstName" required>
                  </div>
                </div>
                <div class="mb-3 row align-items-center">
                  <div class="col-4 fw-bold">Last Name:</div>
                  <div class="col-8">
                    <span v-if="!isEditing">{{ form.lastName }}</span>
                    <input v-else type="text" class="form-control" v-model="form.lastName" required>
                  </div>
                </div>
                <div class="mb-3 row align-items-center">
                  <div class="col-4 fw-bold">Email:</div>
                  <div class="col-8">
                    <span v-if="!isEditing">{{ form.email }}</span>
                    <input v-else type="text" class="form-control" v-model="form.email" required>
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
                    <button type="submit" class="btn btn-primary me-2">Save</button>
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
      userId: null
    };
  },
  computed: {
    avatarInitials() {
      const first = this.form.firstName ? this.form.firstName[0].toUpperCase() : '';
      const last = this.form.lastName ? this.form.lastName[0].toUpperCase() : '';
      return first + last;
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
    async saveProfile() {
      try {
        await userService.updateProfile(this.userId, {
          email: this.form.email,
          firstName: this.form.firstName,
          lastName: this.form.lastName
        });
        Swal.fire({ icon: 'success', title: 'Profile updated!' });
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
</style> 