"""Python GPA module executed in browser via PyScript."""

# pyright: reportMissingImports=false

try:
    from pyscript import document, when
except ImportError:
    document = None

    def when(*_args, **_kwargs):
        def decorator(func):
            return func

        return decorator


def calculate_weighted_average(grades_with_weights):
    total_weight = sum(weight for _, weight in grades_with_weights)
    if total_weight <= 0:
        raise ValueError("La suma de pesos debe ser mayor que 0.")

    weighted_sum = sum(grade * weight for grade, weight in grades_with_weights)
    return weighted_sum / total_weight


def get_document():
    if document is None:
        raise RuntimeError("PyScript document no esta disponible.")
    return document


def parse_number(raw_text, field_name):
    text = (raw_text or "").strip()
    if text == "":
        raise ValueError(f"Falta valor en {field_name}.")

    try:
        return float(text)
    except ValueError as exc:
        raise ValueError(f"{field_name} debe ser numerico.") from exc


def collect_grade_rows():
    doc = get_document()
    rows = []

    for idx in range(1, 5):
        grade_text = doc.querySelector(f"#gpa-grade-{idx}").value
        weight_text = doc.querySelector(f"#gpa-weight-{idx}").value

        if grade_text.strip() == "" and weight_text.strip() == "":
            continue

        grade = parse_number(grade_text, f"Nota {idx}")
        weight = parse_number(weight_text, f"Peso {idx}")

        if not 0 <= grade <= 100:
            raise ValueError(f"Nota {idx} debe estar entre 0 y 100.")
        if weight < 0:
            raise ValueError(f"Peso {idx} no puede ser negativo.")

        rows.append((grade, weight))

    if not rows:
        raise ValueError("Ingresa al menos una nota con su peso.")

    return rows


def show_gpa_message(message, is_error=False):
    result = get_document().querySelector("#gpa-result")
    result.textContent = message
    result.classList.toggle("is-error", is_error)


@when("click", "#gpa-calc-btn")
def on_calculate_click(_event):
    try:
        rows = collect_grade_rows()
        average = calculate_weighted_average(rows)
        show_gpa_message(f"Promedio final: {average:.2f}")
    except (ValueError, RuntimeError) as error:
        show_gpa_message(f"Error: {error}", is_error=True)
