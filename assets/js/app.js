const navButtons = Array.from(document.querySelectorAll(".nav-btn"));
const modulePanels = Array.from(document.querySelectorAll(".module-panel"));
const DEFAULT_MODULE_ID = "module-python-gpa";

function resolveInitialModuleId() {
  const activeButton = navButtons.find((button) => button.classList.contains("is-active") && button.dataset.target);
  if (activeButton?.dataset.target) {
    return activeButton.dataset.target;
  }

  if (modulePanels.some((panel) => panel.id === DEFAULT_MODULE_ID)) {
    return DEFAULT_MODULE_ID;
  }

  return modulePanels[0]?.id ?? null;
}

function showModule(moduleId) {
  if (!moduleId) {
    return;
  }

  const safeModuleId = modulePanels.some((panel) => panel.id === moduleId)
    ? moduleId
    : resolveInitialModuleId();

  if (!safeModuleId) {
    return;
  }

  navButtons.forEach((button) => {
    button.classList.toggle("is-active", button.dataset.target === safeModuleId);
  });

  modulePanels.forEach((panel) => {
    panel.classList.toggle("is-visible", panel.id === safeModuleId);
  });
}

navButtons.forEach((button) => {
  button.addEventListener("click", () => {
    if (button.dataset.target) {
      showModule(button.dataset.target);
    }
  });
});

showModule(resolveInitialModuleId());
