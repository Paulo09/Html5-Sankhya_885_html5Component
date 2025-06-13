// MAIN - FUNÇÕES NATIVAS DE TELA

// Função auxiliar para iterar sobre elementos


function mensagem(){
  alert("Calculo do Frete Acao!!!");
}

function iterateElements(elements, callback) {
  return Array.from(elements).map(callback);
}

function getSelectedRows(off) {
  var checkboxes = document.querySelectorAll("#myTable .select-row");
  var contextoTabela = iterateElements(checkboxes, function (checkbox) {
    if (checkbox.disabled || !checkbox.checked) return null;

    var tds = checkbox.parentNode.parentNode.getElementsByTagName("td");
    var contextoLinha = {};
    iterateElements(tds, function (td) {
      contextoLinha[td.id] = td.textContent.replace(/\n/g, "").trim();
    });

    if (
      off == true &&
      (contextoLinha["restriction"] == "NÃO" || !contextoLinha["restriction"])
    ) {
      checkbox.disabled = true;
    }

    // Adicione as células restriction e obsRestriction diretamente ao objeto contextoLinha
    contextoLinha["restrictionCell"] = tds[13];
    contextoLinha["obsRestrictionCell"] = tds[14];

    return contextoLinha;
  }).filter(Boolean);

  console.log("Dados das linhas selecionadas: ", contextoTabela);
  return contextoTabela;
}

// Função para puxar todos os valores passados nos parametros com tratamento de data
function getParams(idDialog) {
  try {
    const dialog = document.getElementById(idDialog);
    const inputs = dialog.querySelectorAll("input, select, textarea");
    const params = Array.from(inputs).reduce((acc, input) => {
      let value;
      if (input.tagName === "INPUT" && input.type === "date") {
        const [year, month, day] = input.value.split("-");
        value = `${day}/${month}/${year}`;
      } else {
        value = input.value;
      }
      return { ...acc, [input.id]: value };
    }, {});
    console.log("Parametros passados: ", params);
    return params;
  } catch (error) {
    alert(error);
    throw error;
  }
}

//Função para calcular determinada coluna das linhas com o checkbox selecionado
function setCalculoPeso() {
  var table = document.getElementById("myTable");
  var rows = table.getElementsByTagName("tr");

  var totalSelVolume = 0;
  var totalSelPesoBruto = 0;
  var totalSelPesoLiquido = 0;
  var totalSelValorNota = 0;

  var totalGerVolume = 0;
  var totalGerPesoBruto = 0;
  var totalGerPesoLiquido = 0;
  var totalGerValorNota = 0;

  for (var i = 1; i < rows.length; i++) {
    var row = rows[i];

    var volume = Number(
      row
        .querySelector("#qtdVol")
        .textContent.replace(".", "")
        .replace(",", ".")
    );
    var pesoB = Number(
      row
        .querySelector("#pesoBruto")
        .textContent.replace(".", "")
        .replace(",", ".")
    );
    var pesoL = Number(
      row
        .querySelector("#pesoLiquido")
        .textContent.replace(".", "")
        .replace(",", ".")
    );
    var valorNota = Number(
      row
        .querySelector("#vlrNota")
        .textContent.replace("R$", "")
        .trim()
        .replace(".", "")
        .replace(",", ".")
    );

    totalGerVolume += volume;
    totalGerPesoBruto += pesoB;
    totalGerPesoLiquido += pesoL;
    totalGerValorNota += valorNota;

    var checkbox = row.getElementsByClassName("select-row")[0];
    if (checkbox.checked) {
      totalSelVolume += volume;
      totalSelPesoBruto += pesoB;
      totalSelPesoLiquido += pesoL;
      totalSelValorNota += valorNota;
    }
  }

  document.getElementById("totalSelVol").textContent = totalSelVolume
    .toFixed(2)
    .replace(".", ",")
    .replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1.");
  document.getElementById("totalSelPB").textContent = totalSelPesoBruto
    .toFixed(2)
    .replace(".", ",")
    .replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1.");
  document.getElementById("totalSelPL").textContent = totalSelPesoLiquido
    .toFixed(2)
    .replace(".", ",")
    .replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1.");
  document.getElementById("totalSelVLR").textContent = totalSelValorNota
    .toFixed(2)
    .replace(".", ",")
    .replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1.");

  document.getElementById("totalGerVol").textContent = totalGerVolume
    .toFixed(2)
    .replace(".", ",")
    .replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1.");
  document.getElementById("totalGerPB").textContent = totalGerPesoBruto
    .toFixed(2)
    .replace(".", ",")
    .replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1.");
  document.getElementById("totalGerPL").textContent = totalGerPesoLiquido
    .toFixed(2)
    .replace(".", ",")
    .replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1.");
  document.getElementById("totalGerVLR").textContent = totalGerValorNota
    .toFixed(2)
    .replace(".", ",")
    .replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1.");
}

function cleanParam(idDialog) {
  var dialog = document.getElementById(idDialog);
  var inputs = dialog.querySelectorAll("input, select, textarea");
  inputs.forEach(function (input) {
    input.value = "";
  });
}

// ACTION - FUNÇÕES DAS AÇÕES

async function addAndRemoveRestriction() {
  try {
    var button = document.querySelector(".btn.confirm");
    button.disabled = true;
    button.innerHTML = "Carregando...";
    button.classList.add("loading");

    var row = [];
    var result = getSelectedRows(false);
    var valueParams = getParams("Restriction");

    if (valueParams["filterAction"]) {
      param = [
        {
          type: "S",
          paramName: "TIPACTION",
          $: valueParams["filterAction"],
        },
      ];

      // recebendo parametros não obrigatórios
      if (valueParams["filterObsRestriction"]) {
        obs = {
          type: "S",
          paramName: "OBSRESTRICTION",
          $: valueParams["filterObsRestriction"],
        };

        param.push(obs);
      }

      for (var i = 0; i < result.length; i++) {
        var estrutura = {
          field: [{ fieldName: "NUNOTA", $: result[i]["nuNota"] }],
        };
        row[i] = estrutura;

        // Atualize o valor da célula de restrição
        result[i].restrictionCell.textContent =
          valueParams["filterAction"] === "ADD" ? "SIM" : "NÃO";

        if (result[i].obsRestrictionCell) {
          result[i].obsRestrictionCell.textContent =
            valueParams["filterAction"] === "ADD"
              ? valueParams["filterObsRestriction"]
              : "";
        } else {
          console.log("obsRestrictionCell is undefined");
        }
      }

      await acionarBotao(
        {
          param,
        },
        {
          row: row,
        },
        {
          tipo: "sql",
          idBotao: 596, //PROD: 596 // Homologacao: 586
          entidade: "AD_RESTRPRECARG",
          nomeProcedure: "ADD_REMOVE_RESTRICAO_OC_TBM",
        }
      );
    } else {
      alert("Verifique se o campo obrigatório foi preenchido corretamente");
    }
  } catch (error) {
    alert(error);
    throw error;
  } finally {
    button.innerHTML = "Confirmar";
    button.classList.remove("loading");
    button.disabled = false;
  }
}

async function addNotaOC() {
  try {
    var row = [];
    var valueParams = getParams("addNotaOC");
    var resultSelect = getSelectedRows(true);

    if (valueParams["filterOrdem"]) {
      param = [
        {
          type: "I",
          paramName: "ORDCARGA",
          $: valueParams["filterOrdem"],
        },
      ];

      for (var i = 0; i < resultSelect.length; i++) {
        var estrutura = {
          field: [{ fieldName: "NUNOTA", $: resultSelect[i]["nuNota"] }],
        };
        row[i] = estrutura;
      }

      await acionarBotao(
        {
          param,
        },
        {
          row: row,
        },
        {
          tipo: "sql",
          idBotao: 601, // Homologacao: 588 // 601 Producao
          entidade: "CabecalhoNota",
          nomeProcedure: "STP_ADIC_NOTA_ORD_TBM",
        }
      );
    } else {
      alert("Verifique se o campo obrigatório foi preenchido corretamente");
    }
  } catch (error) {
    alert(error);
    throw error;
  }
}

async function createOrdenCarga() {
  try {
    var button = document.querySelector(".btn.confirm");
    button.disabled = true;
    button.innerHTML = "";
    button.classList.add("loading");

    var row = [];
    var valueParams = getParams("gerarOc");
    var resultSelect = getSelectedRows(true);

    if (
      valueParams["filterRegiao"] &&
      valueParams["filterTransportadora"] &&
      valueParams["filterVeiculo"] &&
      valueParams["filterData"]
    ) {
      param = [
        {
          type: "S",
          paramName: "REGIAO",
          $: valueParams["filterRegiao"],
        },
        {
          type: "S",
          paramName: "PARCTRANSPORT",
          $: valueParams["filterTransportadora"],
        },
        {
          type: "S",
          paramName: "VEICULO",
          $: valueParams["filterVeiculo"],
        },
        {
          type: "D",
          paramName: "DTPREVSAIDA",
          $: valueParams["filterData"],
        },
      ];

      if (valueParams["filterMotorista"]) {
        var motorista = {
          type: "S",
          paramName: "PARCMOTOR",
          $: valueParams["filterMotorista"],
        };

        param.push(motorista);
      }

      if (valueParams["filterRoteiro"]) {
        var roteiro = {
          type: "S",
          paramName: "ROTEIRO",
          $: valueParams["filterRoteiro"],
        };

        param.push(roteiro);
      }

      if (valueParams["filterTurno"]) {
        var turno = {
          type: "S",
          paramName: "TURNO",
          $: valueParams["filterTurno"],
        };

        param.push(turno);
      }

      for (var i = 0; i < resultSelect.length; i++) {
        if (resultSelect[i]) {
          if (resultSelect[i]["restriction"] != "SIM") {
            var estrutura = {
              field: [
                {
                  fieldName: "CODEMP",
                  $: resultSelect[i]["codEmp"],
                },
                {
                  fieldName: "NUNOTA",
                  $: resultSelect[i]["nuNota"],
                },
              ],
            };

            row[i] = estrutura;
          } else {
            alert("A nota " + resultSelect[i]["nuNota"] + " possui restrição!");
            break;
          }
        } else {
          alert("Verifique se selecionou a linha corretamente.");
          break;
        }
      }

      action = await acionarBotao(
        {
          param,
        },
        {
          row,
        },
        {
          tipo: "java",
          idBotao: 498,
        }
      );
    } else {
      alert("Preencha os parametros: Região, Transportadora, Veiculo, Data");
    }
  } catch (error) {
    alert(error);
    throw error;
  } finally {
    button.innerHTML = "Confirmar";
    button.classList.remove("loading");
    button.disabled = false;
  }
}

// API - FUNÇÕES SANKHYA

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
    var dialog = document.getElementById("gerarOc");
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

function preencherInfAdicionais(event) {
  document.getElementById("infAdicionais").showModal();

  //Metodo para execução de queries via JavaScript
  //executeQuery(query:String, parameters:Array, onSuccess:Function, onError:Function)
  executeQuery(
    "SELECT PRO.CODPROD, PRO.AD_DESCR_COMERCIAL FROM TGFITE ITE INNER JOIN TGFPRO PRO ON ITE.CODPROD = PRO.CODPROD WHERE ITE.NUNOTA = " +
      event,
    [],
    (retorno) => {
      var dadosTabela = JSON.parse(retorno);

      // Seleciona o corpo da tabela
      var tabela = document
        .getElementById("tabelaProdutos")
        .getElementsByTagName("tbody")[0];

      // Limpa qualquer conteúdo existente no corpo da tabela
      tabela.innerHTML = "";

      // Itera sobre os dados e cria as linhas
      dadosTabela.forEach((item) => {
        // Cria uma nova linha
        var row = tabela.insertRow();

        // Insere as células
        var cellCodProd = row.insertCell(0);
        var cellDescrComercial = row.insertCell(1);

        // Adiciona classes nas células (td)
        cellCodProd.classList.add("linhas");
        cellDescrComercial.classList.add("linhas");

        // Adiciona os valores nas células
        cellCodProd.textContent = item.CODPROD;
        cellDescrComercial.textContent = item.AD_DESCR_COMERCIAL;
      });
    },
    (response) => {
      alert("Erro: " + response);
    }
  );
}
