# DB_SCRUM_PLANNING

Proyecto académico de ejemplo para el Foro #1: procedimientos almacenados para insertar, actualizar y listar registros con paginación en Microsoft SQL Server.

## Contenido del proyecto

- `DB_SCRUM_PLANNING_Procedimientos.sql`: crea la base de datos, cuatro tablas de ejemplo y los procedimientos almacenados.
- Este README: instrucciones para preparar y probar el proyecto.

## Requisitos

- Microsoft SQL Server.
- SQL Server Management Studio (SSMS) o una herramienta compatible con SQL Server.

Python, React y FastAPI/Django no son necesarios para ejecutar únicamente los procedimientos almacenados SQL. Pueden formar parte de una aplicación más amplia si el curso también lo requiere.

## Cómo ejecutarlo

1. Abra SQL Server Management Studio y conéctese a una instancia de SQL Server.
2. Abra el archivo `DB_SCRUM_PLANNING_Procedimientos.sql`.
3. Ejecute el script completo.
4. Confirme que se creó la base de datos `DB_SCRUM_PLANNING`.
5. Revise las tablas `Usuarios`, `Proyectos`, `Sprints` y `Tareas`.
6. En el script, consulte los ejemplos de prueba del final. Están comentados para evitar que se inserten datos de prueba automáticamente; descomente esos comandos cuando quiera probarlos.

## Procedimientos incluidos

Para cada tabla se incluyen procedimientos de inserción, actualización y listado. Los procedimientos de listado utilizan `ORDER BY`, `OFFSET` y `FETCH NEXT` para paginar los resultados.

## Nota importante

Este proyecto se creó desde cero porque no se proporcionó el esquema oficial de la base de datos de la clase. Por eso, las tablas y relaciones son una propuesta académica de ejemplo y deben compararse con las indicaciones del profesor. El script está diseñado para Microsoft SQL Server y no para MySQL o PostgreSQL.

La ejecución real en SQL Server todavía debe verificarse en una instancia de SQL Server antes de considerar el proyecto probado.

## Datos del estudiante

- **Nombre:** Oswaldo Bernardo Acosta Pérez
- **Número de carné:** 240582
