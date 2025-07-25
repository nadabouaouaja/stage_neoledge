<template>
     <div>
       <Navbar />
       <br>
       <!-- Add Document Section -->
       <section id="add-document" class="contact section" style="padding-top: 0%;">
         <div class="container section-title" data-aos="fade-up">
           <h2>Add New Document</h2>
           <p>Upload a document for AI-powered analysis and management</p>
         </div>
         <div class="container" data-aos="fade-up" data-aos-delay="100">
           <div class="row justify-content-center">
             <div class="col-lg-6">
               <div class="add-document-card">
                 <form @submit.prevent="submitForm" class="add-document-form">
                   <div class="mb-3">
                     <label for="documentName" class="form-label">Document Name</label>
                     <input type="text" class="form-control" id="documentName" v-model="form.title" placeholder="Enter document name" required>
                   </div>
                   <div class="mb-3">
                     <label for="category" class="form-label">Category</label>
                     <select class="form-select" id="category" v-model="form.category" required>
                       <option value="" disabled>Select a category</option>
                       <option value="General">General</option>
                       <option value="Invoice">Invoice</option>
                       <option value="Report">Report</option>
                       <option value="Contract">Contract</option>
                       <option value="Other">Other</option>
                     </select>
                   </div>
                   <div class="mb-3">
                     <label for="documentFile" class="form-label">Upload Document</label>
                     <input type="file" class="form-control" id="documentFile" ref="fileInput" @change="handleFileUpload" accept=".pdf,.doc,.docx" required>
                   </div>
                   <div class="text-center">
                     <button type="submit" class="btn btn-primary" :disabled="submitting">
                       <span v-if="submitting" class="spinner-border spinner-border-sm me-2" role="status"></span>
                       {{ submitting ? 'Adding...' : 'Add Document' }}
                     </button>
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
     name: 'AddDocument',
     components: {
    Navbar,
    Footer
    },
     data() {
       return {
         form: {
           title: '',
           category: '',
           file: null
         },
         submitting: false
       };
     },
     methods: {
       handleFileUpload(event) {
         this.form.file = event.target.files[0];
       },
       async submitForm() {
         if (!this.form.file) {
           Swal.fire({
             icon: 'warning',
             title: 'Missing File',
             text: 'Please select a document file to upload.',
             confirmButtonColor: '#0ea2bd'
           });
           return;
         }
         this.submitting = true;
         try {
           await documentService.createDocument({
             file: this.form.file,
             title: this.form.title,
             category: this.form.category
           });
           Swal.fire({
             icon: 'success',
             title: 'Success!',
             text: 'Document added successfully',
             confirmButtonColor: '#0ea2bd'
           });
           this.$router.push('/documents');
         } catch (error) {
           console.error('Error adding document:', error);
           Swal.fire({
             icon: 'error',
             title: 'Error',
             text: error.response?.data?.message || 'Failed to add document',
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
     background-color: #0ea2bd; /* Deep Teal */
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