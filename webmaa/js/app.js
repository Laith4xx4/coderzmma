// MAA Web App Logic
document.addEventListener('DOMContentLoaded', () => {
    const navbar = document.getElementById('navbar');
    const sessionCount = document.getElementById('session-count');
    const memberCount = document.getElementById('member-count');
    const coachCount = document.getElementById('coach-count');

    // Scroll Effect
    window.addEventListener('scroll', () => {
        if (window.scrollY > 50) {
            navbar.style.background = 'rgba(0, 0, 0, 0.9)';
            navbar.style.backdropFilter = 'blur(10px)';
        } else {
            navbar.style.background = 'transparent';
            navbar.style.backdropFilter = 'none';
        }
    });

    // --- Session Management ---
    const token = localStorage.getItem('maa_token');
    const user = localStorage.getItem('maa_user');
    const loginBtn = document.querySelector('nav .btn');

    if (token) {
        // Change Login to Profile/Logout
        loginBtn.textContent = (user || 'PROFILE').toUpperCase();
        loginBtn.href = '#';
        loginBtn.addEventListener('click', (e) => {
            e.preventDefault();
            if(confirm('Do you want to logout?')) {
                localStorage.clear();
                window.location.reload();
            }
        });
    }

    // --- Live API Statistics ---
    async function fetchStats() {
        try {
            const response = await fetch('/api/Public/stats');
            if (response.ok) {
                const data = await response.json();
                animateValue(sessionCount, 0, data.sessions, 1500);
                animateValue(memberCount, 0, data.members, 1500);
                animateValue(coachCount, 0, data.coaches, 1500);
            } else {
                throw new Error('API unstable');
            }
        } catch (error) {
            console.error('Stats Sync Error:', error);
            // Elegant fallback
            animateValue(sessionCount, 0, 10, 800);
            animateValue(memberCount, 0, 100, 800);
            animateValue(coachCount, 0, 5, 800);
        }
    }

    function animateValue(obj, start, end, duration) {
        let startTimestamp = null;
        const step = (timestamp) => {
            if (!startTimestamp) startTimestamp = timestamp;
            const progress = Math.min((timestamp - startTimestamp) / duration, 1);
            obj.innerHTML = Math.floor(progress * (end - start) + start);
            if (progress < 1) {
                window.requestAnimationFrame(step);
            }
        };
        window.requestAnimationFrame(step);
    }

    fetchStats();
});
