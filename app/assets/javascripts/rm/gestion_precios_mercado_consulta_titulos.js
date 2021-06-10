$(function() {
  $("#consulta_titulo_precios_mercado_rango_de_fechas").hide();
  $('#gestion_precios_mercado_consulta_precios_tipo_consulta_precios_consulta_fecha_especifica').click(function(){
    $("#consulta_titulo_precios_mercado_rango_de_fechas").hide();    
    $("#consulta_titulo_precios_mercado_fecha_especifica").fadeIn();
  });
  $('#gestion_precios_mercado_consulta_precios_tipo_consulta_precios_consulta_rango_de_fechas').click(function(){
    $("#consulta_titulo_precios_mercado_fecha_especifica").hide();
    $("#consulta_titulo_precios_mercado_rango_de_fechas").fadeIn();    
  });  
  $("input[name='gestion_precios_mercado_consulta_precios[tipo_consulta_precios]']:checked").trigger('click');
  $('#resultado_consulta_precios_mercado').DataTable(datatable_opciones({"dom": 'flrti<"bottom"p>',
                                                                         "order": [0, 'desc'],
                                                                         "pageLength": 25,
                                                                         "lengthMenu": [[25, 50, 100, 150, -1], [25, 50, 100, 150, "Todos"]]
                                                                        }));

});
