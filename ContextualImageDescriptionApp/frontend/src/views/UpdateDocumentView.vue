<template>
  <div>
    <Navbar />
    <br>
    <section id="update-document" class="contact section" style="padding-top: 0%;">
      <div class="container section-title" data-aos="fade-up">
        <h2>Update Document</h2>
        <p>Edit your document details and upload a new file if needed</p>
      </div>
      <div class="container" data-aos="fade-up" data-aos-delay="100">
        <div class="row justify-content-center">
          <div class="col-lg-6">
            <div class="add-document-card">
              <div v-if="loading" class="text-center">
                <div class="spinner-border text-primary" role="status">
                  <span class="visually-hidden">Loading...</span>
                </div>
                <p class="mt-2">Loading document details...</p>
              </div>
              <form v-else @submit.prevent="submitForm" class="add-document-form">
                <div class="mb-3">
                  <label for="documentName" class="form-label">Document Name</label>
                  <div class="input-error-container">
                    <input type="text" class="form-control" id="documentName" v-model="form.title" placeholder="Enter document name" required
                      :class="[inputClass(titleValid), { 'is-invalid': formTouched.title && titleError }]"
                      @blur="formTouched.title = true">
                    <div class="error-message-box" v-if="formTouched.title && titleError">{{ titleError }}</div>
                  </div>
                </div>
                <div class="mb-3">
                  <label for="category" class="form-label">Category</label>
                  <div class="input-error-container">
                    <select class="form-select" id="category" v-model="form.category" required
                      :class="[inputClass(categoryValid), { 'is-invalid': formTouched.category && categoryError }]"
                      @blur="formTouched.category = true">
                      <option value="" disabled>Select a category</option>
                      <option value="General">General</option>
                      <option value="Invoice">Invoice</option>
                      <option value="Report">Report</option>
                      <option value="Contract">Contract</option>
                      <option value="Other">Other</option>
                    </select>
                    <div class="error-message-box" v-if="formTouched.category && categoryError">{{ categoryError }}</div>
                  </div>
                </div>
                <br>
                <div class="text-center">
                  <button type="submit" class="btn btn-primary" :disabled="!formIsValid || submitting">
                    <span v-if="submitting" class="spinner-border spinner-border-sm me-2" role="status"></span>
                    {{ submitting ? 'Updating...' : 'Save Changes' }}
                  </button>
                  <router-link :to="`/documents`" class="btn btn-secondary ms-2">Cancel</router-link>
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
import documentService from '../api/documentService';
import Swal from 'sweetalert2';
import Category from '@/entities/Category';

export default {
  name: 'UpdateDocumentView',
  components: { Navbar, Footer },
  data() {
    return {
      documentId: null,
      loading: true,
      submitting: false,
      form: {
        title: '',
        category: ''
      },
      formTouched: {
        title: false,
        category: false
      }
    };
  },
  computed: {
    titleValid() {
      if (!this.formTouched.title) return null;
      return !!this.form.title;
    },
    categoryValid() {
      if (!this.formTouched.category) return null;
      return !!this.form.category;
    },
    titleError() {
      if (!this.formTouched.title) return '';
      if (!this.form.title) return 'Document name is required.';
      return '';
    },
    categoryError() {
      if (!this.formTouched.category) return '';
      if (!this.form.category) return 'Category is required.';
      return '';
    },
    formIsValid() {
      return this.titleValid && this.categoryValid;
    }
  },
  async created() {
    this.documentId = this.$route.params.id;
    await this.loadDocument();
  },
  methods: {
    inputClass(valid) {
      if (valid === null) return '';
      return valid ? 'input-valid' : 'input-invalid';
    },
    async loadDocument() {
      try {
        this.loading = true;
        const response = await documentService.getDocument(this.documentId);
        const document = response.data;
        this.form = {
          title: document.title || '',
          category: typeof document.category === 'number' ? Category[document.category] : (document.category || ''),
        };
      } catch (error) {
        console.error('Error loading document:', error);
        Swal.fire({
          icon: 'error',
          title: 'Error',
          text: error.response?.data?.message || 'Failed to load document details',
          confirmButtonColor: '#0ea2bd'
        });
        this.$router.push('/documents');
      } finally {
        this.loading = false;
      }
    },
    async submitForm() {
      try {
        this.submitting = true;
        
        await documentService.updateDocument(this.documentId, {
          title: this.form.title,
          category: Category.indexOf(this.form.category)
        });

        Swal.fire({
          icon: 'success',
          title: 'Success!',
          text: 'Document updated successfully',
          showConfirmButton: false,
          timer: 2000,
          timerProgressBar: true,
          allowOutsideClick: false,
          allowEscapeKey: false
        });

        this.$router.push(`/documents`);
      } catch (error) {
        console.error('Error updating document:', error);
        Swal.fire({
          icon: 'error',
          title: 'Error',
          text: error.response?.data?.message || 'Failed to update document',
          confirmButtonColor: '#0ea2bd'
        });
      } finally {
        this.submitting = false;
      }
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
.add-document-form .form-select option {
  background-color: #fff;
  color: #2D3748;
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
.add-document-form .form-label {
  color: #2D3748;
  font-weight: 500;
}
.input-error-container {
  position: relative;
  margin-bottom: 0.5em;
}
.add-document-form .form-control.input-valid,
.add-document-form .form-select.input-valid {
  border-color: #0ea2bd;
}
.add-document-form .form-control.input-invalid,
.add-document-form .form-select.input-invalid {
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