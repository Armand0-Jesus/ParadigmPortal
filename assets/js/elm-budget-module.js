function getElement(id) {
  return document.querySelector(`#${id}`);
}

let elmBudgetInitialized = false;

function showElmStatus(message, isError = false) {
  const status = getElement("elm-budget-status");
  if (!status) {
    return;
  }

  status.textContent = message;
  status.classList.toggle("is-error", isError);
}

function initElmBudgetModule() {
  const mountNode = getElement("elm-budget-root");
  if (!mountNode || elmBudgetInitialized) {
    return;
  }

  const elmGlobal = window.Elm;
  if (!elmGlobal || !elmGlobal.Main || typeof elmGlobal.Main.init !== "function") {
    showElmStatus(
      "Error: no se encontro elm-budget.js. Compila Elm para activar este modulo.",
      true
    );
    return;
  }

  try {
    elmGlobal.Main.init({ node: mountNode });
    elmBudgetInitialized = true;
    showElmStatus("Modulo Elm cargado correctamente.");
  } catch (error) {
    const message = error instanceof Error ? error.message : "Error desconocido al inicializar Elm.";
    showElmStatus(`Error: ${message}`, true);
  }
}

initElmBudgetModule();
