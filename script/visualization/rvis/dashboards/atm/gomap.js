// When locator icon in datatable is clicked, go to that spot on the map
$(document).on("click", ".go-map", function(e) {
  e.preventDefault();
  Shiny.onInputChange("goto", {
    id: $(this).data("id"),
    date: $(this).data("date"),
    ord100: $(this).data("ord100"),
    ord50: $(this).data("ord50"),
    ord20: $(this).data("ord20"),
    piaz: Math.random()
  });
});
