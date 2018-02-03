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

   $(".atualiza_usuario").submit(function(ev){
   	ev.preventDefault();

   	var data = $(this).serialize();
   	var method = $(this).attr("method");
   	var action = $(this).attr("action");
   	$.API.ajax(action, method, data, 'json', function(retorno){
   		if(retorno.status === "Error"){
	   		$("#msg_atualiza").text(retorno.message);
	   		$(".msg_sucesso_atualiza").hide();
	   		$(".msg_erro_atualiza").show();
	   	}
	   	else if(retorno.status = "Success"){
	   		$("#msg_atualiza_2").text(retorno.message);
	   		$(".msg_erro_atualiza").hide();
	   		$(".msg_sucesso_atualiza").show();
	   	}
   	}, 
   	function(xhr,status,error){
   		 $("#msg_atualiza").text(error);
   		$(".msg_sucesso_atualiza").hide();
   		$(".msg_erro_atualiza").show();
   	});
   });

   $("#envia_termos").submit(function(ev){
   	swal({
	  title: 'Aguarde...',
	  text: 'Buscando dados do servidor!',
	  onOpen: () => {
	    swal.showLoading();
	    $("#nlk-search-submit").prop("disabled", true);
	  }
	}).then((result) => {
	})
   });
});