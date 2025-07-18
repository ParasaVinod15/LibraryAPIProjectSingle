document.addEventListener("DOMContentLoaded", function () {
  const filterBy = document.getElementById('filter-by');
  if (!filterBy) return;

  filterBy.addEventListener('change', function () {
    const value = filterBy.value;

    document.getElementById('isbn-filter').style.display = value === 'isbn' ? 'block' : 'none';
    document.getElementById('author-filter').style.display = value === 'author' ? 'block' : 'none';
    document.getElementById('type-filter').style.display = value === 'book_type' ? 'block' : 'none';
  });
});
