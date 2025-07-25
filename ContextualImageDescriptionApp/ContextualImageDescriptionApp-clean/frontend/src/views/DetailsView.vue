<template>
    <div>
       <Navbar />
       <br>

       <!-- Document Details Section -->
       <section id="document-details" class="services section" style="padding-top: 0%;">
         <div class="container section-title" data-aos="fade-up">
           <h2>Document Details</h2>
           <p>View detailed information and associated images for your document</p>
         </div>
         <div class="container" data-aos="fade-up" data-aos-delay="100">
           <div class="row mb-4 align-items-center">
             <div class="col-md-3 text-center mb-3 mb-md-0">
                 <iframe
  v-if="document.filePath"
  :src="document.filePath"
  width="100%"
  height="200"
  style="border-radius: 8px; border: 1px solid #eee;"
  allowfullscreen
></iframe>
             </div>
             <div class="col-md-9">
               <div class="document-card">
                 <h3 style="color: #0ea2bd;">{{ document.title }}</h3>
                 <p><strong>Category:</strong> {{ document.category }}</p>
                 <p><strong>Uploaded:</strong> {{ document.uploaded }}</p>
                 <p><strong>Description:</strong> {{ document.content }}</p>
               </div>
             </div>
           </div>
           <div class="row mb-4">
             <div class="col-12">
               <h4>Associated Images</h4>
             </div>
           </div>
           <div class="row gy-4">
             <div v-for="(image, index) in document.images" :key="index" class="col-6 col-md-4 col-lg-3">
               <div class="image-card" data-aos="fade-up" :data-aos-delay="100 + index * 100">
                 <img :src="image.src" :alt="image.name" class="img-fluid associated-thumbnail">
                 <h4>{{ image.name }}</h4>
                 <p><strong>Description:</strong> {{ image.description }}</p>
               </div>
             </div>
           </div>
           <br>
           <div class="row mt-4">
             <div class="col-12 text-center">
               <router-link to="/documents" class="btn back-btn">Back to Documents</router-link>
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
   import documentService from '@/api/documentService';
   import Swal from 'sweetalert2';
   import Category from '@/entities/Category';
   import Status from '@/entities/Status';

   export default {
     name: 'Details',
     components: {
       Navbar,
       Footer
     },
     data() {
       return {
         document: {
           id: this.$route.params.id,
           title: '',
           category: '',
           uploaded: '',
           content: '',
           status: '',
           filePath: '', 
           image: '',
           images: []
         }
       };
     },
     
     async created() {
       try {
         const response = await documentService.getDocument(this.$route.params.id);
         const doc = response.data;
         this.document = {
           id: doc.documentID,
           title: doc.title,
           category: Category[doc.category],
           uploaded: doc.uploadDate ? new Date(doc.uploadDate).toLocaleDateString() : '',
           content: doc.content,
           status: Status[doc.status],
           filePath: doc.filePath
             ? `http://localhost:5047/uploads/${doc.filePath.split(/[\\/]/).pop()}`
             : '/assets/img/features-1.svg',
           images: (doc.images || []).map(img => ({
             name: img.filePath ? img.filePath.split(/[\\/]/).pop() : 'Image',
             description: img.description || '',
             src: img.filePath
               ? `http://localhost:5047/uploads/${img.filePath.split(/[\\/]/).pop()}`
               : '/assets/img/features-1.svg'
           }))
         };
       } catch (error) {
         Swal.fire({ icon: 'error', title: 'Error', text: 'Failed to load document details.' });
       }
     }
   };
   </script>

   <style scoped>
   .document-card, .image-card {
     background-color: #F8FAFC; /* Off-White */
     padding: 1.5rem;
     border-radius: 10px;
     box-shadow: 0 0 15px rgba(0, 0, 0, 0.1);
     transition: transform 0.3s ease;
   }
   .document-card:hover, .image-card:hover {
     transform: translateY(-5px);
   }
   .document-card img {
     max-width: 25%;
     height: auto;
     border-radius: 8px;
     margin-bottom: 1rem;
     display: block;
     margin-left: auto;
     margin-right: auto;
   }
   .image-card img {
     width: 100%;
     height: auto;
     border-radius: 8px;
     margin-bottom: 1rem;
   }
   .document-card h3, .image-card h4 {
     color: #2D3748; 
   }
   .document-card p, .image-card p {
     color: #2D3748;
   }
   .document-card .btn-primary {
     background-color: #0ea2bd; 
     border-color: #0ea2bd;
   }
   .document-card .btn-primary:hover {
     background-color: #71d1e2; 
     border-color: #71d1e2;
   }
   .back-btn {
     background-color: #0ea2bd; 
     border-color: #0ea2bd;
     color: #fff;
     border-radius: 50px;
     padding: 0.5rem 1.5rem;
     transition: background-color 0.3s ease, transform 0.2s ease;
   }
   .back-btn:hover {
     background-color: #71d1e2; 
     border-color: #71d1e2;
     transform: scale(1.05);
   }
   .document-card.row {
     padding: 1.5rem;
     border-radius: 10px;
     box-shadow: 0 0 15px rgba(0, 0, 0, 0.1);
     background-color: #F8FAFC;
     margin: 0;
   }
   .document-thumbnail {
     max-width: 120px;
     width: 100%;
     height: auto;
     border-radius: 8px;
     margin-bottom: 1rem;
     display: block;
     margin-left: auto;
     margin-right: auto;
   }
   .document-thumbnail-standalone {
     max-width: 100px;
     width: 100%;
     height: auto;
     border-radius: 8px;
     margin-bottom: 1rem;
     display: block;
     margin-left: auto;
     margin-right: auto;
     box-shadow: 0 0 10px rgba(0,0,0,0.07);
   }
   .associated-thumbnail {
     max-width: 70px;
     width: 100%;
     height: auto;
     border-radius: 6px;
     margin-bottom: 0.5rem;
     display: block;
     margin-left: auto;
     margin-right: auto;
     box-shadow: 0 0 6px rgba(0,0,0,0.06);
   }
   @media (max-width: 767.98px) {
     .document-card.row {
       flex-direction: column;
       text-align: center;
     }
     .document-thumbnail {
       margin-bottom: 1rem;
     }
     .document-thumbnail-standalone {
       margin-bottom: 1rem;
     }
   }
   </style>