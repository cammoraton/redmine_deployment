function updateTaskFrom(url) {
  $.ajax({
    url: url,
    type: 'post',
    data: $('#deployment_task-form').serialize()
  });
}
