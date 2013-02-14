function showAndUpdateForm(env,comment,changeset) {
  var div = '#' + env + '_deployment_form';
  var form = '#' + env + '_actual_form';
  $(div).show();
  $(form + " #deployment_object_comment").val(comment);
  $(form + " #deployment_object_changeset_id").val(changeset);
}

function clearAndHideForm(env) {
  var div = '#' + env + '_deployment_form';
  var form = '#' + env + '_actual_form';
  $(div).hide();
  $(form + " #deployment_object_comment").reset();
  $(form + " #deployment_object_changeset_id").reset();
}
