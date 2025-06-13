<%@ page language="java" contentType="text/html; charset=UTF-8"
pageEncoding="UTF-8" isELIgnored ="false"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@ page import="java.util.*" %> <%@ taglib
uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %> <%@ taglib
uri="http://java.sun.com/jstl/core_rt" prefix="c" %> <%@ taglib prefix="snk"
uri="/WEB-INF/tld/sankhyaUtil.tld" %>
<html>
  <head>
    <title>HTML5 Component</title>
    <link
      rel="stylesheet"
      type="text/css"
      href="${BASE_FOLDER}/css/parceiroCSS.css"
    />
    <link
      href="https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css"
      rel="stylesheet"
    />
    <script defer src="${BASE_FOLDER}/js/main.js"></script>
    <script defer src="${BASE_FOLDER}/js/filter.js"></script>
    <script defer src="${BASE_FOLDER}/js/api.js"></script>

    <script src="https://code.jquery.com/jquery-3.3.1.js"></script>
    <script src="https://cdn.datatables.net/1.10.20/js/jquery.dataTables.min.js"></script>
    <snk:load />
    <!-- essa tag deve ficar nesta posição -->

    <!-- 	<script type='text/javascript'>
		function abrirContatos(codParc){
			var params = {'CODPARC' : codParc};
			refreshDetails('html5_ulnyo6', params);
		}
		
		function abrirFinanceiros(codParc){
			var params = {'CODPARC' : codParc};
			openLevel('lvl_ulnyo9', params);
		}
	</script> -->
  </head>
  <body>
    <snk:query var="parceiros">
      SELECT CODEMP, CIF_FOB, CODEMPSAIDA, NUNOTA, DTNEG, NUMNOTA, NUREM,
      AD_NUMNOTA_REMESSA, CODTIPOPER, NOMECONTATO, UFCONTATO, CIDADECONTATO,
      BAIRROCONTATO, REGIAOCONTATO, CODPARCDEST, NOMEPARCDEST, UFPARCDEST,
      CIDADEPARCDEST, BAIRROPARCDEST, REGIAOPARCDEST, DTPREEMBARQUE, QTDVOL,
      PESOBRUTO, PESO, VLRNOTA, CODPARC, NOMEPARC, OBSPEDIDO, OBSERVACAO,
      PEDIDOCLIENTE, NUNOTAPED, LOCAL FROM (SELECT C.CODEMP, C.CIF_FOB, (CASE
      WHEN NVL(C.NUREM, 0) <> 0 THEN C.CODEMPNEGOC ELSE C.CODEMP END)
      CODEMPSAIDA, C.NUNOTA, C.DTNEG, C.NUMNOTA, C.NUREM, (SELECT C2.NUMNOTA
      FROM TGFCAB C2 WHERE C2.NUNOTA = C.NUREM AND ROWNUM = 1) AS
      AD_NUMNOTA_REMESSA, C.CODTIPOPER, CONTATO.NOMECONTATO AS NOMECONTATO,
      UFCONTATO.DESCRICAO UFCONTATO, CIDADECONTATO.NOMECID CIDADECONTATO,
      BAIRROCONTATO.NOMEBAI BAIRROCONTATO, REGIAOCONTATO.NOMEREG REGIAOCONTATO,
      PARCEIRODESTINO.CODPARC CODPARCDEST, PARCEIRODESTINO.NOMEPARC AS
      NOMEPARCDEST, UFPARCDEST.DESCRICAO UFPARCDEST, CIDADEPARCDEST.NOMECID
      CIDADEPARCDEST, BAIRROPARCDEST.NOMEBAI BAIRROPARCDEST,
      REGIAOPARCDEST.NOMEREG REGIAOPARCDEST, TRUNC((C.AD_PREVENTREGA - 7))
      DTPREEMBARQUE, C.QTDVOL, C.PESOBRUTO, C.PESO, C.VLRNOTA, PARCEIRO.CODPARC
      CODPARC, PARCEIRO.NOMEPARC NOMEPARC, C.AD_OBSERVACAOPEDIDO OBSPEDIDO,
      C.OBSERVACAO, C.NUMPEDIDO2 PEDIDOCLIENTE, (SELECT V.NUNOTAORIG FROM TGFVAR
      V WHERE V.NUNOTA = C.NUNOTA AND ROWNUM = 1) NUNOTAPED, (SELECT
      FU_CONCATENAR_VARCHAR_TBM(DISTINCT L.DESCRLOCAL) FROM TGFITE I, TGFLOC L
      WHERE I.NUNOTA = C.NUNOTA AND L.CODLOCAL = I.CODLOCALORIG AND L.DESCRLOCAL
      <> 'DMP1') LOCAL FROM TGFCAB C LEFT JOIN (SELECT NOMECONTATO, COMPLEMENTO,
      CODPARC, CODCONTATO, CODCID, CODEND, NUMEND, CEP, CODBAI, CODREG FROM
      TGFCTT) CONTATO ON (C.CODPARC = CONTATO.CODPARC AND C.CODCONTATO =
      CONTATO.CODCONTATO) LEFT JOIN (SELECT B.CODREG, B.CODBAI, B.NOMEBAI FROM
      TSIBAI B) BAIRROCONTATO ON (CONTATO.CODBAI = BAIRROCONTATO.CODBAI) LEFT
      JOIN (SELECT CODREG, NOMECID, CODCID, CID.UF FROM TSICID CID)
      CIDADECONTATO ON (CONTATO.CODCID = CIDADECONTATO.CODCID) LEFT JOIN (SELECT
      U.CODUF, U.UF, U.DESCRICAO FROM TSIUFS U) UFCONTATO ON (CIDADECONTATO.UF =
      UFCONTATO.CODUF) LEFT JOIN (SELECT CODREG, NOMEREG FROM TSIREG)
      REGIAOCONTATO ON (CONTATO.CODREG = REGIAOCONTATO.CODREG) LEFT JOIN (SELECT
      CODREG, COMPLEMENTO, NOMEPARC, CODPARC, CODCID, CODEND, NUMEND, CEP,
      CODBAI FROM TGFPAR) PARCEIRO ON (C.CODPARC = PARCEIRO.CODPARC) LEFT JOIN
      (SELECT CODREG, COMPLEMENTO, NOMEPARC, CODPARC, CODCID, CODEND, NUMEND,
      CEP, CODBAI FROM TGFPAR) PARCEIRODESTINO ON (C.CODPARCDEST =
      PARCEIRODESTINO.CODPARC) LEFT JOIN (SELECT B.CODREG, B.CODBAI, B.NOMEBAI
      FROM TSIBAI B) BAIRROPARCDEST ON (PARCEIRODESTINO.CODBAI =
      BAIRROPARCDEST.CODBAI) LEFT JOIN (SELECT CODREG, NOMECID, CODCID, CID.UF
      FROM TSICID CID) CIDADEPARCDEST ON (PARCEIRODESTINO.CODCID =
      CIDADEPARCDEST.CODCID) LEFT JOIN (SELECT U.CODUF, U.UF, U.DESCRICAO FROM
      TSIUFS U) UFPARCDEST ON (CIDADEPARCDEST.UF = UFPARCDEST.CODUF) LEFT JOIN
      (SELECT CODREG, NOMEREG FROM TSIREG) REGIAOPARCDEST ON
      (PARCEIRODESTINO.CODREG = REGIAOPARCDEST.CODREG) WHERE C.CHAVENFE IS NOT
      NULL AND ((TRUNC((C.AD_PREVENTREGA - 7)) IS NULL) OR
      (TRUNC((C.AD_PREVENTREGA - 7)) <= TRUNC(SYSDATE))) AND
      C.AD_TIPRESTRIEMBARQUE IS NULL AND NVL(C.AD_CODUSUPRECARREG, 0) = 0 AND
      NVL(C.ORDEMCARGA, 0) = 0 AND (C.CODTIPOPER IN (701, 702, 706, 707, 716,
      725, 732, 738, 740, 741, 786, 1520) OR (C.CODTIPOPER IN (715, 718) AND
      EXISTS (SELECT 1 FROM TGFCAB CI WHERE CI.NUNOTA = C.NUREM AND
      NVL(CI.ORDEMCARGA, 0) = 0)) OR (C.CODTIPOPER IN (677, 608) AND
      FU_VER_701_PREEMBARQUE_TBM(C.NUNOTA) = 'S')) AND (TO_DATE(C.DTNEG) BETWEEN
      :P_DTNEG.INI AND :P_DTNEG.FIN) AND (C.CIF_FOB IN (:P_TIPOFRETE)) AND
      C.STATUSNOTA = 'L' AND (UFPARCDEST.CODUF IN (:CODUF)) AND
      ((BAIRROPARCDEST.CODBAI = :P_BAIRRO) OR (:P_BAIRRO IS NULL)) AND
      ((CIDADEPARCDEST.CODCID = :P_CID) OR (:P_CID IS NULL)) AND
      ((PARCEIRODESTINO.CODPARC = :P_PARC) OR (:P_PARC IS NULL))) WHERE
      (CODEMPSAIDA IN (:P_CODEMP)) AND (CODTIPOPER IN (:TOP))
    </snk:query>

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

    <dialog id="params" class="dialogParam">
      <div class="boxDialog">
        <div class="form">
          <p class="legenda">
            Preencha o campo abaixo para vincular a uma OC já existente
          </p>
          <div class="campoForm">
            <div>
              <label>Ordem Carga</label>
              <div>
                <input
                  type="number"
                  id="filterOrdem"
                  class="filter"
                  placeholder="cod. ordem carga"
                />
              </div>
            </div>
          </div>
          <p class="legenda">
            Preencha os campos abaixo para gerar uma nova OC
          </p>
          <div class="campoForm">
            <div>
              <label>Região<span class="obrigatorio">*</span></label>
              <div>
                <input
                  id="filterRegiao"
                  class="filter"
                  placeholder="cod. região"
                /><i
                  class="bx bx-search-alt-2"
                  onclick="document.getElementById('regiao').showModal()"
                ></i>
              </div>
            </div>
            <div>
              <label>Veículo<span class="obrigatorio">*</span></label>
              <div>
                <input
                  id="filterVeiculo"
                  class="filter"
                  placeholder="cod. veiculo"
                /><i
                  class="bx bx-search-alt-2"
                  onclick="document.getElementById('veiculo').showModal()"
                ></i>
              </div>
            </div>
          </div>
          <div class="campoForm">
            <div>
              <label>Transportadora<span class="obrigatorio">*</span></label>
              <div>
                <input
                  id="filterTransportadora"
                  class="filter"
                  placeholder="cod. Transportadora"
                />
              </div>
            </div>
            <div>
              <label>Motorista</label>
              <div>
                <input
                  id="filterMotorista"
                  class="filter"
                  placeholder="cod. Motorista"
                /><i
                  class="bx bx-search-alt-2"
                  onclick="document.getElementById('motorista').showModal()"
                ></i>
              </div>
            </div>
          </div>
          <div class="campoForm">
            <div>
              <label>Dt. Prev. Saída<span class="obrigatorio">*</span></label>
              <div>
                <input
                  type="date"
                  id="filterData"
                  class="filter"
                  placeholder="Data"
                />
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
          <div clas="campoForm">
            <div>
              <label>Roteiro</label>
              <div>
                <textarea
                  name="roteiro"
                  id="filterRoteiro"
                  class="filter"
                ></textarea>
              </div>
            </div>
          </div>
        </div>
        <button onclick="document.getElementById('params').close()">
          Cancelar
        </button>
        <button onclick="gerarOrdemCarga()">Confirmar</button>
      </div>
    </dialog>
    <div id="TotalTable" class="totalTable"></div>
    <div class="somatorio">
      <div id="totalPeso" class="somaResult"></div>
      <div class="gerarOC">
        <button
          class="button"
          onclick="document.getElementById('params').showModal()"
        >
          <i class="bx bxs-bolt"> Gerar OC</i>
        </button>
      </div>
    </div>

    <table border="1" id="myTable">
      <thead>
        <tr class="header">
          <th class="column"></th>
          <th class="column">
            Código Empresa
            <div class="filterIcon"><i class="bx bx-filter-alt"></i></div>
            <div class="filterDiv" data-column="2"></div>
          </th>
          <th class="column">
            Cif/Fob
            <div class="filterIcon"><i class="bx bx-filter-alt"></i></div>
            <div class="filterDiv" data-column="3"></div>
          </th>
          <th class="column">
            Empresa de Saida
            <div class="filterIcon"><i class="bx bx-filter-alt"></i></div>
            <div class="filterDiv" data-column="4"></div>
          </th>
          <th class="column">
            Nu. Nota
            <div class="filterIcon"><i class="bx bx-filter-alt"></i></div>
            <div class="filterDiv" data-column="5"></div>
          </th>
          <th class="column">
            Dt. Negociação
            <div class="filterIcon"><i class="bx bx-filter-alt"></i></div>
            <div class="filterDiv" data-column="6"></div>
          </th>
          <th class="column">
            Num. Nota
            <div class="filterIcon"><i class="bx bx-filter-alt"></i></div>
            <div class="filterDiv" data-column="7"></div>
          </th>
          <th class="column">
            Nu. Remessa
            <div class="filterIcon"><i class="bx bx-filter-alt"></i></div>
            <div class="filterDiv" data-column="8"></div>
          </th>
          <th class="column">
            Num. Remessa
            <div class="filterIcon"><i class="bx bx-filter-alt"></i></div>
            <div class="filterDiv" data-column="9"></div>
          </th>
          <th class="column">
            Top
            <div class="filterIcon"><i class="bx bx-filter-alt"></i></div>
            <div class="filterDiv" data-column="10"></div>
          </th>
          <th class="column">
            Nome Contato
            <div class="filterIcon"><i class="bx bx-filter-alt"></i></div>
            <div class="filterDiv" data-column="11"></div>
          </th>
          <th class="column">
            UF Contato
            <div class="filterIcon"><i class="bx bx-filter-alt"></i></div>
            <div class="filterDiv" data-column="12"></div>
          </th>
          <th class="column">
            Cidade Contato
            <div class="filterIcon"><i class="bx bx-filter-alt"></i></div>
            <div class="filterDiv" data-column="13"></div>
          </th>
          <th class="column">
            Bairro Contato
            <div class="filterIcon"><i class="bx bx-filter-alt"></i></div>
            <div class="filterDiv" data-column="14"></div>
          </th>
          <th class="column">
            Região Contato
            <div class="filterIcon"><i class="bx bx-filter-alt"></i></div>
            <div class="filterDiv" data-column="15"></div>
          </th>
          <th class="column">
            Cod. Parceiro Dest.
            <div class="filterIcon"><i class="bx bx-filter-alt"></i></div>
            <div class="filterDiv" data-column="16"></div>
          </th>
          <th class="column">
            Nome Parceiro Dest.
            <div class="filterIcon"><i class="bx bx-filter-alt"></i></div>
            <div class="filterDiv" data-column="17"></div>
          </th>
          <th class="column">
            UF Destino
            <div class="filterIcon"><i class="bx bx-filter-alt"></i></div>
            <div class="filterDiv" data-column="18"></div>
          </th>
          <th class="column">
            Cidade Destino
            <div class="filterIcon"><i class="bx bx-filter-alt"></i></div>
            <div class="filterDiv" data-column="19"></div>
          </th>
          <th class="column">
            Bairro Destino
            <div class="filterIcon"><i class="bx bx-filter-alt"></i></div>
            <div class="filterDiv" data-column="20"></div>
          </th>
          <th class="column">
            Região Destino
            <div class="filterIcon"><i class="bx bx-filter-alt"></i></div>
            <div class="filterDiv" data-column="21"></div>
          </th>
          <th class="column">
            Dt. Pre Embarque
            <div class="filterIcon"><i class="bx bx-filter-alt"></i></div>
            <div class="filterDiv" data-column="22"></div>
          </th>
          <th class="column">
            Qtd. Volume
            <div class="filterIcon"><i class="bx bx-filter-alt"></i></div>
            <div class="filterDiv" data-column="23"></div>
          </th>
          <th class="column">
            Peso Bruto
            <div class="filterIcon"><i class="bx bx-filter-alt"></i></div>
            <div class="filterDiv" data-column="24"></div>
          </th>
          <th class="column">
            Peso Liquido
            <div class="filterIcon"><i class="bx bx-filter-alt"></i></div>
            <div class="filterDiv" data-column="25"></div>
          </th>
          <th class="column">
            Vlr. Nota
            <div class="filterIcon"><i class="bx bx-filter-alt"></i></div>
            <div class="filterDiv" data-column="26"></div>
          </th>
          <th class="column">
            Cod. Parceiro
            <div class="filterIcon"><i class="bx bx-filter-alt"></i></div>
            <div class="filterDiv" data-column="27"></div>
          </th>
          <th class="column">
            Nome Parceiro
            <div class="filterIcon"><i class="bx bx-filter-alt"></i></div>
            <div class="filterDiv" data-column="28"></div>
          </th>
          <th class="column" id="obs">Obs. Pedido</th>
          <th class="column" id="obs">Obs.</th>
          <th class="column">
            Pedido Cliente
            <div class="filterIcon"><i class="bx bx-filter-alt"></i></div>
            <div class="filterDiv" data-column="31"></div>
          </th>
          <th class="column">
            Nu. Pedido
            <div class="filterIcon"><i class="bx bx-filter-alt"></i></div>
            <div class="filterDiv" data-column="32"></div>
          </th>
          <th class="column">
            Local
            <div class="filterIcon"><i class="bx bx-filter-alt"></i></div>
            <div class="filterDiv" data-column="33"></div>
          </th>
        </tr>
      </thead>
      <tbody>
        <c:forEach items="${parceiros.rows}" var="row">
          <tr>
            <td class="linhas">
              <input
                type="checkbox"
                class="select-row"
                onclick="setCalculoPeso()"
              />
            </td>
            <td class="linhas">
              <c:out value="${row.CODEMP}" />
            </td>
            <td class="linhas">
              <c:out value="${row.cif_fob}" />
            </td>
            <td class="linhas">
              <c:out value="${row.CODEMPSAIDA}" />
            </td>
            <td class="linhas">
              <c:out value="${row.Nunota}" />
            </td>
            <td class="linhas">
              <fmt:formatDate value="${row.DTNEG}" pattern="MM/dd/yyyy" />
            </td>
            <td class="linhas">
              <c:out value="${row.NUMNOTA}" />
            </td>
            <td class="linhas">
              <c:out value="${row.NUREM}" />
            </td>
            <td class="linhas">
              <c:out value="${row.AD_NUMNOTA_REMESSA}" />
            </td>
            <td class="linhas">
              <c:out value="${row.codtipoper}" />
            </td>
            <td class="linhas">
              <c:out value="${row.nomecontato}" />
            </td>
            <td class="linhas">
              <c:out value="${row.ufcontato}" />
            </td>
            <td class="linhas">
              <c:out value="${row.cidadecontato}" />
            </td>
            <td class="linhas">
              <c:out value="${row.bairrocontato}" />
            </td>
            <td class="linhas">
              <c:out value="${row.regiaocontato}" />
            </td>
            <td class="linhas">
              <c:out value="${row.codparcdest}" />
            </td>
            <td class="linhas">
              <c:out value="${row.nomeparcdest}" />
            </td>
            <td class="linhas">
              <c:out value="${row.ufparcdest}" />
            </td>
            <td class="linhas">
              <c:out value="${row.cidadeparcdest}" />
            </td>
            <td class="linhas">
              <c:out value="${row.bairroparcdest}" />
            </td>
            <td class="linhas">
              <c:out value="${row.regiaoparcdest}" />
            </td>
            <td class="linhas">
              <c:out value="${row.dtpreembarque}" />
            </td>
            <td class="linhas">
              <fmt:formatNumber
                value="${row.qtdvol}"
                type="number"
                maxFractionDigits="2"
                pattern="##,###.##"
              />
            </td>
            <td class="linhas">
              <fmt:formatNumber
                value="${row.pesobruto}"
                type="number"
                maxFractionDigits="2"
                pattern="##,###.##"
              />
            </td>
            <td class="linhas">
              <fmt:formatNumber
                value="${row.peso}"
                type="number"
                maxFractionDigits="2"
                pattern="##,###.##"
              />
            </td>
            <td class="linhas">
              <fmt:formatNumber value="${row.vlrnota}" type="currency" />
            </td>
            <td class="linhas">
              <c:out value="${row.codparc}" />
            </td>
            <td class="linhas">
              <c:out value="${row.nomeparc}" />
            </td>
            <td class="linhas" id="obs">
              <c:out value="${row.obspedido}" />
            </td>
            <td class="linhas" id="obs">
              <c:out value="${row.observacao}" />
            </td>
            <td class="linhas">
              <c:out value="${row.pedidocliente}" />
            </td>
            <td class="linhas">
              <c:out value="${row.nunotaped}" />
            </td>
            <td class="linhas">
              <c:out value="${row.local}" />
            </td>
          </tr>
        </c:forEach>
      </tbody>
    </table>
    <dialog id="regiao" class="dialogFilt">
      <div class="boxFilt">
        <input
          type="text"
          class="filtro-nome"
          placeholder="Digite para pesquisar..."
        />
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
      <button onclick="document.getElementById('regiao').close()">
        Cancelar
      </button>
      <button onclick="getSelectFilter('regiao','filterRegiao')">
        Confirmar
      </button>
    </dialog>

    <dialog id="veiculo" class="dialogFilt">
      <div class="boxFilt">
        <input
          type="text"
          class="filtro-nome"
          placeholder="Digite para pesquisar..."
        />
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
      <button onclick="document.getElementById('veiculo').close()">
        Cancelar
      </button>
      <button onclick="getSelectFilter('veiculo','filterVeiculo')">
        Confirmar
      </button>
    </dialog>

    <dialog id="motorista" class="dialogFilt">
      <div class="boxFilt">
        <input
          type="text"
          class="filtro-nome"
          placeholder="Digite para pesquisar..."
        />
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
      <button onclick="document.getElementById('motorista').close()">
        Cancelar
      </button>
      <button onclick="getSelectFilter('motorista','filterMotorista')">
        Confirmar
      </button>
    </dialog>

    <!-- <dialog id="dialogReturn">
      <div id="statusMensagem"></div>
      <button onclick="openTela()">
        Abrir OC
      </button>
    </dialog> -->

    <script>
      var table = document.getElementById("myTable");
      var linhas = table
        .getElementsByTagName("tbody")[0]
        .getElementsByTagName("tr");
      var qtdRegistros = document.getElementById("TotalTable");
      qtdRegistros.textContent = "A tabela possui " + linhas.length + " linha(s)";
    </script>
  </body>
</html>
