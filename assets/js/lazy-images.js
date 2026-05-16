document.querySelectorAll('img[loading="lazy"]').forEach(function (img) {
  if (img.complete) {
    img.classList.add('loaded');
  } else {
    img.addEventListener('load', function () { img.classList.add('loaded'); }, { once: true });
    img.addEventListener('error', function () { img.classList.add('loaded'); }, { once: true });
  }
});
