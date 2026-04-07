const RULES_PATH = "modules/prolog-recommender/rules.pl";

const RECOMMENDATION_MESSAGES = {
  study_for_exam: "Prioriza estudiar para el examen hoy.",
  finish_project_milestone: "Enfocate en adelantar la entrega importante.",
  practice_hard_topic: "Dedica tiempo a practicar el tema mas dificil.",
  light_review: "Haz un repaso liviano de notas o resumenes.",
  plan_and_review: "Organiza tu plan semanal y repasa temas pendientes.",
};

const OPTIONAL_FACT_PREDICATES = [
  "exam_soon",
  "deadline_soon",
  "difficult_subject",
  "low_energy",
];

let cachedRules = "";
let isRecommendationRunning = false;

function getElement(id) {
  return document.querySelector(`#${id}`);
}

function showPrologResult(message, isError = false) {
  const result = getElement("prolog-result");
  if (!result) {
    return;
  }

  result.textContent = message;
  result.classList.toggle("is-error", isError);
}

function setRunButtonState(isBusy) {
  const runButton = getElement("prolog-run-btn");
  if (!runButton) {
    return;
  }

  runButton.disabled = isBusy;
  runButton.textContent = isBusy ? "Analizando..." : "Recomendar estudio";
}

function hasTauProlog() {
  return typeof window.pl === "object" && window.pl !== null && typeof window.pl.create === "function";
}

async function loadRules() {
  if (cachedRules !== "") {
    return cachedRules;
  }

  const response = await fetch(RULES_PATH);
  if (!response.ok) {
    throw new Error("No se pudo cargar rules.pl.");
  }

  cachedRules = await response.text();
  return cachedRules;
}

function collectFacts() {
  const facts = [];

  if (getElement("prolog-exam-soon")?.checked) {
    facts.push("exam_soon.");
  }

  if (getElement("prolog-deadline-soon")?.checked) {
    facts.push("deadline_soon.");
  }

  if (getElement("prolog-difficult-subject")?.checked) {
    facts.push("difficult_subject.");
  }

  if (getElement("prolog-low-energy")?.checked) {
    facts.push("low_energy.");
  }

  return facts;
}

function buildProgram(rules, facts) {
  const factsBlock = facts.join("\n");
  const defaultFactsBlock = OPTIONAL_FACT_PREDICATES.map(
    (predicateName) => `${predicateName} :- fail.`
  ).join("\n");

  return `${rules}\n\n${factsBlock}\n${defaultFactsBlock}\n`;
}

function consultProgram(session, programText) {
  return new Promise((resolve, reject) => {
    session.consult(programText, {
      success: () => resolve(),
      error: (error) => reject(new Error(String(error))),
    });
  });
}

function queryBestRecommendation(session) {
  return new Promise((resolve, reject) => {
    session.query("best_recommendation(Action).", {
      success: () => {
        session.answer({
          success: (answer) => {
            const formatted = session.format_answer(answer);
            const match = formatted.match(/Action\s*=\s*([a-zA-Z0-9_]+)/);
            if (!match) {
              reject(new Error("No se pudo interpretar la respuesta de Prolog."));
              return;
            }

            resolve(match[1]);
          },
          fail: () => reject(new Error("No se encontro recomendacion.")),
          error: (error) => reject(new Error(String(error))),
          limit: () => reject(new Error("Se alcanzo limite de inferencia en Prolog.")),
        });
      },
      error: (error) => reject(new Error(String(error))),
    });
  });
}

async function runRecommendation() {
  if (isRecommendationRunning) {
    return;
  }

  isRecommendationRunning = true;
  setRunButtonState(true);
  showPrologResult("Analizando reglas...");

  try {
    if (!hasTauProlog()) {
      throw new Error("Tau Prolog no esta disponible en la pagina.");
    }

    const rules = await loadRules();
    const facts = collectFacts();
    const program = buildProgram(rules, facts);

    const session = window.pl.create(1000);
    await consultProgram(session, program);
    const recommendationKey = await queryBestRecommendation(session);

    const message = RECOMMENDATION_MESSAGES[recommendationKey] || `Recomendacion: ${recommendationKey}`;
    showPrologResult(`Recomendacion final: ${message}`);
  } catch (error) {
    const message = error instanceof Error ? error.message : "Error desconocido en Tau Prolog.";
    showPrologResult(`Error: ${message}`, true);
  } finally {
    isRecommendationRunning = false;
    setRunButtonState(false);
  }
}

function initPrologModule() {
  const runButton = getElement("prolog-run-btn");
  if (!runButton) {
    return;
  }

  setRunButtonState(false);

  runButton.addEventListener("click", () => {
    runRecommendation();
  });
}

initPrologModule();
