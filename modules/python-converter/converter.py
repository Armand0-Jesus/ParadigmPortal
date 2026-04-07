"""Python converter module executed in browser via PyScript."""

# pyright: reportMissingImports=false

try:
    from pyscript import document, when
except ImportError:
    document = None

    def when(*_args, **_kwargs):
        def decorator(func):
            return func

        return decorator


def percentage_to_letter(score):
    if score >= 90:
        return "A"
    if score >= 80:
        return "B"
    if score >= 70:
        return "C"
    if score >= 60:
        return "D"
    return "F"


def hours_to_minutes(hours):
    return hours * 60


def celsius_to_fahrenheit(celsius):
    return (celsius * 9 / 5) + 32


def megabytes_to_gigabytes(megabytes):
    return megabytes / 1024


def get_document():
    if document is None:
        raise RuntimeError("PyScript document no esta disponible.")
    return document


def parse_input_value():
    raw_value = (get_document().querySelector("#converter-input").value or "").strip()
    if raw_value == "":
        raise ValueError("Ingresa un valor para convertir.")

    try:
        return float(raw_value)
    except ValueError as exc:
        raise ValueError("El valor de entrada debe ser numerico.") from exc


def convert_selected_value(converter_type, value):
    if converter_type == "percentage_to_letter":
        if not 0 <= value <= 100:
            raise ValueError("Para porcentaje a letra, usa un valor entre 0 y 100.")
        return f"{value:.2f}% equivale a letra {percentage_to_letter(value)}."

    if converter_type == "hours_to_minutes":
        result = hours_to_minutes(value)
        return f"{value:.2f} horas son {result:.2f} minutos."

    if converter_type == "celsius_to_fahrenheit":
        result = celsius_to_fahrenheit(value)
        return f"{value:.2f} C son {result:.2f} F."

    if converter_type == "megabytes_to_gigabytes":
        result = megabytes_to_gigabytes(value)
        return f"{value:.2f} MB son {result:.4f} GB."

    raise ValueError("Tipo de conversion no soportado.")


def show_converter_message(message, is_error=False):
    result = get_document().querySelector("#converter-result")
    result.textContent = message
    result.classList.toggle("is-error", is_error)


@when("click", "#converter-run-btn")
def on_convert_click(_event):
    try:
        converter_type = get_document().querySelector("#converter-type").value
        value = parse_input_value()
        message = convert_selected_value(converter_type, value)
        show_converter_message(message)
    except (ValueError, RuntimeError) as error:
        show_converter_message(f"Error: {error}", is_error=True)
