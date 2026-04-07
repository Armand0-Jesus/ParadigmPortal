# Programming Languages Midterm - Smart Academic Task Planner

Proyecto universitario en una sola pagina web personal con 7 programas ejecutables desde el mismo sitio, cubriendo paradigmas imperativo, funcional, logico y orientado a objetos.

## Objetivo de arquitectura

- Un solo sitio web estatico (sin backend obligatorio).
- Un layout visual compartido para todos los modulos.
- Una sola navegacion que cambia entre secciones.
- Cada programa vive en su carpeta para mantener orden y facilitar mantenimiento.
- Integracion simple con JavaScript como glue code.

## Estructura exacta del proyecto

```text
Programming-Languages-Midterm/
	index.html
	README.md
	assets/
		css/
			styles.css
		generated/
			.gitkeep
		js/
			app.js
			java-modules.js
	data/
		cv.json
	scripts/
		build-java-web.ps1
	modules/
		python-gpa/
			gpa.py
		python-converter/
			converter.py
		java-task-manager/
			pom.xml
			src/
				main/
					java/
						Main.java
						TaskBridgeEntry.java
		java-priority-calculator/
			pom.xml
			src/
				main/
					java/
						PriorityCalculator.java
						PriorityBridgeEntry.java
		prolog-recommender/
			rules.pl
		elm-budget-tracker/
			src/
				Main.elm
		cv-generator/
			generator.js
```

## Integracion por lenguaje (simple y estable)

1. Python (2 modulos imperativos)
- Opcion elegida: PyScript (Pyodide) en front-end.
- Ventaja: no requiere backend, ejecuta Python en navegador.
- Uso actual: formularios conectados a `gpa.py` y `converter.py` con validaciones y salida en pantalla.

2. Java (2 modulos OOP)
- Opcion elegida: TeaVM para compilar Java a JavaScript/WebAssembly.
- Ventaja: mantienes logica en Java y ejecutas en navegador.
- Uso actual: `java-modules.js` carga bridges de TeaVM si existen y usa fallback JS si no estan compilados.

3. Tau Prolog (modulo logico)
- Opcion elegida: Tau Prolog por CDN.
- Ventaja: reglas Prolog en archivo `.pl` y consultas desde JS.
- Uso actual: UI con condiciones de estudio -> facts dinamicos -> consulta `best_recommendation(Action)`.

4. Elm (modulo funcional)
- Opcion elegida: Elm compilado con `elm make` a JS.
- Ventaja: arquitectura funcional clara y segura.
- Uso actual: app funcional de ingresos/gastos con balance total y eliminacion de entradas.

5. CV / Resume Generator (requisito especial)
- Opcion elegida: JavaScript puro + `data/cv.json`.
- Usa campo `enabled` por seccion y por entrada para activar/desactivar contenido.
- Renderiza resume HTML dentro de la pagina y permite descargar PDF.
- PDF integrado con `html2pdf.js`.

## Estado de implementacion

- Sitio unificado en una sola pagina con navegacion entre 7 modulos.
- Modulos Python funcionales (GPA y conversor).
- Modulos Java funcionales en web con fallback JS y soporte opcional de bridge TeaVM.
- Modulo Tau Prolog funcional con reglas y recomendacion final.
- Modulo Elm funcional y compilado a `assets/generated/elm-budget.js`.
- Modulo CV funcional con toggles, render y exportacion a PDF.
- Limpieza aplicada: `.gitignore` agregado, cache `elm-stuff` removida y textos de estado actualizados.

## Como correr localmente (VS Code)

Opcion A: Live Server (recomendada)
1. Abrir la carpeta `Programming-Languages-Midterm` en VS Code.
2. Instalar extension Live Server si no la tienes.
3. Abrir `index.html` y ejecutar "Open with Live Server".

Opcion B: Servidor simple con Python
1. En terminal, entrar a la carpeta del proyecto.
2. Ejecutar:

```bash
python -m http.server 5500
```

3. Abrir `http://localhost:5500` en el navegador.

Nota: usar un servidor local evita problemas de `fetch` para leer `data/cv.json`.

## Build de Java con TeaVM (opcional pero recomendado)

1. Tener Java 17+ y Maven instalados.
2. En terminal, en la raiz del proyecto, ejecutar:

```powershell
./scripts/build-java-web.ps1
```

3. Esto genera:
- `assets/generated/java-task-bridge.js`
- `assets/generated/java-priority-bridge.js`

4. Al recargar la pagina, los modulos Java usaran esos bridges automaticamente.
Si los archivos no existen, el sitio sigue funcionando con fallback JS.

Nota de entorno: si VS Code muestra importaciones TeaVM sin resolver en los archivos bridge,
normalmente se corrige cuando Maven esta instalado y el proyecto Maven se puede resolver en el editor.

## Estado actual

El proyecto esta integrado y funcional en sus 7 modulos, con una pasada de limpieza aplicada para mantener estructura, consistencia y ejecucion local simple.
