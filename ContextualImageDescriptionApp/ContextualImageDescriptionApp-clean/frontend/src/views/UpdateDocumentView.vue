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
                  <input type="text" class="form-control" id="documentName" v-model="form.title" placeholder="Enter document name" required>
                </div>
                <div class="mb-3">
                  <label for="category" class="form-label">Category</label>
                  <select class="form-select" id="category" v-model="form.category" required>
                    <option value="" disabled>Select a category</option>
                    <option value="Contract">Contract</option>
                    <option value="Report">Report</option>
                    <option value="Invoice">Invoice</option>
                  </select>
                </div>
                <div class="mb-3">
                  <label for="descriptionDoc" class="form-label">Description</label>
                  <input type="text" class="form-control" id="descriptionDoc" v-model="form.content" placeholder="Enter document description" required>
                </div>
               <br>
                <div class="text-center">
                  <button type="submit" class="btn btn-primary" :disabled="submitting">
                    <span v-if="submitting" class="spinner-border spinner-border-sm me-2" role="status"></span>
                    {{ submitting ? 'Updating...' : 'Save Changes' }}
                  </button>
                  <router-link :to="`/details/${documentId}`" class="btn btn-secondary ms-2">Cancel</router-link>
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
        category: '',
        content: ''
      }
    };
  },
  async created() {
    this.documentId = this.$route.params.id;
    await this.loadDocument();
  },
  methods: {
    async loadDocument() {
      try {
        this.loading = true;
        const response = await documentService.getDocument(this.documentId);
        const document = response.data;
        
        this.form = {
          title: document.title || '',
          category: document.category || '',
          content: document.content || ''
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
          category: this.form.category
        });

        Swal.fire({
          icon: 'success',
          title: 'Success!',
          text: 'Document updated successfully',
          confirmButtonColor: '#0ea2bd'
        });

        // Redirect to document details page
        this.$router.push(`/details/${this.documentId}`);
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
</style> 