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

    $('.pics_upload').fileupload({
      dataType: 'html',
      autoUpload: true,
      filesContainer: '.upload_files',
      uploadTemplate: function (o) {
        var rows = $();
        $.each(o.files, function (index, file) {
	  var row = $('<p>Загрузка ' + file.name + '...</p>');
	  rows = rows.add(row);
	});
        return rows;
      },
      always: function (e, data) {
        $(data.result).appendTo('#pictures');
      }
    });
});
