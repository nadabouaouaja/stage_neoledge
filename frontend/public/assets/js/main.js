/**
      * Template Name: HeroBiz
      * Template URL: https://bootstrapmade.com/herobiz-bootstrap-business-template/
      * Updated: Aug 07 2024 with Bootstrap v5.3.3
      * Author: BootstrapMade.com
      * License: https://bootstrapmade.com/license/
      */
     (function () {
       "use strict";

       /**
        * Initialize when Vue.js app is mounted
        */
       function initWhenReady() {
         if (!document.querySelector('#app')) {
           setTimeout(initWhenReady, 100);
           return;
         }

         /**
          * Apply .scrolled class to body for sticky header
          */
         const selectBody = document.querySelector('body');
         const selectHeader = document.querySelector('#header');
         function toggleScrolled() {
           if (selectHeader && selectBody &&
               (selectHeader.classList.contains('scroll-up-sticky') ||
                selectHeader.classList.contains('sticky-top') ||
                selectHeader.classList.contains('fixed-top'))) {
             window.scrollY > 100 ? selectBody.classList.add('scrolled') : selectBody.classList.remove('scrolled');
           }
         }
         if (selectHeader && selectBody) {
           document.addEventListener('scroll', toggleScrolled);
           window.addEventListener('load', toggleScrolled);
         }

         /**
          * Mobile nav toggle
          */
         const mobileNavToggleBtn = document.querySelector('.mobile-nav-toggle');
         if (mobileNavToggleBtn) {
           mobileNavToggleBtn.addEventListener('click', () => {
             if (selectBody) {
               selectBody.classList.toggle('mobile-nav-active');
               mobileNavToggleBtn.classList.toggle('bi-list');
               mobileNavToggleBtn.classList.toggle('bi-x');
             }
           });
         }

         /**
          * Hide mobile nav on same-page/hash links or router-links
          */
         const navmenuLinks = document.querySelectorAll('#navmenu a, #navmenu router-link');
         navmenuLinks.forEach(navmenu => {
           navmenu.addEventListener('click', () => {
             if (selectBody && selectBody.classList.contains('mobile-nav-active')) {
               selectBody.classList.remove('mobile-nav-active');
               if (mobileNavToggleBtn) {
                 mobileNavToggleBtn.classList.add('bi-list');
                 mobileNavToggleBtn.classList.remove('bi-x');
               }
             }
           });
         });

         /**
          * Scroll top button
          */
         const scrollTop = document.querySelector('#scroll-top');
         if (scrollTop) {
           function toggleScrollTop() {
             window.scrollY > 100 ? scrollTop.classList.add('active') : scrollTop.classList.remove('active');
           }
           scrollTop.addEventListener('click', (e) => {
             e.preventDefault();
             window.scrollTo({
               top: 0,
               behavior: 'smooth'
             });
           });
           window.addEventListener('load', toggleScrollTop);
           document.addEventListener('scroll', toggleScrollTop);
         }

         /**
          * Animation on scroll (AOS) initialization
          */
         if (typeof AOS !== 'undefined') {
           AOS.init({
             duration: 600,
             easing: 'ease-in-out',
             once: true,
             mirror: false
           });
         }
       }

       // Run initialization when DOM is ready
       document.addEventListener('DOMContentLoaded', initWhenReady);
     })();