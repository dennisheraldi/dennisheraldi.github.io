// Mobile menu functionality
function setupMobileMenu() {
  const menuBtn = document.getElementById("mobile-menu-btn");
  const menu = document.getElementById("mobile-menu");

  menuBtn?.addEventListener("click", () => {
    menu?.classList.toggle("hidden");
    menuBtn?.classList.toggle("hamburger-active");
  });

  // Close menu when clicking a link
  menu?.querySelectorAll("a").forEach((link) => {
    link.addEventListener("click", () => {
      menu.classList.add("hidden");
      menuBtn?.classList.remove("hamburger-active");
    });
  });
}

// Initialize
document.addEventListener("DOMContentLoaded", () => {
  setupMobileMenu();
});

