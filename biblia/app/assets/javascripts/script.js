$.API = {};


$.API = {
	ajax: function(action, method, data, tipo, sucesso, erro){
		$.ajax({
		 	url: action,
		 	type: method,
		 	data: data,
		 	datatype: tipo,
		 	success: sucesso,
		 	error: erro
		});
	}
}




$(document).ready(function(){
   $(".cadastra_usuario").submit(function(ev){
   	ev.preventDefault();
   	var data = $(this).serialize();
   	var method = $(this).attr("method");
   	var action = $(this).attr("action");
   	$.API.ajax(action, method, data, 'json', function(retorno){
   		if(retorno.status === "Error"){
	   		$("#msg_cadastro").text(retorno.message);
	   		$(".msg_sucesso_cadastro").hide();
	   		$(".msg_erro_cadastro").show();
	   	}
	   	else if(retorno.status = "Success"){
	   		$("#msg_cadastro_2").text(retorno.message);
	   		$(".msg_erro_cadastro").hide();
	   		$(".msg_sucesso_cadastro").show();
	   	}
   	}, 
   	function(xhr,status,error){
   		$("#msg_cadastro").text(error);
   		$(".msg_sucesso_cadastro").hide();
   		$(".msg_erro_cadastro").show();
   	});
   });
});