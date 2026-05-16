const popover = document.getElementById('email-popover');
if (popover) {
  popover.addEventListener('click', function (e) {
    if (e.target === popover) popover.close();
  });

  document.querySelectorAll('[data-email-popover-open]').forEach(function (btn) {
    btn.addEventListener('click', function () { popover.showModal(); });
  });

  document.querySelectorAll('[data-email-popover-close]').forEach(function (btn) {
    btn.addEventListener('click', function () { popover.close(); });
  });
}
