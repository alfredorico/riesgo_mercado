$(document).ready(function(){

  if($('#rm_analisis_portafolio_tipo_de_gestion').val() == "1" || $('#rm_analisis_portafolio_tipo_de_gestion').val() == "2" || $('#rm_analisis_portafolio_tipo_de_gestion').val() == "3")
  {
    $('#rm_inversion_select').show();
  }

  $('#rm_analisis_portafolio_tipo_de_gestion').change(function(){
        //alert($(this).val());
        if( $(this).val() == "1" || $(this).val() == "2" || $(this).val() == "3")
        {
         $('#rm_inversion_select').fadeIn('slow');
       }
       else
       {
         $('#rm_inversion_select').fadeOut('slow');
       }
     });

}); 