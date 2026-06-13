import "./styles.css";

// Stamp the current year into the footer.
const year = document.getElementById("year");
if (year) year.textContent = String(new Date().getFullYear());
