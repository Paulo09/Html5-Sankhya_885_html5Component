<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false" %>
  <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
  <%@ page import="java.util.*" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
      <%@ taglib uri="http://java.sun.com/jstl/core_rt" prefix="c" %>
        <%@ taglib prefix="snk" uri="/WEB-INF/tld/sankhyaUtil.tld" %>
          <%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

            <html>

            <head>
              <title>Pré-Carregamento Embarque *</title>

              <!-- IMPORT JS -->
              <script src="${BASE_FOLDER}/../js/main.js"></script>
              <script src="${BASE_FOLDER}/../js/filter.js"></script>
              <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
              <script>

              </script>

              <!-- IMPORT CSS -->

              <link rel="stylesheet" type="text/css" href="${BASE_FOLDER}/../css/html.css" />

              <link rel="stylesheet" type="text/css" href="${BASE_FOLDER}/../css/table.css" />

              <link rel="stylesheet" type="text/css" href="${BASE_FOLDER}/../css/actions.css" />

              <link rel="stylesheet" type="text/css" href="${BASE_FOLDER}/../css/dialogs.css" />

              <link rel="stylesheet" type="text/css" href="${BASE_FOLDER}/../css/filter.css" />

              <link rel="stylesheet" type="text/css" href="${BASE_FOLDER}/../css/totaleValue.css" />

              <link href="https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css" rel="stylesheet" />
              
              <snk:load />
            </head>

            <body>
              <!-- CONSULTAS -->

              <snk:query var="regiao">
                select reg.codreg, reg.nomereg from tsireg reg where reg.codreg <> 0
              </snk:query>

              <snk:query var="veiculo">
                select VEI.CODVEICULO, VEI.PLACA, VEI.AD_CODPARCTRANSP, VEI.PESOMAX from
                TGFVEI VEI where VEI.CODVEICULO <> 0 AND VEI.AD_CODPARCTRANSP IS NOT NULL
                  AND (VEI.AD_CODPARCTRANSP <> 0 OR VEI.EMPPARC = 'P') ORDER BY
                    VEI.CODVEICULO
              </snk:query>

              <snk:query var="motorista">
                select par.codparc, par.razaosocial from tgfpar par where par.motorista =
                'S'
              </snk:query>

              <!-- Variavel do Parametro Empresa -->

              <c:set var="CODEMPRESA" scope="session" value="${P_CODEMP}" />

              <!-- Cabeçalho da tela -->

              <div id="TotalTable" class="totalTable"></div>
              <div class="somatorio">
                <div id="totalPeso" class="somaResult">
                  <div>Volume: <span id="totalSelVol">0</span></div>
                  <div>Peso B.: <span id="totalSelPB">0,0</span></div>
                  <div>Peso L.: <span id="totalSelPL">0,0</span></div>
                  <div>Vlr. Nota: R$ <span id="totalSelVLR">0,0</span></div>
                </div>
                <div id="totalGeral" class="somaResult">
                  <div>Volume: <span id="totalGerVol">0</span></div>
                  <div>Peso B.: <span id="totalGerPB">0,0</span></div>
                  <div>Peso L.: <span id="totalGerPL">0,0</span></div>
                  <div>Vlr. Nota: R$ <span id="totalGerVLR">0,0</span></div>
                </div>
              </div>

              <div class="floating-btn">
                <div class="options">
                  <div class="option" onclick="document.getElementById('addNotaOC').showModal()">
                    <a>Adicionar nota</a>
                  </div>
                  <div class="option" onclick="document.getElementById('gerarOc').showModal()">
                    <a>Gerar OC</a>
                  </div>
                  <!--Simulador Ordem de Carga -->  
                  <div class="option" onclick="document.getElementById('addNotaOC2').showModal()">
                    <a>Simulador de Frete</a>
                  </div>

                </div>
                <div class="main-btn">
                  <span><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
                      <path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
                    </svg>
                  </span>
                </div>
              </div>

              <!-- Layout TBM -->

              <snk:query var="TBM">
                SELECT * FROM (SELECT (CASE WHEN NVL(C.NUREM, 0) <> 0 THEN C.CODEMPNEGOC
                  ELSE C.CODEMP END) CODEMPSAIDA, C.NUNOTA, C.DTNEG, C.NUMNOTA, (CASE WHEN
                  C.CODTIPOPER = 707 OR C.CODTIPOPER = 738 THEN DECODE((SELECT NUNOTA FROM
                  TGFVAR WHERE NUNOTAORIG = C.NUNOTA AND ROWNUM = 1), NULL, 'S', 'N') ELSE
                  'N' END) faltaNotaRemessa, (SELECT C2.NUMNOTA FROM TGFCAB C2 WHERE
                  C2.NUNOTA = C.NUREM AND ROWNUM = 1) AS AD_NUMNOTA_REMESSA,
                  PARCEIRODESTINO.NOMEPARC AS NOMEPARCDEST, UFPARCDEST.DESCRICAO UFPARCDEST,
                  CIDADEPARCDEST.NOMECID CIDADEPARCDEST, (CASE WHEN AD_PREVENTREGA <> null
                    THEN AD_PREVENTREGA - 7 ELSE AD_PREVENTREGA END) DTPREEMBARQUE, C.QTDVOL,
                    C.PESOBRUTO, C.PESO, C.VLRNOTA, PARCEIRO.NOMEPARC NOMEPARC,
                    C.AD_OBSERVACAOPEDIDO OBSPEDIDO, (SELECT V.NUNOTAORIG FROM TGFVAR V WHERE
                    V.NUNOTA = C.NUNOTA AND ROWNUM = 1) NUNOTAPED, (SELECT
                    FU_CONCATENAR_VARCHAR_TBM(DISTINCT L.DESCRLOCAL) FROM TGFITE I, TGFLOC L
                    WHERE I.NUNOTA = C.NUNOTA AND L.CODLOCAL = I.CODLOCALORIG AND L.DESCRLOCAL
                    <> 'DMP1') LOCAL,
                      CASE 
                      WHEN C.CIF_FOB = 'C' THEN 'CIF'
                      WHEN C.CIF_FOB = 'F' THEN 'FOB'
                      WHEN C.CIF_FOB = 'T' THEN 'TERCEIRO'
                      ELSE 'Desconhecido'
                      END AS FRETE,
                      C.CODTIPOPER,
                      (SELECT FU_IS_MALHA_CRUA_TBM(ITE.CODPROD)
                      FROM TGFITE ITE
                      WHERE ITE.NUNOTA = C.NUNOTA FETCH FIRST 1 ROW ONLY) MALHA,
                      (SELECT FU_IS_FIO_TBM(ITE.CODPROD)
                      FROM TGFITE ITE
                      WHERE ITE.NUNOTA = C.NUNOTA FETCH FIRST 1 ROW ONLY) FIO
                      FROM TGFCAB C LEFT JOIN (SELECT CODREG,
                      COMPLEMENTO, NOMEPARC, CODPARC, CODCID, CODEND, NUMEND, CEP, CODBAI FROM
                      TGFPAR) PARCEIRO ON (C.CODPARC = PARCEIRO.CODPARC) LEFT JOIN (SELECT
                      CODREG, COMPLEMENTO, NOMEPARC, CODPARC, CODPARCMATRIZ, CODCID, CODEND,
                      NUMEND, CEP, CODBAI FROM TGFPAR) PARCEIRODESTINO ON (DECODE(C.CODPARCDEST,
                      0, C.CODPARC, C.CODPARCDEST) = PARCEIRODESTINO.CODPARC) LEFT JOIN (SELECT
                      CODREG, NOMECID, CODCID, CID.UF FROM TSICID CID) CIDADEPARCDEST ON
                      (PARCEIRODESTINO.CODCID = CIDADEPARCDEST.CODCID) LEFT JOIN (SELECT
                      U.CODUF, U.UF, U.DESCRICAO FROM TSIUFS U) UFPARCDEST ON (CIDADEPARCDEST.UF
                      = UFPARCDEST.CODUF) WHERE ((STATUSNOTA = 'L' AND CHAVENFE IS NOT NULL))
                      AND C.AD_TIPRESTRIEMBARQUE IS NULL AND NVL(C.AD_CODUSUPRECARREG, 0) = 0
                      AND NVL(C.ORDEMCARGA, 0) = 0 AND (C.CODTIPOPER IN (702, 706, 707, 716,
                      724, 725, 732, 738, 740, 741, 742, 746, 756, 786, 1513, 1520, 3326,326) OR
                      (C.CODTIPOPER IN (715, 718) AND EXISTS (SELECT 1 FROM TGFCAB CI WHERE
                      CI.NUNOTA = C.NUREM AND NVL(CI.ORDEMCARGA, 0) = 0))) AND (TO_DATE(C.DTNEG)
                      BETWEEN :P_DTNEG.INI AND :P_DTNEG.FIN) AND (C.CIF_FOB IN (:P_TIPOFRETE) OR
                      (:P_TIPOFRETE IS NULL)) AND (UFPARCDEST.CODUF IN (:CODUF) OR (:CODUF IS
                      NULL)) AND ((CIDADEPARCDEST.CODCID = :P_CID) OR (:P_CID IS NULL)) AND
                      ((PARCEIRODESTINO.CODPARC = :P_PARC) OR (:P_PARC IS NULL))
                      AND (
                       ('S' = (:P_INTER))
                        OR ('N' = (:P_INTER) AND PARCEIRODESTINO.CODPARC NOT IN (7, 2909, 6149, 13379, 15984, 16548, 18385)
                        AND PARCEIRO.CODPARC NOT IN (18385)
                        )
                   )
                      ) WHERE (CODEMPSAIDA IN (:P_CODEMP))
                      AND (CODTIPOPER IN (:TOP))
                      AND (:P_ISMALHACRUA IN ('S', 'N') AND MALHA = :P_ISMALHACRUA)
                      AND (:P_ISFIO IN ('S', 'N') AND FIO = :P_ISFIO)
                      ORDER BY
                      NOMEPARCDEST, UFPARCDEST, DTNEG
              </snk:query>

              <table id="myTable">
                <thead>
                  <tr class="header">
                    

                   
                    <th class="column">
                      <input type="checkbox" id="select-all" onclick="toggleSelectAll(this)" />
                      
                    </th>
                    
                    
                    <th class="column">
                      Empresa de Saida
                      <div class="filterIcon"><i class="bx bx-filter-alt"></i></div>
                      <div class="filterDiv" data-column="2"></div>
                    </th>
                    <th class="column">
                      Dt. Negociação
                      <div class="filterIcon"><i class="bx bx-filter-alt"></i></div>
                      <div class="filterDiv" data-column="3"></div>
                    </th>
                    <th class="column">
                      Nu. Nota
                      <div class="filterIcon"><i class="bx bx-filter-alt"></i></div>
                      <div class="filterDiv" data-column="4"></div>
                    </th>
                    <th class="column">
                      Falta Nota Remessa
                      <div class="filterIcon"><i class="bx bx-filter-alt"></i></div>
                      <div class="filterDiv" data-column="5"></div>
                    </th>
                    <th class="column">
                      Dt. Pre Recebimento
                      <div class="filterIcon"><i class="bx bx-filter-alt"></i></div>
                      <div class="filterDiv" data-column="6"></div>
                    </th>
                    <th class="column">
                      Num. Nota
                      <div class="filterIcon"><i class="bx bx-filter-alt"></i></div>
                      <div class="filterDiv" data-column="7"></div>
                    </th>
                    <th class="column">
                      Nome Parceiro
                      <div class="filterIcon"><i class="bx bx-filter-alt"></i></div>
                      <div class="filterDiv" data-column="8"></div>
                    </th>
                    <th class="column">
                      Num. Remessa
                      <div class="filterIcon"><i class="bx bx-filter-alt"></i></div>
                      <div class="filterDiv" data-column="9"></div>
                    </th>
                    <th class="column">
                      Nome Parceiro Dest.
                      <div class="filterIcon"><i class="bx bx-filter-alt"></i></div>
                      <div class="filterDiv" data-column="10"></div>
                    </th>
                    <th class="column">Qtd. Volume</th>
                    <th class="column">Peso Bruto</th>
                    <th class="column">
                      UF Destino
                      <div class="filterIcon"><i class="bx bx-filter-alt"></i></div>
                      <div class="filterDiv" data-column="13"></div>
                    </th>
                    <th class="column">
                      Cidade Destino
                      <div class="filterIcon"><i class="bx bx-filter-alt"></i></div>
                      <div class="filterDiv" data-column="14"></div>
                    </th>
                    <th class="column" id="obs">Obs. Pedido</th>
                    <th class="column">
                      Local
                      <div class="filterIcon"><i class="bx bx-filter-alt"></i></div>
                      <div class="filterDiv" data-column="16"></div>
                    </th>
                    <th class="column">
                      Frete
                      <div class="filterIcon"><i class="bx bx-filter-alt"></i></div>
                      <div class="filterDiv" data-column="17"></div>
                      </th>
                    <th class="column">Peso Liquido</th>
                    <th class="column">Vlr. Nota</th>
                    <th class="column">
                      Produtos
                    </th>
                  </tr>
                </thead>
               <p id="SelectedCount">Linhas selecionadas: 0</p> 
                <tbody>
                  <c:forEach items="${TBM.rows}" var="row">
                    <tr>
                      <td class="linhas" id="check">
                        <input type="checkbox" class="select-row" onclick="setCalculoPeso()" />
                      </td>
                      <td class="linhas" id="codEmp">
                        <c:out value="${row.CODEMPSAIDA}" />
                      </td>
                      <td class="linhas" id="dtNeg">
                        <fmt:formatDate value="${row.DTNEG}" pattern="dd/MM/yyyy" />
                      </td>
                      <td class="linhas" id="nuNota">
                        <c:out value="${row.Nunota}" />
                      </td>
                      <td class="linhas" id="faltaNotaRemessa">
                        <c:out value="${row.faltaNotaRemessa}" />
                      </td>
                      <td class="linhas" id="dtPreEmbarque">
                        <fmt:formatDate value="${row.dtpreembarque}" pattern="dd/MM/yyyy" />
                      </td>
                      <td class="linhas" id="numNota">
                        <c:out value="${row.NUMNOTA}" />
                      </td>
                      <td class="linhas" id="nomeParc">
                        <c:out value="${row.nomeparc}" />
                      </td>
                      <td class="linhas" id="numRemessa">
                        <c:out value="${row.AD_NUMNOTA_REMESSA}" />
                      </td>
                      <td class="linhas" id="nomeParcDest">
                        <c:out value="${row.nomeparcdest}" />
                      </td>
                      <td class="linhas" id="qtdVol">
                        <fmt:formatNumber value="${row.qtdvol}" type="number" maxFractionDigits="2" pattern="##,###.##" />
                      </td>
                      <td class="linhas" id="pesoBruto">
                        <fmt:formatNumber value="${row.pesobruto}" type="number" maxFractionDigits="2" pattern="##,###.##" />
                      </td>
                      <td class="linhas" id="ufDestino">
                        <c:out value="${row.ufparcdest}" />
                      </td>
                      <td class="linhas" id="cidDestino">
                        <c:out value="${row.cidadeparcdest}" />
                      </td>
                      <td class="linhas" id="obsPedido">
                        <c:out value="${row.obspedido}" />
                      </td>
                      <td class="linhas" id="local">
                        <c:out value="${row.local}" />
                      </td>
                      <td class="linhas" id="Frete">
                        <c:out value="${row.Frete}" />
                      </td>

                      <td class="linhas" id="pesoLiquido">
                        <fmt:formatNumber value="${row.peso}" type="number" maxFractionDigits="2" pattern="##,###.##" />
                      </td>
                      <td class="linhas" id="vlrNota">
                        <fmt:formatNumber value="${row.vlrnota}" type="currency" />
                      </td>
                      <td class="linhas">
                        <div style="cursor: pointer;" onclick="preencherInfAdicionais(`${row.Nunota}`)">
                          <button class="btn">Ver Produtos</button>
                        </div>
                      </td>
                    </tr>
                  </c:forEach>
                </tbody>
              </table>

              <!-- Dialog das Informações Adicionais -->

              <dialog id="infAdicionais" class="dialog">
                <div class="container-dialog">
                  <div class="header-dialog">
                    <div class="title-dialog">
                      <h3>Informações Adicionais</h3>
                    </div>
                    <div class="close-dialog" onclick="document.getElementById('infAdicionais').close()">
                      <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M6 18 18 6M6 6l12 12" />
                      </svg>
                    </div>
                  </div>
                  <div class="body-dialog">
                    <table id="tabelaProdutos">
                      <thead>
                        <tr class="header">
                          <th class="column">
                            Produto
                          </th>
                          <th class="column">
                            Descr. Comercial
                          </th>
                        </tr>
                      </thead>
                      <tbody>
                      </tbody>
                    </table>
                  </div>
                </div>
              </dialog>

              <!-- Dialog dos buttons -->

              <dialog id="gerarOc" class="dialog gerarOC">
                <div class="container-dialog">
                  <div class="form-dialog">
                    <div class="header-dialog">
                      <div class="title-dialog">
                        <h3>Gerar Ordem Carga</h3>
                      </div>
                      <div class="close-dialog" onclick="document.getElementById('gerarOc').close()">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
                          <path stroke-linecap="round" stroke-linejoin="round" d="M6 18 18 6M6 6l12 12" />
                        </svg>
                      </div>
                    </div>
                    <div class="body-dialog">
                      <div class="campoForm">
                        <div>
                          <label>Região<span class="obrigatorio">*</span></label>
                          <div>
                            <input id="filterRegiao" class="filter" placeholder="cod. Região" /><i class="bx bx-search-alt-2" onclick="document.getElementById('regiao').showModal()"></i>
                          </div>
                        </div>
                        <div>
                          <label>Veículo<span class="obrigatorio">*</span></label>
                          <div>
                            <input id="filterVeiculo" class="filter" placeholder="cod. Veiculo" /><i class="bx bx-search-alt-2" onclick="document.getElementById('veiculo').showModal()"></i>
                          </div>
                        </div>
                      </div>
                      <div class="campoForm">
                        <div>
                          <label>Transportadora<span class="obrigatorio">*</span></label>
                          <div>
                            <input id="filterTransportadora" class="filter" placeholder="cod. Transportadora" />
                          </div>
                        </div>
                        <div>
                          <label>Motorista</label>
                          <div>
                            <input id="filterMotorista" class="filter" placeholder="cod. Motorista" /><i class="bx bx-search-alt-2" onclick="document.getElementById('motorista').showModal()"></i>
                          </div>
                        </div>
                      </div>
                      <div class="campoForm">
                        <div>
                          <label>Dt. Prev. Saída<span class="obrigatorio">*</span></label>
                          <div>
                            <input type="date" id="filterData" class="filter" placeholder="Data" />
                          </div>
                        </div>
                        <div>
                          <label>Turno</label>
                          <div>
                            <select name="turno" id="filterTurno" class="filter">
                              <option value="" selected>Selecionar turno...</option>
                              <option value="Manhã">Manhã</option>
                              <option value="Tarde">Tarde</option>
                            </select>
                          </div>
                        </div>
                      </div>
                      <div class="campoForm" id="textArea">
                        <div>
                          <label>Roteiro</label>
                          <div>
                            <textarea name="roteiro" id="filterRoteiro" class="filter"></textarea>
                          </div>
                        </div>
                      </div>
                    </div>
                    <div class="footer-dialog">
                      <button class="btn clean" onclick="cleanParam('gerarOc')">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
                          <path stroke-linecap="round" stroke-linejoin="round" d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 0 0-7.5 0" />
                        </svg>

                        Limpar
                      </button>
                      <button class="btn confirm" onclick="createOrdenCarga()">
                        Confirmar
                      </button>
                    </div>
                  </div>
                </div>
              </dialog>

              <dialog id="addNotaOC" class="dialog addNotaOC">
                <div class="container-dialog">
                  <div class="form-dialog">
                    <div class="header-dialog">
                      <div class="title-dialog">
                        <h3>Adicionar nota a uma OC</h3>
                      </div>
                      <div class="close-dialog" onclick="document.getElementById('addNotaOC').close()">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
                          <path stroke-linecap="round" stroke-linejoin="round" d="M6 18 18 6M6 6l12 12" />
                        </svg>
                      </div>
                    </div>
                    <div class="body-dialog">
                      <div class="campoForm">
                        <div>
                          <label>Ordem Carga</label>
                          <div>
                            <input type="number" id="filterOrdem" class="filter" placeholder="cod. ordem carga" />
                          </div>
                        </div>
                      </div>
                    </div>
                    <div class="footer-dialog">
                      <button class="btn clean" onclick="cleanParam('addNotaOC')">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
                          <path stroke-linecap="round" stroke-linejoin="round" d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 0 0-7.5 0" />
                        </svg>

                        Limpar
                      </button>
                      <button class="btn confirm" onclick="addNotaOC()">Confirmar</button>
                    </div>
                  </div>
                </div>
              </dialog>


              <!--------       Inicio @Paulo - Estudo Comportamento     ----------->


              <dialog id="addNotaOC2" class="dialog addNotaOC">
                <div class="container-dialog">
                  <div class="form-dialog">
                    <div class="header-dialog">
                      <div class="title-dialog">
                        <h3>Consultar Cep</h3>
                      </div>
                      <div class="close-dialog" onclick="document.getElementById('addNotaOC').close()">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
                          <path stroke-linecap="round" stroke-linejoin="round" d="M6 18 18 6M6 6l12 12" />
                        </svg>
                      </div>
                    </div>
                    <div class="body-dialog">
                      <div class="campoForm">
                        <div>
                          <label>Ordem Carga</label>
                          <div>
                            <input type="number" id="filterOrdem" class="filter" placeholder="cod. ordem carga" />
                          </div>
                        </div>
                      </div>
                    </div>
                    <div class="footer-dialog">
                      <button class="btn clean" onclick="cleanParam('addNotaOC')">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
                          <path stroke-linecap="round" stroke-linejoin="round" d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 0 0-7.5 0" />
                        </svg>

                        Limpar
                      </button>
                      <button class="btn confirm" onclick="mensagem()">Confirmar</button>
                    </div>
                  </div>
                </div>
              </dialog>

              <!------------------ Fim   ---------------------------->

              <dialog id="Restriction" class="dialog Restriction">
                <div class="container-dialog">
                  <div class="form-dialog">
                    <div class="header-dialog">
                      <div class="title-dialog">
                        <h3>Adição/Remoção de Restrição</h3>
                      </div>
                      <div class="close-dialog" onclick="document.getElementById('Restriction').close()">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
                          <path stroke-linecap="round" stroke-linejoin="round" d="M6 18 18 6M6 6l12 12" />
                        </svg>
                      </div>
                    </div>
                    <div class="body-dialog">
                      <div class="campoForm">
                        <div>
                          <label>O que deseja fazer?</label>
                          <div>
                            <select name="turno" id="filterAction" class="filter">
                              <option value="" selected>Selecione uma ação</option>
                              <option value="ADD">Adicionar Restrição</option>
                              <option value="REMOVE">Remover Restrição</option>
                            </select>
                          </div>
                        </div>
                      </div>
                      <div class="campoForm" id="textArea">
                        <div>
                          <label>Observação da Restrição</label>
                          <div>
                            <textarea name="roteiro" id="filterObsRestriction" class="filter"></textarea>
                          </div>
                        </div>
                      </div>
                    </div>
                    <div class="footer-dialog">
                      <button class="btn clean" onclick="cleanParam('Restriction')">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
                          <path stroke-linecap="round" stroke-linejoin="round" d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 0 0-7.5 0" />
                        </svg>

                        Limpar
                      </button>
                      <button class="btn confirm" onclick="addAndRemoveRestriction()">
                        Confirmar
                      </button>
                    </div>
                  </div>
                </div>
              </dialog>

              <!-- Dialogs dos Parâmetros -->

              <dialog id="regiao" class="dialog filter">
                <div class="container-dialog">
                  <div class="form-dialog">
                    <div class="header-dialog">
                      <div class="title-dialog">
                        <h3>Selecione uma Região</h3>
                      </div>
                      <div class="close-dialog" onclick="document.getElementById('regiao').close()">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
                          <path stroke-linecap="round" stroke-linejoin="round" d="M6 18 18 6M6 6l12 12" />
                        </svg>
                      </div>
                    </div>
                    <div class="body-dialog filter">
                      <div class="campoForm">
                        <div>
                          <label>Pesquisar:</label>
                          <div>
                            <input type="text" class="filtro-nome" placeholder="Digite para pesquisar..." />
                          </div>
                        </div>
                      </div>
                      <table class="lista">
                        <thead>
                          <tr>
                            <th></th>
                            <th>Cod. Região</th>
                            <th>Nome Região</th>
                          </tr>
                        </thead>
                        <tbody>
                          <c:forEach items="${regiao.rows}" var="row">
                            <tr>
                              <td><input type="checkbox" class="select-filter" /></td>
                              <td>
                                <c:out value="${row.codreg}" />
                              </td>
                              <td>
                                <c:out value="${row.nomereg}" />
                              </td>
                            </tr>
                          </c:forEach>
                        </tbody>
                      </table>
                    </div>
                    <div class="footer-dialog">
                      <button class="btn confirm filter" onclick="getSelectFilter('regiao','filterRegiao')">
                        Confirmar
                      </button>
                    </div>
                  </div>
                </div>
              </dialog>

              <dialog id="veiculo" class="dialog filter">
                <div class="container-dialog">
                  <div class="form-dialog">
                    <div class="header-dialog">
                      <div class="title-dialog">
                        <h3>Selecione um Veículo</h3>
                      </div>
                      <div class="close-dialog" onclick="document.getElementById('veiculo').close()">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
                          <path stroke-linecap="round" stroke-linejoin="round" d="M6 18 18 6M6 6l12 12" />
                        </svg>
                      </div>
                    </div>
                    <div class="body-dialog filter">
                      <div class="campoForm">
                        <div>
                          <label>Pesquisar:</label>
                          <div>
                            <input type="text" class="filtro-nome" placeholder="Digite para pesquisar..." />
                          </div>
                        </div>
                      </div>
                      <table class="lista">
                        <thead>
                          <tr>
                            <th></th>
                            <th>Cod. Veiculo</th>
                            <th>Placa</th>
                            <th>Transportadora</th>
                            <th>Peso Máximo</th>
                          </tr>
                        </thead>
                        <tbody>
                          <c:forEach items="${veiculo.rows}" var="row">
                            <tr>
                              <td><input type="checkbox" class="select-filter" /></td>
                              <td>
                                <c:out value="${row.CODVEICULO}" />
                              </td>
                              <td>
                                <c:out value="${row.PLACA}" />
                              </td>
                              <td>
                                <c:out value="${row.AD_CODPARCTRANSP}" />
                              </td>
                              <td>
                                <c:out value="${row.PESOMAX}" />
                              </td>
                            </tr>
                          </c:forEach>
                        </tbody>
                      </table>
                    </div>
                    <div class="footer-dialog">
                      <button class="btn confirm filter" onclick="getSelectFilter('veiculo','filterVeiculo')">
                        Confirmar
                      </button>
                    </div>
                  </div>
                </div>
              </dialog>

              <dialog id="motorista" class="dialog filter">
                <div class="container-dialog">
                  <div class="form-dialog">
                    <div class="header-dialog">
                      <div class="title-dialog">
                        <h3>Selecione um Motorista</h3>
                      </div>
                      <div class="close-dialog" onclick="document.getElementById('motorista').close()">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
                          <path stroke-linecap="round" stroke-linejoin="round" d="M6 18 18 6M6 6l12 12" />
                        </svg>
                      </div>
                    </div>
                    <div class="body-dialog filter">
                      <div class="campoForm">
                        <div>
                          <label>Pesquisar:</label>
                          <div>
                            <input type="text" class="filtro-nome" placeholder="Digite para pesquisar..." />
                          </div>
                        </div>
                      </div>
                      <table class="lista">
                        <thead>
                          <tr>
                            <th></th>
                            <th>Cod. Motorista</th>
                            <th>Razão Social</th>
                          </tr>
                        </thead>
                        <tbody>
                          <c:forEach items="${motorista.rows}" var="row">
                            <tr>
                              <td><input type="checkbox" class="select-filter" /></td>
                              <td>
                                <c:out value="${row.codparc}" />
                              </td>
                              <td>
                                <c:out value="${row.razaosocial}" />
                              </td>
                            </tr>
                          </c:forEach>
                        </tbody>
                      </table>
                    </div>
                    <div class="footer-dialog">
                      <button class="btn confirm filter" onclick="getSelectFilter('motorista','filterMotorista')">
                        Confirmar
                      </button>
                    </div>
                  </div>
                </div>
              </dialog>

              <!-- JS -->

              <script>
                var table = document.getElementById("myTable");
                var linhas = table
                  .getElementsByTagName("tbody")[0]
                  .getElementsByTagName("tr");
                var qtdRegistros = document.getElementById("TotalTable");
                qtdRegistros.textContent = "A tabela possui " + linhas.length + " linha(s)";
      
                const floatingBtn = document.querySelector(".floating-btn");
              
                floatingBtn.addEventListener("click", () => {
                  floatingBtn.classList.toggle("active");
                });
              
                document.addEventListener("click", (e) => {
                  if (!floatingBtn.contains(e.target)) {
                    floatingBtn.classList.remove("active");
                  }
                });
              
                callFilterColumn();
              
                createSearchFilter();
              
                document.addEventListener("DOMContentLoaded", function () {
                  var checkboxes = document.querySelectorAll(
                    'td[class="linhas"] input[type="checkbox"]'
                  );
              
                  checkboxes.forEach(function (checkbox) {
                    checkbox.addEventListener("click", function () {
                      var tr = this.closest("tr");
                      if (tr.classList.contains("active")) {
                        tr.classList.remove("active");
                      } else {
                        tr.classList.add("active");
                      }
                      updateSelectedCount(); // Chama a função para atualizar a contagem
                    });
                  });
                });
              
                const valueIcon = document.querySelector(".bx.bx-chevron-down");
                valueIcon.addEventListener("click", () => {
                  valueIcon.classList.toggle("bx-rotate-180");
                });
              
                document.addEventListener("click", (e) => {
                  if (!valueIcon.contains(e.target)) {
                    valueIcon.classList.remove("bx-rotate-180");
                  }
                });
              
                function toggleSelectAll(checkbox) {
                  // Seleciona todas as caixas de seleção dentro da tabela
                  const checkboxes = document.querySelectorAll('#myTable .select-row');
                  
                  checkboxes.forEach((cb) => {
                    // Define o estado do checkbox de acordo com o principal
                    cb.checked = checkbox.checked;
              
                    // Adiciona ou remove a classe `active` na linha correspondente
                    const tr = cb.closest("tr");
                    if (checkbox.checked) {
                      tr.classList.add("active");
                    } else {
                      tr.classList.remove("active");
                    }
                  });
              
                  updateSelectedCount(); // Atualiza a contagem após selecionar/desmarcar tudo

                                  // Chamar setCalculoPeso para cada checkbox marcado
                              checkboxes.forEach(checkbox => {
                        if (checkbox.checked) {
                            setCalculoPeso(checkbox.value); // Passe o valor ou outro parâmetro necessário

                          }  else {
                                  // Limpa o peso para os checkboxes desmarcados
                                  setCalculoPeso(null, checkbox.value);
                                              }
                        
                        
                    });

                    // Caso também deseje desmarcar, pode-se adicionar lógica para isso
                    if (!selectAllCheckbox.checked) {
                        setCalculoPeso(null); // Exemplo para resetar valores
                    }
                }
                
              
                // Função para atualizar a contagem das linhas selecionadas
                function updateSelectedCount() {
                  var selectedRows = document.querySelectorAll('tr.active'); // Seleciona as linhas ativas
                  var count = selectedRows.length; // Conta as linhas ativas
                  var selectedCountDisplay = document.getElementById("SelectedCount");
                  selectedCountDisplay.textContent = "Linhas selecionadas: " + count; // Exibe o contador
                }
              </script>

                <style>
                  /* CSS atualizado para alinhar o elemento */
                  #SelectedCount {
                    border-radius: 0 2px 20px 0;
                    border: none;
                    background-color: #255073;
                    width: 14vw;
                    padding: 6px 26px;
                    margin: 1vh 0 0 0; /* Define a margem superior */
                    font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto,
                      Oxygen, Ubuntu, Cantarell, "Open Sans", "Helvetica Neue", sans-serif;
                    font-weight: unset;
                    color: #fff;
                  }
                </style>



              
            </body>

            </html>