// Função auxiliar para iterar sobre elementos
function iterateElements(elements, callback) {
  return Array.from(elements).map(callback);
}

// Tratar caracteres especiais antes da criação de filtros
function cssEscape(value) {
  if (value && typeof CSS !== 'undefined' && CSS.escape) {
    return CSS.escape(value);
  }
  return value.replace(/[!"#$%&'()*+,.\/:;<=>?@[\\\]^`{|}~]/g, "\\$&");
}

function callFilterColumn() {
  // Adiciona um ouvinte de evento a cada ícone para mostrar o filtro correspondente quando clicado
  const filterIcons = document.querySelectorAll(".filterIcon");
  const filterDivs = document.querySelectorAll(".filterDiv");

  iterateElements(filterIcons, (filterIcon, index) => {
    filterIcon.addEventListener("click", function (event) {
      event.stopPropagation();
      const filterDiv = filterDivs[index];
      filterDiv.style.display =
        filterDiv.style.display === "none" ? "block" : "none";
    });
  });

  // Impede que cliques nos filtros se propaguem ao documento
  iterateElements(filterDivs, (filterDiv) => {
    filterDiv.addEventListener("click", (event) => event.stopPropagation());
  });

  // Fecha os filtros ao clicar fora deles
  document.addEventListener("click", () => {
    iterateElements(filterDivs, (filterDiv) => {
      filterDiv.style.display = "none";
    });
  });

  // Cria os filtros ao carregar a página
  window.addEventListener("load", criarFiltros);
}

// Função para criar os filtros
function criarFiltros() {
  const rows = document.querySelectorAll("#myTable tr");
  const uniqueValues = [];

  iterateElements(rows, (row, rowIndex) => {
    if (rowIndex > 0) {
      iterateElements(row.querySelectorAll("td"), (cell, cellIndex) => {
        const value = cell.textContent.trim();
        if (!uniqueValues[cellIndex]) uniqueValues[cellIndex] = new Set();
        uniqueValues[cellIndex].add(value);
      });
    }
  });

  uniqueValues.forEach((values, cellIndex) => {
    const filterDiv = document.querySelector(`.filterDiv[data-column='${cellIndex + 1}']`);
    if (filterDiv) {
      values.forEach((value) => {
        const escapedValue = cssEscape(value);
        if (!filterDiv.querySelector(`input[value='${escapedValue}']`)) {
          const checkbox = document.createElement("input");
          checkbox.type = "checkbox";
          checkbox.value = value;
          checkbox.checked = true;

          checkbox.addEventListener("change", () => {
            iterateElements(rows, (row) => {
              const cell = row.querySelector(`td:nth-child(${cellIndex + 1})`);
              if (cell && cell.textContent.trim() === value) {
                row.style.display = checkbox.checked ? "" : "none";
              }
            });
          });

          filterDiv.appendChild(checkbox);
          filterDiv.appendChild(document.createTextNode(value));
          filterDiv.appendChild(document.createElement("br"));
        }
      });

      // Adiciona o checkbox de "Selecionar Tudo"
      const selectAllCheckbox = document.createElement("input");
      selectAllCheckbox.type = "checkbox";
      selectAllCheckbox.checked = true;

      selectAllCheckbox.addEventListener("change", () => {
        const checkboxes = filterDiv.querySelectorAll("input[type='checkbox']");
        iterateElements(checkboxes, (checkbox) => {
          checkbox.checked = selectAllCheckbox.checked;
          checkbox.dispatchEvent(new Event("change"));
        });
      });

      filterDiv.insertBefore(selectAllCheckbox, filterDiv.firstChild);
      filterDiv.insertBefore(document.createTextNode("Selecionar tudo"), filterDiv.childNodes[1]);
      filterDiv.insertBefore(document.createElement("br"), filterDiv.childNodes[2]);
    }
  });
}

// Função para criar filtros de busca
function createSearchFilter() {
  window.onload = () => {
    const dialogs = document.querySelectorAll(".body-dialog.filter");

    iterateElements(dialogs, (dialog) => {
      const filtro = dialog.querySelector(".filtro-nome");
      const tabela = dialog.querySelector(".lista");

      filtro.onkeyup = function () {
        const nomeFiltro = this.value.toLowerCase();

        iterateElements(tabela.rows, (row, rowIndex) => {
          if (rowIndex === 0) return; // Ignora o cabeçalho
          const rowContent = row.textContent.toLowerCase();
          row.style.display = rowContent.includes(nomeFiltro) ? "" : "none";
        });
      };
    });
  };
}



// Função para setar input com valor selecionado no filtro
function getSelectFilter(idDialog, idInput) {
  const dialog = document.getElementById(idDialog);
  const table = dialog.querySelector(".lista");
  const checkboxes = table.querySelectorAll(".select-filter");

  let contextoTabela = "";
  let preenchimentoAuto = "";
  let countChecked = 0;

  iterateElements(checkboxes, (checkbox) => {
    if (checkbox.checked) {
      countChecked++;
      if (countChecked > 1) {
        alert("Marque apenas uma opção!");
        return;
      }
      const row = checkbox.closest("tr");
      const tds = row.querySelectorAll("td");

      contextoTabela = tds[1].textContent.trim();
      if (idInput === "filterVeiculo") {
        preenchimentoAuto = tds[3].textContent.trim();
        document.getElementById("filterTransportadora").value = preenchimentoAuto;
      }
    }
  });

  if (countChecked === 0) {
    alert("Marque uma opção!");
    return;
  }

  document.getElementById(idInput).value = contextoTabela;
  dialog.close();
}

function applyFilters() {
  let rows = document.querySelectorAll("#myTable tr");
  let filterDivs = document.querySelectorAll(".filterDiv");

  // Itera por todas as linhas, exceto o cabeçalho
  iterateElements(rows, (row, rowIndex) => {
    if (rowIndex === 0) return; // Ignora cabeçalho

    let shouldShow = true;
    let isSelected = row.querySelector("input[type='checkbox']")?.checked || false;

    // Itera por todos os filtros e verifica as condições
    iterateElements(filterDivs, (filterDiv) => {
      let columnIndex = parseInt(filterDiv.getAttribute("data-column")) - 1;
      let cell = row.querySelector(`td:nth-child(${columnIndex + 1})`);

      if (cell) {
        let cellValue = cell.textContent.normalize().trim();
        let checkboxes = filterDiv.querySelectorAll("input[type='checkbox']:not(:first-child)");
        let checkedValues = Array.from(checkboxes)
          .filter((checkbox) => checkbox.checked)
          .map((checkbox) => checkbox.value);

        // Se o valor da célula não está nos valores marcados, esconde a linha
        if (!checkedValues.includes(cellValue)) {
          shouldShow = false;
        }
      }
    });

    // Mostra ou esconde a linha com base nos filtros aplicados
    row.style.display = shouldShow ? "" : "none";

    // Adiciona ou remove a classe 'active' com base no estado de exibição e seleção
    if (shouldShow && isSelected) {
      row.classList.add("active");
    } else {
      row.classList.remove("active");
    }
  });

  // Atualiza o contador de linhas selecionadas
  updateSelectedCount();
}

function criarFiltros() {
  let rows = document.querySelectorAll("#myTable tr");
  let uniqueValues = [];

  // Coleta valores únicos para cada coluna
  iterateElements(rows, (row, rowIndex) => {
    if (rowIndex > 0) {
      iterateElements(row.querySelectorAll("td"), (cell, cellIndex) => {
        let value = cell.textContent.normalize().trim();
        if (!uniqueValues[cellIndex]) {
          uniqueValues[cellIndex] = new Set();
        }
        uniqueValues[cellIndex].add(value);
      });
    }
  });

  uniqueValues.forEach((values, cellIndex) => {
    let filterDiv = document.querySelector(
      `.filterDiv[data-column='${cellIndex + 1}']`
    );
    if (filterDiv) {
      values.forEach((value) => {
        let escapedValue = cssEscape(value);
        if (!filterDiv.querySelector(`input[value='${escapedValue}']`)) {
          let checkbox = document.createElement("input");
          checkbox.type = "checkbox";
          checkbox.value = value;
          checkbox.checked = true;

          // Evento de filtro: Atualiza a tabela ao alterar qualquer filtro
          checkbox.addEventListener("change", applyFilters);

          filterDiv.appendChild(checkbox);
          filterDiv.appendChild(document.createTextNode(value));
          filterDiv.appendChild(document.createElement("br"));
        }
      });

      // Adiciona o checkbox de "Selecionar Tudo" para esta coluna
      let selectAllCheckbox = document.createElement("input");
      selectAllCheckbox.type = "checkbox";
      selectAllCheckbox.checked = true;

      selectAllCheckbox.addEventListener("change", function () {
        const checkboxes = filterDiv.querySelectorAll("input[type='checkbox']:not(:first-child)");
        checkboxes.forEach((checkbox) => {
          checkbox.checked = selectAllCheckbox.checked;
        });
        applyFilters(); // Aplica os filtros ao alterar "Selecionar Tudo"
      });

      filterDiv.insertBefore(selectAllCheckbox, filterDiv.firstChild);
      filterDiv.insertBefore(
        document.createTextNode("Selecionar tudo"),
        filterDiv.childNodes[1]
      );
      filterDiv.insertBefore(
        document.createElement("br"),
        filterDiv.childNodes[2]
      );
    }
  });
}