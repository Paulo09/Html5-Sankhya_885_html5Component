//Função que realiza o post no Sankhya
async function post(url, corpo, { headers } = { headers: {} }) {
  let tipoCorpoRequisicao = "";
  let isJSON = true;

  if (headers) {
    tipoCorpoRequisicao = headers["Content-Type"]
      ? String(headers["Content-Type"])
      : tipoCorpoRequisicao;
    isJSON =
      tipoCorpoRequisicao.length < 1 || tipoCorpoRequisicao.includes("json");

    headers["Content-Type"] && delete headers["Content-Type"];
    headers["Content-Type"] = !isJSON
      ? tipoCorpoRequisicao
      : "application/json; charset=UTF-8";
  }

  try {
    const resposta = await window.fetch.bind(window)(url, {
      headers,
      method: "POST",
      redirect: "follow",
      body: isJSON ? JSON.stringify(corpo) : corpo,
    });

    return isJSON ? resposta.json() : resposta.text();
  } catch (e) {
    console.error(e);
  }
}

//Função responsável por estruturar os dados para a ação de acionamento remoto
function converterParametro(params, rows) {
  if (params != null) {
    let novosDados = {
      params,
      rows,
    };

    return novosDados;
  } else {
    let novosDados = {
      rows: {
        row: rows,
      },
    };

    return novosDados;
  }
}

// Função responsável por configurar a estrutura da chamada na api
function acionarBotao(
  param,
  dados,
  { tipo, idBotao, entidade, nomeProcedure } = { tipo: "java", idBotao: 0 }
) {
  let nomeServico = "";
  let dadosEnvio = {};

  switch (tipo.toLowerCase()) {
    case "js": {
      nomeServico = "ActionButtonsSP.executeScript";
      dadosEnvio = {
        serviceName: nomeServico,
        requestBody: {
          runScript: {
            actionID: idBotao,
            ...converterParametro(param, dados),
          },
        },
      };
      break;
    }
    case "java": {
      nomeServico = "ActionButtonsSP.executeJava";
      dadosEnvio = {
        serviceName: nomeServico,
        requestBody: {
          javaCall: {
            actionID: idBotao,
            ...converterParametro(param, dados),
          },
        },
      };
      break;
    }
    case "sql": {
      if (!entidade) {
        console.error(
          "Entidade (parametro entidade) é necessária para a execução!"
        );
        return;
      } else if (!nomeProcedure) {
        console.error(
          "Nome da procedure (parametro nomeProcedure) é necessária para a execução!"
        );
        return;
      }

      nomeServico = "ActionButtonsSP.executeSTP";
      dadosEnvio = {
        serviceName: nomeServico,
        requestBody: {
          stpCall: {
            actionID: idBotao,
            rootEntity: entidade,
            procName: nomeProcedure,
            ...converterParametro(param, dados),
          },
        },
      };
      break;
    }
    default:
      break;
  }

  console.log(dadosEnvio);

  const url = `${window.location.origin}/mge/service.sbr?serviceName=${nomeServico}&outputType=json`;

  return post(url, dadosEnvio).then((res) => {
    console.log("Resposta", res);

    var loop = 3;
    var dialog = document.getElementById("params");
    var dialogReturn = document.getElementById("dialogReturn");

    for (var i = 0; i < loop; i++) {
      if (res.statusMessage) {
        // encerrar o dialog dos parametros
        dialog.close();

        // resetar os parametros
        document.getElementById("filterRegiao").value = "";
        document.getElementById("filterVeiculo").value = "";
        document.getElementById("filterTransportadora").value = "";
        document.getElementById("filterMotorista").value = "";
        document.getElementById("filterData").value = "";
        document.getElementById("filterTurno").value = "";
        document.getElementById("filterRoteiro").value = "";

        var dialogIds = ["regiao", "veiculo", "motorista"];
        for (var j = 0; j < dialogIds.length; j++) {
          var dialog = document.getElementById(dialogIds[j]);
          var checkboxes = dialog.getElementsByClassName("select-filter");
          for (var i = 0; i < checkboxes.length; i++) {
            checkboxes[i].checked = false;
          }
        }

        alert(res.statusMessage);

        break;
      }
    }
  });
}