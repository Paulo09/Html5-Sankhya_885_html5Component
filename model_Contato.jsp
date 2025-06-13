<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="UTF-8" isELIgnored ="false"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@ page import="java.util.*" %>
<%@ taglib uri="http://java.sun.com/jstl/core_rt" prefix="c" %>
<%@ taglib prefix="snk" uri="/WEB-INF/tld/sankhyaUtil.tld" %>
<html>
<head>
	<title>HTML5 Component</title>
	<link rel="stylesheet" type="text/css" href="${BASE_FOLDER}/css/contatoCSS.css">
	<script defer src="${BASE_FOLDER}/js/main.js"></script>
	<script src="https://cdn.jsdelivr.net/gh/wansleynery/SankhyaJX/jx.min.js"></script>
	<snk:load/> <!-- essa tag deve ficar nesta posição -->
</head>
<body>

	<!-- <snk:query var="contatos">
		<%
			String query = "select * from TGFCTT where ";
			
			if(request.getAttribute("CODPARC") != null) {
				query += " CODPARC = :CODPARC ";
			} else {
				query += " 1 <> 1 ";
			}

			query += " order by CODPARC asc ";

			out.println(query);
		%>
	</snk:query> -->
	
	<snk:query var="embarcados">
		select C.CODEMP,
			(CASE
				WHEN NVL(C.NUREM, 0) <> 0 THEN
				C.CODEMPNEGOC
				ELSE
				C.CODEMP
			END) CODEMPSAIDA,
			c.Nunota,
			c.DTNEG,
			c.NUMNOTA,
			c.NUREM,
			(SELECT C2.NUMNOTA
				FROM TGFCAB C2
				WHERE C2.NUNOTA = C.NUREM
				AND ROWNUM = 1) AS AD_NUMNOTA_REMESSA,
			c.codtipoper,
			Contato.NOMECONTATO AS nomecontato,
			UfContato.Descricao ufcontato,
			CidadeContato.Nomecid cidadecontato,
			BairroContato.nomebai bairrocontato,
			RegiaoContato.Nomereg regiaocontato,
			ParceiroDestino.Codparc codparcdest,
			ParceiroDestino.NOMEPARC AS nomeparcdest,
			UfParcDest.Descricao ufparcdest,
			CidadeParcDest.Nomecid cidadeparcdest,
			BairroParcDest.nomebai bairroparcdest,
			RegiaoParcDest.Nomereg regiaoparcdest,
			TRUNC((c.AD_PREVENTREGA - 7)) dtpreembarque,
			c.qtdvol,
			c.pesobruto,
			c.peso,
			c.vlrnota,
			Parceiro.Codparc codparc,
			Parceiro.Nomeparc nomeparc,
			c.ad_observacaopedido obspedido,
			c.observacao,
			c.numpedido2 pedidocliente,
			(SELECT v.nunotaorig
				FROM TGFVAR v
				WHERE v.nunota = c.nunota
				AND rownum = 1) nunotaped,
			(SELECT fu_concatenar_varchar_tbm(DISTINCT l.descrlocal)
				FROM TGFITE i, TGFLOC l
				WHERE i.nunota = c.nunota
				AND l.codlocal = i.codlocalorig
				AND l.descrlocal <> 'DMP1') local
		FROM TGFCAB c
		left join (SELECT NOMECONTATO,
							COMPLEMENTO,
							CODPARC,
							CODCONTATO,
							CODCID,
							CODEND,
							NUMEND,
							CEP,
							CODBAI,
							CODREG
					FROM TGFCTT) Contato
			ON (c.CODPARC = Contato.CODPARC AND c.CODCONTATO = Contato.CODCONTATO)
		left join (SELECT b.CODREG, b.CODBAI, b.nomebai FROM TSIBAI b) BairroContato
			ON (Contato.CODBAI = BairroContato.CODBAI)
		left join (SELECT CODREG, NOMECID, CODCID, cid.uf FROM TSICID cid) CidadeContato
			ON (Contato.CODCID = CidadeContato.CODCID)
		left join (SELECT u.coduf, u.uf, u.descricao FROM TSIUFS u) UfContato
			ON (CidadeContato.uf = UfContato.coduf)
		left join (SELECT CODREG, NOMEREG FROM TSIREG) RegiaoContato
			ON (Contato.CODREG = RegiaoContato.CODREG)
		left join (SELECT CODREG,
							COMPLEMENTO,
							NOMEPARC,
							CODPARC,
							CODCID,
							CODEND,
							NUMEND,
							CEP,
							CODBAI
					FROM TGFPAR) Parceiro
			ON (c.CODPARC = Parceiro.CODPARC)
		left join (SELECT CODREG,
							COMPLEMENTO,
							NOMEPARC,
							CODPARC,
							CODCID,
							CODEND,
							NUMEND,
							CEP,
							CODBAI
					FROM TGFPAR) ParceiroDestino
			ON (c.CODPARCDEST = ParceiroDestino.CODPARC)
		left join (SELECT b.CODREG, b.CODBAI, b.nomebai FROM TSIBAI b) BairroParcDest
			ON (ParceiroDestino.CODBAI = BairroParcDest.CODBAI)
		left join (SELECT CODREG, NOMECID, CODCID, cid.uf FROM TSICID cid) CidadeParcDest
			ON (ParceiroDestino.CODCID = CidadeParcDest.CODCID)
		left join (SELECT u.coduf, u.uf, u.descricao FROM TSIUFS u) UfParcDest
			ON (CidadeParcDest.uf = UfParcDest.coduf)
		left join (SELECT CODREG, NOMEREG FROM TSIREG) RegiaoParcDest
			ON (ParceiroDestino.CODREG = RegiaoParcDest.CODREG)
		WHERE c.STATUSNOTA = 'L'
		AND c.ORDEMCARGA IS NULL
		AND (c.cif_fob in (:P_TIPOFRETE))
		AND C.AD_CODUSUPRECARREG IS NOT NULL
		AND (C.AD_CODUSUPRECARREG IN (:P_USO))
		AND (C.CODEMP IN (:P_CODEMP))
		AND (C.CODTIPOPER IN
			(701, 702, 706, 707, 716, 725, 732, 738, 740, 741, 786) OR
			(C.CODTIPOPER IN (715, 718) AND EXISTS
				(SELECT 1
					FROM TGFCAB CI
				WHERE CI.NUNOTA = C.NUREM
					AND NVL(CI.ORDEMCARGA, 0) = 0)))
		AND C.ad_tiprestriembarque IS NULL
		AND (TO_DATE(C.DTNEG) BETWEEN :P_DTNEG.INI AND :P_DTNEG.FIN)
		AND ((TRUNC((c.AD_PREVENTREGA - 7)) IS NULL) OR
			(TRUNC((c.AD_PREVENTREGA - 7)) <= TRUNC(sysdate)))
		AND c.CHAVENFE IS NOT NULL
	</snk:query>

	<table border="1" >
		<caption>Embarcados</caption>
		<tr>
			<th>Código Empresa</th>
			<th>Empresa de Saida</th>
			<th>Nu. Nota</th>
			<th>Dt. Negociação</th>
			<th>Num. Nota</th>
			<th>Nu. Remessa</th>
			<th>Num. Remessa</th>
			<th>Top</th>
			<th>Nome Contato</th>
			<th>UF Contato</th>
			<th>Cidade Contato</th>
			<th>Bairro Contato</th>
			<th>Região Contato</th>
			<th>Cod. Parceiro Dest.</th>
			<th>Nome Parceiro Dest.</th>
			<th>UF Destino</th>
			<th>Cidade Destino</th>
			<th>Bairro Destino</th>
			<th>Região Destino</th>
			<th>Dt. Pre Embarque</th>
			<th>Qtd. Volume</th>
			<th>Peso Bruto</th>
			<th>Peso Liquido</th>
			<th>Vlr. Nota</th>
			<th>Cod. Parceiro</th>
			<th>Nome Parceiro</th>
			<th>Obs. Pedido</th>
			<th>Obs.</th>
			<th>Pedido Cliente</th>
			<th>Nu. Pedido</th>
			<th>Local</th>
		</tr>
		<c:forEach items="${embarcados.rows}" var="row">
			<tr>
				<td >
					<c:out value="${row.CODEMP}" />
				</td>
				<td >
					<c:out value="${row.CODEMPSAIDA}" />
				</td>
				<td ondblclick="desfazerPreEmbarque(this)">
					<c:out value="${row.Nunota}" />
				</td>
				<td >
					<c:out value="${row.DTNEG}" />
				</td>
				<td >
					<c:out value="${row.NUMNOTA}" />
				</td>
				<td >
					<c:out value="${row.NUREM}" />
				</td>
				<td >
					<c:out value="${row.AD_NUMNOTA_REMESSA}" />
				</td>
				<td >
					<c:out value="${row.codtipoper}" />
				</td>
				<td >
					<c:out value="${row.nomecontato}" />
				</td>
				<td >
					<c:out value="${row.ufcontato}" />
				</td>
				<td >
					<c:out value="${row.cidadecontato}" />
				</td>
				<td >
					<c:out value="${row.bairrocontato}" />
				</td>
				<td >
					<c:out value="${row.regiaocontato}" />
				</td>
				<td >
					<c:out value="${row.codparcdest}" />
				</td>
				<td >
					<c:out value="${row.nomeparcdest}" />
				</td>
				<td >
					<c:out value="${row.ufparcdest}" />
				</td>
				<td >
					<c:out value="${row.cidadeparcdest}" />
				</td>
				<td >
					<c:out value="${row.bairroparcdest}" />
				</td>
				<td >
					<c:out value="${row.regiaoparcdest}" />
				</td>
				<td >
					<c:out value="${row.dtpreembarque}" />
				</td>
				<td >
					<c:out value="${row.qtdvol}" />
				</td>
				<td >
					<c:out value="${row.pesobruto}" />
				</td>
				<td >
					<c:out value="${row.peso}" />
				</td>
				<td >
					<c:out value="${row.vlrnota}" />
				</td>
				<td >
					<c:out value="${row.codparc}" />
				</td>
				<td >
					<c:out value="${row.nomeparc}" />
				</td>
				<td >
					<c:out value="${row.obspedido}" />
				</td>
				<td >
					<c:out value="${row.observacao}" />
				</td>
				<td >
					<c:out value="${row.pedidocliente}" />
				</td>
				<td >
					<c:out value="${row.nunotaped}" />
				</td>
				<td >
					<c:out value="${row.local}" />
				</td>
			</tr>
		</c:forEach>
	</table>
</body>
</html>