async function addAndRemoveRestriction() {
  try {
    var result = getSelectedRows(false);
    var valueParams = getParams("Restriction");
    var row = [];

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

    console.log("Objeto de parametros: " + param);
    console.log("Parametro de Action: " + valueParams["filterAction"]);

    for (var i = 0; i < result.length; i++) {
      var estrutura = {
        field: [{ fieldName: "NUNOTA", $: result[i].contextoLinha[6] }],
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

    let teste = await acionarBotao(
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

    console.log(teste);
  } catch (error) {
    alert(error);
    throw error;
  }
}

async function addNotaOC(result, numOC) {
  try {
    var row = [];
    param = [
      {
        type: "I",
        paramName: "ORDCARGA",
        $: numOC,
      },
    ];

    for (var i = 0; i < result.length; i++) {
      var estrutura = {
        field: [{ fieldName: "NUNOTA", $: result[i].contextoLinha[6] }],
      };
      row[i] = estrutura;
    }

    let teste = await acionarBotao(
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

    console.log(teste);
  } catch (error) {
    alert(error);
    throw error;
  }
}
