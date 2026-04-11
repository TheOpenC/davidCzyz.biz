// Lazy load videos on scroll using IntersectionObserver
const videos = document.querySelectorAll('video.graphic');

const observer = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    const video = entry.target;
    if (entry.isIntersecting) {
      if (!video.src) {
        video.src = video.dataset.src;
      }
      video.play();
      observer.unobserve(video);
    }
  });
}, {
  rootMargin: '200px',
  threshold: 0
});

videos.forEach(video => {
  video.dataset.src = video.src;
  video.removeAttribute('src');
  observer.observe(video);
});