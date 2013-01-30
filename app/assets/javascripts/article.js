function feedDataFromUrl() {
  var article_form = $(".js-article-form form");
  $.ajax({
    url: "/articles/feed",
    type: "GET",
    data: article_form.serialize()
  })
}