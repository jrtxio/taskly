/**
 * Taskly - Apple Style Interactions
 */

document.addEventListener('DOMContentLoaded', () => {
    initSmoothScrolling();
    initScrollAnimations();
    initLanguageSwitcher();
});

// Smooth scrolling
function initSmoothScrolling() {
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            const targetId = this.getAttribute('href');
            if (targetId === '#' || targetId === '#lang-toggle') return; // Ignore toggle

            e.preventDefault();
            const targetElement = document.querySelector(targetId);
            if (targetElement) {
                const headerOffset = 60;
                const elementPosition = targetElement.getBoundingClientRect().top;
                const offsetPosition = elementPosition + window.pageYOffset - headerOffset;

                window.scrollTo({
                    top: offsetPosition,
                    behavior: 'smooth'
                });
            }
        });
    });
}

// Simple Intersection Observer for scroll animations
function initScrollAnimations() {
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0)';
                observer.unobserve(entry.target);
            }
        });
    }, { threshold: 0.1 });

    // Animate Bento cards and texts
    const elements = document.querySelectorAll('.bento-card, .hero h1, .hero p, .section-title, .section-subtitle');

    elements.forEach(el => {
        el.style.opacity = '0';
        el.style.transform = 'translateY(20px)';
        el.style.transition = 'opacity 0.8s cubic-bezier(0.2, 0.8, 0.2, 1), transform 0.8s cubic-bezier(0.2, 0.8, 0.2, 1)';
        observer.observe(el);
    });
}

// Language Switcher
const translations = {
    en: 'English',
    zh: '简体中文'
};

function initLanguageSwitcher() {
    // Check browser language or saved state
    const savedLang = localStorage.getItem('taskly_lang');
    const browserLang = navigator.language.startsWith('zh') ? 'zh' : 'en';
    let currentLang = savedLang || browserLang;

    console.log('Taskly: Initializing language:', currentLang);
    setLanguage(currentLang);
}

window.setLanguage = function (lang) {
    console.log('Taskly: Setting language to:', lang);
    localStorage.setItem('taskly_lang', lang);
    document.documentElement.lang = lang;

    // Update text content
    const elementsToTranslate = document.querySelectorAll('[data-en], [data-zh]');
    elementsToTranslate.forEach(el => {
        const text = el.getAttribute('data-' + lang);
        if (text) {
            // Use innerHTML instead of innerText if the attribute contains HTML (like icons)
            // But for most elements here, text is safer.
            // If it's a link or button, we might want to preserve nested elements?
            // Actually, in our index.html, translatable elements are mostly just text.
            el.innerText = text;
        }
    });

    // Update Label
    const currentLangLabel = document.getElementById('current-lang-label');
    if (currentLangLabel && translations[lang]) {
        currentLangLabel.innerText = translations[lang];
    }
}
