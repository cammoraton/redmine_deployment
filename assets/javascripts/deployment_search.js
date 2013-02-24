function updateDeploySearch(url) {
  $.ajax({
    url: url,
    type: 'post',
    data: $('#search-results').serialize()
  });
}
