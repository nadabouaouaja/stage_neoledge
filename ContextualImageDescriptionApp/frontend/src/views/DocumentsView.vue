<template>
     <div>
       <Navbar />
       <br>
       <!-- Documents Section -->
       <section id="documents" class="featured-services section" style="padding-top: 0%;">
         <div class="container section-title" data-aos="fade-up">
           <h2>Your Documents</h2>
           <p>Manage and analyze your documents with AI-powered insights</p>
         </div>
         <div class="container" data-aos="fade-up" data-aos-delay="100">
           <div class="row mb-2">
             <div class="col-12 text-center">
               <router-link to="/add-document" class="btn add-document-btn mb-2">Add Document</router-link>
             </div>
           </div>
           <br>
           <div class="row mb-4 align-items-center flex-nowrap g-2">
             <div class="col-md-4 col-12">
               <div class="search-bar">
                 <input type="text" class="form-control" v-model="searchInput" placeholder="Search documents..." @input="filterDocuments">
                 <i class="bi bi-search search-icon" @click="filterDocuments"></i>
               </div>
             </div>
             <div class="col-md-4 col-12">
               <div class="filter-dropdown">
                 <select class="form-select" v-model="categoryFilter" @change="filterDocuments">
                   <option value="all">All Categories</option>
                   <option value="Contract">Contract</option>
                   <option value="Report">Report</option>
                   <option value="Invoice">Invoice</option>
                   <option value="General">General</option>
                 </select>
               </div>
             </div>
             <div class="col-md-4 col-12 d-flex justify-content-md-end justify-content-start mt-2 mt-md-0">
               <button class="btn add-document-btn sort-btn" @click="toggleSortOrder">
                 <i :class="sortOrder === 'desc' ? 'bi bi-sort-down' : 'bi bi-sort-up'"></i>
                 Sort: {{ sortOrder === 'desc' ? 'Newest' : 'Oldest' }}
               </button>
             </div>
           </div>
           <div class="row gy-4 gx-4" id="documentList">
             <div v-for="doc in paginatedDocuments" :key="doc.id"  class="col-xl-3 col-md-6 mb-4">
               <div class="document-card position-relative w-100 h-100">
                 <div class="document-actions position-absolute top-0 end-0 p-2 d-flex gap-2">
                   <button class="icon-btn icon-edit" @click="updateDocument(doc)" title="Edit"><i class="bi bi-pencil"></i></button>
                   <button class="icon-btn icon-delete" @click="deleteDocument(doc.id)" title="Delete"><i class="bi bi-trash"></i></button>
                   <button class="icon-btn icon-download" @click="downloadDocument(doc.id)" title="Download"><i class="bi bi-download"></i></button>
                 </div>
                 <br><br>
                 <iframe v-if="doc.filePath" :src="`http://localhost:5047/uploads/${doc.filePath.split(/[\\/]/).pop()}`" width="100%" height="200" style="border-radius: 8px; border: 1px solid #eee;" allowfullscreen></iframe>
                 <br>
                 <h4 style="color: #0ea2bd;">{{ doc.title }}</h4>
                 <p><strong>Uploaded:</strong> {{ doc.uploaded }}</p>
                 <p><strong>Category:</strong> {{ doc.category }}</p>
                 <p><strong>Status:</strong> {{ doc.status }}</p>
                 <div class="d-flex justify-content-between align-items-center mt-3 flex-wrap gap-2">
                   <button class="btn btn-primary flex-fill me-1 mb-1" @click="showDetails(doc)"><i class="bi bi-info-circle me-1"></i>Details</button>
                   <button class="btn btn-secondary flex-fill mb-1" @click="analyzeDocument(doc)"><i class="bi bi-graph-up-arrow me-1"></i>Analyze</button>
                
                 </div>
               </div>
             </div>
           </div>
           <br><br>
           <nav aria-label="Document pagination" class="mt-4">
             <ul class="pagination justify-content-center">
               <li class="page-item" :class="{ disabled: currentPage === 1 }">
                 <a class="page-link" href="#" aria-label="Previous" @click.prevent="prevPage">Previous</a>
               </li>
               <li v-for="page in totalPages" :key="page" class="page-item" :class="{ active: currentPage === page }">
                 <a class="page-link" href="#" @click.prevent="goToPage(page)">{{ page }}</a>
               </li>
               <li class="page-item" :class="{ disabled: currentPage === totalPages }">
                 <a class="page-link" href="#" aria-label="Next" @click.prevent="nextPage">Next</a>
               </li>
             </ul>
           </nav>
         </div>
       </section>
       <Footer />
     </div>
   </template>

   <script>
   import axios from 'axios';
   import Footer from '../components/Footer.vue';
   import Navbar from '../components/Navbar.vue';
   import documentService from '@/api/documentService';
   import Swal from 'sweetalert2';
   import Category from '@/entities/Category';
   import Status from '@/entities/Status';
   export default {
     name: 'Documents',
     components: {
       Footer,
       Navbar
     },
     data() {
       return {
         searchInput: '',
         categoryFilter: 'all',
         sortOrder: 'desc',
         documents: [ ],
         currentPage: 1,
         pageSize: 12
       };
     },
     async created() {
       try {
         const response = await documentService.listDocuments();
         this.documents = response.data.map(doc => ({
           id: doc.documentID,
           title: doc.title,
           filePath: doc.filePath,
           category: Category[doc.category], // maps number to string
           uploaded: doc.uploadDate ? new Date(doc.uploadDate).toLocaleDateString() : '',
           content: doc.content,
           image: doc.filePath? `http://localhost:5047/uploads/${doc.filePath.split(/[\\/]/).pop()}`: '/assets/img/features-1.svg',
           status: Status[doc.status] // maps number to string
         }));
       } catch (error) {
         Swal.fire({ icon: 'error', title: 'Error', text: 'Failed to fetch documents.' });
       }
     },
     computed: {
       filteredDocuments() {
         let docs = this.documents.filter(doc => {
           const matchesSearch = doc.title.toLowerCase().includes(this.searchInput.toLowerCase()) ||
                                doc.content.toLowerCase().includes(this.searchInput.toLowerCase());
           const matchesCategory = this.categoryFilter === 'all' || doc.category === this.categoryFilter;
           return matchesSearch && matchesCategory;
         });
         // Sort by uploaded date
         docs = docs.slice().sort((a, b) => {
           const dateA = new Date(a.uploaded);
           const dateB = new Date(b.uploaded);
           return this.sortOrder === 'desc' ? dateB - dateA : dateA - dateB;
         });
         return docs;
       },
       paginatedDocuments() {
         const start = (this.currentPage - 1) * this.pageSize;
         return this.filteredDocuments.slice(start, start + this.pageSize);
       },
       totalPages() {
         return Math.ceil(this.filteredDocuments.length / this.pageSize) || 1;
       }
     },
     methods: {
       filterDocuments() {
         // Triggered by search input or category change
         this.currentPage = 1;
       },
       showDetails(doc) {
         this.$router.push(`/details/${doc.id}`);
       },
       async analyzeDocument(doc) {
         try {
           Swal.fire({
             title: 'Analyzing...',
             text: 'Please wait while we analyze the document.',
             allowOutsideClick: false,
             didOpen: () => {
               Swal.showLoading();
             }
           });
           const response = await fetch(`http://localhost:8000/analyze-pdf/${doc.id}?fileName=${encodeURIComponent(doc.filePath)}`);
           if (!response.ok) throw new Error('Erreur lors de l\'analyse');
           const data = await response.json();

           // Enregistrement automatique dans la base .NET
           await fetch('http://localhost:5047/api/Image', {
             method: 'POST',
             headers: { 'Content-Type': 'application/json' },
             body: JSON.stringify({
               DocumentID: doc.id,
               Description: data.description,
               FilePath: data.image_path,
               ExtractedDate: new Date().toISOString()
             })
           });

           Swal.close();
           // Affiche la popup d'information seulement
           Swal.fire({
             title: 'Description générée et enregistrée !',
             html: `
               <b>Description :</b> ${data.description}<br>
               <b>Objets détectés :</b> ${data.objects ? data.objects.join(', ') : ''}<br>
               <b>Texte extrait :</b> ${data.text ? data.text.substring(0, 300) + (data.text.length > 300 ? '...' : '') : ''}
             `,
             icon: 'success'
           });
         } catch (error) {
           Swal.close();
           Swal.fire({
             title: 'Erreur',
             text: error.message,
             icon: 'error'
           });
         }
       },
       updateDocument(doc) {
         this.$router.push(`/update/${doc.id}`);
       },
       async deleteDocument(id) {
         const result = await Swal.fire({
           title: 'Are you sure?',
           text: 'This will permanently delete the document.',
           icon: 'warning',
           showCancelButton: true,
           confirmButtonText: 'Yes, delete it!',
           cancelButtonText: 'Cancel'
         });
         if (result.isConfirmed) {
           try {
             await documentService.deleteDocument(id);
             this.documents = this.documents.filter(doc => doc.id !== id);
             Swal.fire({ icon: 'success', title: 'Deleted!', text: 'Document has been deleted.' });
           } catch (error) {
             Swal.fire({ icon: 'error', title: 'Error', text: 'Failed to delete document.' });
           }
         }
       },
       toggleSortOrder() {
         this.sortOrder = this.sortOrder === 'desc' ? 'asc' : 'desc';
       },
       async downloadDocument(documentId) {
         try {
           const response = await documentService.downloadDocument(documentId);
           // Create a blob and trigger download
           const url = window.URL.createObjectURL(new Blob([response.data]));
           const link = document.createElement('a');
           link.href = url;
           link.setAttribute('download', `document_${documentId}.pdf`); // or use the real filename if available
           document.body.appendChild(link);
           link.click();
           document.body.removeChild(link);
           window.URL.revokeObjectURL(url);
         } catch (error) {
           Swal.fire({ icon: 'error', title: 'Error', text: 'Failed to download document.' });
         }
       },
       async previewDocument(documentId) {
         try {
           const response = await documentService.downloadDocument(documentId);
           const file = new Blob([response.data], { type: 'application/pdf' });
           const fileURL = URL.createObjectURL(file);
           window.open(fileURL);
         } catch (error) {
           Swal.fire({ icon: 'error', title: 'Error', text: 'Failed to preview document.' });
         }
       },
       goToPage(page) {
         if (page >= 1 && page <= this.totalPages) {
           this.currentPage = page;
         }
       },
       nextPage() {
         if (this.currentPage < this.totalPages) {
           this.currentPage++;
         }
       },
       prevPage() {
         if (this.currentPage > 1) {
           this.currentPage--;
         }
       }
     }
   };
   </script>

   <style scoped>
   .document-card {
     background-color: #F8FAFC; /* Off-White */
     padding: 1.5rem;
     border-radius: 10px;
     box-shadow: 0 0 15px rgba(0, 0, 0, 0.1);
     transition: transform 0.3s ease;
   }
   .document-card:hover {
     transform: translateY(-5px);
   }
   .document-card .btn-primary {
     background-color: #0ea2bd; /* Deep Teal */
     border-color: #0ea2bd;
   }
   .document-card .btn-primary:hover {
     background-color: #71d1e2; /* Coral */
     border-color: #71d1e2;
   }
   .document-card .btn-secondary {
     background-color: #4A5568; /* Slate Gray */
     border-color: #4A5568;
   }
   .document-card .btn-secondary:hover {
     background-color: #71d1e2; /* Coral */
     border-color: #71d1e2;
   }
   .document-card img {
     width: 100%;
     height: auto;
     border-radius: 8px;
     margin-bottom: 1rem;
   }
   .add-document-btn {
     background-color: #0ea2bd; /* Deep Teal */
     border-color: #0ea2bd;
     color: #fff;
     border-radius: 50px;
     padding: 0.5rem 1.5rem;
     transition: background-color 0.3s ease, transform 0.2s ease;
   }
   .add-document-btn:hover {
     background-color: #71d1e2; /* Coral */
     border-color: #71d1e2;
     transform: scale(1.05);
   }
   .search-bar {
     position: relative;
   }
   .search-bar .form-control {
     border-radius: 50px;
     padding-right: 2.5rem;
     border: 1px solid #0ea2bd; /* Deep Teal */
     background-color: #F8FAFC; /* Off-White */
     color: #2D3748; /* Dark Gray */
     transition: border-color 0.3s ease, box-shadow 0.3s ease;
   }
   .search-bar .form-control:focus {
     border-color: #0ea2bd;
     box-shadow: 0 0 0 0.2rem rgba(14, 162, 189, 0.25);
   }
   .search-bar .search-icon {
     position: absolute;
     right: 10px;
     top: 50%;
     transform: translateY(-50%);
     color: #0ea2bd;
     cursor: pointer;
     transition: color 0.3s ease;
   }
   .search-bar .search-icon:hover {
     color: #71d1e2; /* Coral */
   }
   .filter-dropdown .form-select {
     border-radius: 50px;
     border: 1px solid #0ea2bd; /* Deep Teal */
     background-color: #F8FAFC; /* Off-White */
     color: #2D3748; /* Dark Gray */
     padding: 0.5rem 1.5rem;
     transition: border-color 0.3s ease, box-shadow 0.3s ease;
   }
   .filter-dropdown .form-select:focus {
     border-color: #0ea2bd;
     box-shadow: 0 0 0 0.2rem rgba(14, 162, 189, 0.25);
   }
   .filter-dropdown .form-select option {
     background-color: #fff;
     color: #2D3748;
   }
   .pagination .page-link {
     color: #0ea2bd; /* Deep Teal */
     transition: background-color 0.3s ease;
   }
   .pagination .page-link:hover {
     background-color: #71d1e2; /* Coral */
     border-color: #71d1e2;
     color: #fff;
   }
   .pagination .page-item.active .page-link {
     background-color: #0ea2bd;
     border-color: #0ea2bd;
     color: #fff;
   }
   .pagination .page-item.disabled .page-link {
     color: #6c757d;
   }
   .document-card .btn {
     min-width: 0;
     white-space: nowrap;
   }
   .document-card .btn i {
     vertical-align: middle;
   }
   .document-actions {
     z-index: 2;
   }
   .icon-btn {
     width: 36px;
     height: 36px;
     display: flex;
     align-items: center;
     justify-content: center;
     border: none;
     border-radius: 50%;
     background: #f1f1f1;
     color: #333;
     font-size: 1.2rem;
     transition: background 0.2s, color 0.2s, box-shadow 0.2s;
     box-shadow: 0 2px 8px rgba(0,0,0,0.06);
     margin-left: 2px;
   }
   .icon-btn:focus {
     outline: none;
   }
   .icon-edit {
     background: #fff;
     color: #0ea2bd;
     border: 1px solid #0ea2bd;
   }
   .icon-edit:hover {
     background:rgb(92, 192, 210);
     color:rgb(249, 250, 250);
   }
   .icon-delete {
     background: #ffeaea;
     color: #d90429;
     border: 1px solid #d90429;
   }
   .icon-delete:hover {
     background: #ff6b6b;
     color: #fff;
   }

   .icon-download {
     background: #fff;
     color: #0ea2bd;
     border: 1px solid #0ea2bd;
   }
   .icon-download:hover {
     background:rgb(92, 192, 210);
     color:rgb(249, 250, 250);
   }
   .sort-btn {
     border-radius: 50px;
     padding: 0.5rem 1.2rem;
     font-weight: 400;
     display: flex;
     align-items: center;
     gap: 0.5rem;
     background-color: #F8FAFC; /* Off-White, same as search/category */
     border: 1px solid #0ea2bd; /* Deep Teal */
     color: #2D3748; /* Dark Gray */
     transition: background 0.2s, color 0.2s, border-color 0.2s;
   }
   .sort-btn:hover, .sort-btn:focus {
     background-color: #e0f7fa;
     color: #0ea2bd;
     border-color: #0ea2bd;
   }
   .sort-btn i {
     font-size: 1.2rem;
     color: #0ea2bd;
   }
   @media (max-width: 767.98px) {
     .row.mb-4.align-items-center.flex-nowrap.g-2 > .col-md-4 {
       margin-bottom: 0.5rem;
     }
   }
   .document-item {
     margin-bottom: 2rem;
   }
   .document-card {
     margin: 0.5rem;
   }
   .document-card iframe,
   .document-card img {
     width: 100%;
     height: 200px;
     object-fit: cover;
     border-radius: 8px;
   }
   .document-card {
     margin: 0;
     padding: 1.5rem;
     border-radius: 10px;
     box-shadow: 0 0 15px rgba(0, 0, 0, 0.1);
     background: #F8FAFC;
     height: 100%;
     display: flex;
     flex-direction: column;
     justify-content: space-between;
   }
   </style>