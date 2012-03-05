// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).ready(function(){
    $('#folder_election_id').change(function(){
      election = $(this).val();
      if (election == '') {
        $('#folder_commission_id')
	.html('<option value="">Не указаны выборы</option>');
      } else {
        $.get('/elections/' + election + '/region_list', function(data) {
	  $('#folder_commission_id').html(data);
	});
      }
    });

    $('.pics_upload').fileUploadUI({
      uploadTable: $('.upload_files'),
      buildUploadRow: function (files, index) {
        i = $('.pics_upload').data('filecount');
        return $('<tr><td>' + files[i++].name + '<\/td>' +
	  '<td class="file_upload_progress"><div><\/div><\/td>' +
	  '<td class="file_upload_cancel">' +
	  '<button class="ui-state-default ui-corner-all" title="Cancel">' +
	  '<img src="/assets/cancel.png"/>' +
	  '<\/button><\/td><\/tr>');
      },
      downloadTable: $('#pictures'),
      buildDownloadRow: function (file) {
        return $('<div id="picture_'+file.id+'" class="picture">'+
	  '<a href="'+file.url+'"><img src="'+file.preview_url+'"/></a>'+
	  '<a rel="nofollow" data-remote="true" data-method="delete" data-confirm="Удалить цифровую копию?" href="'+file.delete_url+'"><i class="icon-remove"></i></a></div>');
      },
      sequentialUploads: true,
      onChange: function (event) {
        $('.pics_upload').data('filecount', 0);
      }
    });
});
