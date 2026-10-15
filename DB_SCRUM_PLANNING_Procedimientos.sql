/*
FORO #1 - EVALUACION SUMATIVA
Base de datos: DB_SCRUM_PLANNING
Motor propuesto: Microsoft SQL Server

NOTA:
Como no se proporciono un esquema previo de la base de datos, este script crea
una estructura inicial de ejemplo para gestionar proyectos Scrum. Incluye
procedimientos almacenados para INSERTAR, ACTUALIZAR y LISTAR con paginacion
(OFFSET / FETCH) para todas las tablas definidas aqui.

INSTRUCCIONES:
1. Abrir SQL Server Management Studio (SSMS).
2. Abrir este archivo y ejecutar el script completo.
3. Para probar los procedimientos, revisar los ejemplos al final.
*/

IF DB_ID(N'DB_SCRUM_PLANNING') IS NULL
    CREATE DATABASE DB_SCRUM_PLANNING;
GO

USE DB_SCRUM_PLANNING;
GO

/* Eliminar procedimientos si se vuelve a ejecutar el script */
DROP PROCEDURE IF EXISTS dbo.sp_Usuario_Insertar;
DROP PROCEDURE IF EXISTS dbo.sp_Usuario_Actualizar;
DROP PROCEDURE IF EXISTS dbo.sp_Usuario_Listar;
DROP PROCEDURE IF EXISTS dbo.sp_Proyecto_Insertar;
DROP PROCEDURE IF EXISTS dbo.sp_Proyecto_Actualizar;
DROP PROCEDURE IF EXISTS dbo.sp_Proyecto_Listar;
DROP PROCEDURE IF EXISTS dbo.sp_Sprint_Insertar;
DROP PROCEDURE IF EXISTS dbo.sp_Sprint_Actualizar;
DROP PROCEDURE IF EXISTS dbo.sp_Sprint_Listar;
DROP PROCEDURE IF EXISTS dbo.sp_Tarea_Insertar;
DROP PROCEDURE IF EXISTS dbo.sp_Tarea_Actualizar;
DROP PROCEDURE IF EXISTS dbo.sp_Tarea_Listar;
GO

/* Crear tablas si todavía no existen */
IF OBJECT_ID(N'dbo.Usuarios', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Usuarios (
        UsuarioID INT IDENTITY(1,1) PRIMARY KEY,
        Nombre NVARCHAR(100) NOT NULL,
        Correo NVARCHAR(150) NOT NULL UNIQUE,
        Rol NVARCHAR(30) NOT NULL
            CONSTRAINT DF_Usuarios_Rol DEFAULT N'Miembro',
        Activo BIT NOT NULL
            CONSTRAINT DF_Usuarios_Activo DEFAULT 1,
        FechaCreacion DATETIME2 NOT NULL
            CONSTRAINT DF_Usuarios_Fecha DEFAULT SYSDATETIME()
    );
END;
GO

IF OBJECT_ID(N'dbo.Proyectos', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Proyectos (
        ProyectoID INT IDENTITY(1,1) PRIMARY KEY,
        Nombre NVARCHAR(120) NOT NULL,
        Descripcion NVARCHAR(500) NULL,
        FechaInicio DATE NULL,
        FechaFin DATE NULL,
        Estado NVARCHAR(30) NOT NULL
            CONSTRAINT DF_Proyectos_Estado DEFAULT N'Planificado',
        ResponsableID INT NULL,
        CONSTRAINT FK_Proyectos_Usuarios
            FOREIGN KEY (ResponsableID) REFERENCES dbo.Usuarios(UsuarioID),
        CONSTRAINT CK_Proyectos_Fechas
            CHECK (FechaFin IS NULL OR FechaInicio IS NULL OR FechaFin >= FechaInicio)
    );
END;
GO

IF OBJECT_ID(N'dbo.Sprints', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Sprints (
        SprintID INT IDENTITY(1,1) PRIMARY KEY,
        ProyectoID INT NOT NULL,
        Nombre NVARCHAR(100) NOT NULL,
        Objetivo NVARCHAR(500) NULL,
        FechaInicio DATE NOT NULL,
        FechaFin DATE NOT NULL,
        Estado NVARCHAR(30) NOT NULL
            CONSTRAINT DF_Sprints_Estado DEFAULT N'Planificado',
        CONSTRAINT FK_Sprints_Proyectos
            FOREIGN KEY (ProyectoID) REFERENCES dbo.Proyectos(ProyectoID),
        CONSTRAINT CK_Sprints_Fechas CHECK (FechaFin >= FechaInicio)
    );
END;
GO

IF OBJECT_ID(N'dbo.Tareas', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Tareas (
        TareaID INT IDENTITY(1,1) PRIMARY KEY,
        SprintID INT NOT NULL,
        AsignadoA INT NULL,
        Titulo NVARCHAR(150) NOT NULL,
        Descripcion NVARCHAR(600) NULL,
        Prioridad NVARCHAR(20) NOT NULL
            CONSTRAINT DF_Tareas_Prioridad DEFAULT N'Media',
        Estado NVARCHAR(30) NOT NULL
            CONSTRAINT DF_Tareas_Estado DEFAULT N'Pendiente',
        EstimacionHoras DECIMAL(8,2) NULL,
        FechaCreacion DATETIME2 NOT NULL
            CONSTRAINT DF_Tareas_Fecha DEFAULT SYSDATETIME(),
        CONSTRAINT FK_Tareas_Sprints
            FOREIGN KEY (SprintID) REFERENCES dbo.Sprints(SprintID),
        CONSTRAINT FK_Tareas_Usuarios
            FOREIGN KEY (AsignadoA) REFERENCES dbo.Usuarios(UsuarioID),
        CONSTRAINT CK_Tareas_Estimacion
            CHECK (EstimacionHoras IS NULL OR EstimacionHoras >= 0)
    );
END;
GO

/* =========================================================
   TABLA: USUARIOS
   ========================================================= */
CREATE PROCEDURE dbo.sp_Usuario_Insertar
    @Nombre NVARCHAR(100),
    @Correo NVARCHAR(150),
    @Rol NVARCHAR(30) = N'Miembro',
    @Activo BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM dbo.Usuarios WHERE Correo = @Correo)
        THROW 50001, 'Ya existe un usuario con ese correo.', 1;

    INSERT INTO dbo.Usuarios (Nombre, Correo, Rol, Activo)
    VALUES (@Nombre, @Correo, @Rol, @Activo);

    SELECT CAST(SCOPE_IDENTITY() AS INT) AS UsuarioID;
END;
GO

CREATE PROCEDURE dbo.sp_Usuario_Actualizar
    @UsuarioID INT,
    @Nombre NVARCHAR(100),
    @Correo NVARCHAR(150),
    @Rol NVARCHAR(30),
    @Activo BIT
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.Usuarios WHERE UsuarioID = @UsuarioID)
        THROW 50002, 'El usuario indicado no existe.', 1;
    IF EXISTS (SELECT 1 FROM dbo.Usuarios WHERE Correo = @Correo AND UsuarioID <> @UsuarioID)
        THROW 50003, 'El correo ya pertenece a otro usuario.', 1;

    UPDATE dbo.Usuarios
    SET Nombre = @Nombre, Correo = @Correo, Rol = @Rol, Activo = @Activo
    WHERE UsuarioID = @UsuarioID;

    SELECT @@ROWCOUNT AS RegistrosActualizados;
END;
GO

CREATE PROCEDURE dbo.sp_Usuario_Listar
    @Pagina INT = 1,
    @TamanoPagina INT = 10
AS
BEGIN
    SET NOCOUNT ON;
    IF @Pagina < 1 OR @TamanoPagina < 1
        THROW 50004, 'La pagina y el tamano de pagina deben ser mayores que cero.', 1;

    SELECT UsuarioID, Nombre, Correo, Rol, Activo, FechaCreacion
    FROM dbo.Usuarios
    ORDER BY UsuarioID
    OFFSET (@Pagina - 1) * @TamanoPagina ROWS
    FETCH NEXT @TamanoPagina ROWS ONLY;
END;
GO

/* =========================================================
   TABLA: PROYECTOS
   ========================================================= */
CREATE PROCEDURE dbo.sp_Proyecto_Insertar
    @Nombre NVARCHAR(120),
    @Descripcion NVARCHAR(500) = NULL,
    @FechaInicio DATE = NULL,
    @FechaFin DATE = NULL,
    @Estado NVARCHAR(30) = N'Planificado',
    @ResponsableID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @FechaFin IS NOT NULL AND @FechaInicio IS NOT NULL AND @FechaFin < @FechaInicio
        THROW 50005, 'La fecha final no puede ser anterior a la fecha inicial.', 1;

    INSERT INTO dbo.Proyectos (Nombre, Descripcion, FechaInicio, FechaFin, Estado, ResponsableID)
    VALUES (@Nombre, @Descripcion, @FechaInicio, @FechaFin, @Estado, @ResponsableID);

    SELECT CAST(SCOPE_IDENTITY() AS INT) AS ProyectoID;
END;
GO

CREATE PROCEDURE dbo.sp_Proyecto_Actualizar
    @ProyectoID INT,
    @Nombre NVARCHAR(120),
    @Descripcion NVARCHAR(500) = NULL,
    @FechaInicio DATE = NULL,
    @FechaFin DATE = NULL,
    @Estado NVARCHAR(30),
    @ResponsableID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.Proyectos WHERE ProyectoID = @ProyectoID)
        THROW 50006, 'El proyecto indicado no existe.', 1;
    IF @FechaFin IS NOT NULL AND @FechaInicio IS NOT NULL AND @FechaFin < @FechaInicio
        THROW 50007, 'La fecha final no puede ser anterior a la fecha inicial.', 1;

    UPDATE dbo.Proyectos
    SET Nombre = @Nombre, Descripcion = @Descripcion, FechaInicio = @FechaInicio,
        FechaFin = @FechaFin, Estado = @Estado, ResponsableID = @ResponsableID
    WHERE ProyectoID = @ProyectoID;

    SELECT @@ROWCOUNT AS RegistrosActualizados;
END;
GO

CREATE PROCEDURE dbo.sp_Proyecto_Listar
    @Pagina INT = 1,
    @TamanoPagina INT = 10
AS
BEGIN
    SET NOCOUNT ON;
    IF @Pagina < 1 OR @TamanoPagina < 1
        THROW 50008, 'La pagina y el tamano de pagina deben ser mayores que cero.', 1;

    SELECT p.ProyectoID, p.Nombre, p.Descripcion, p.FechaInicio, p.FechaFin,
           p.Estado, p.ResponsableID, u.Nombre AS NombreResponsable
    FROM dbo.Proyectos AS p
    LEFT JOIN dbo.Usuarios AS u ON u.UsuarioID = p.ResponsableID
    ORDER BY p.ProyectoID
    OFFSET (@Pagina - 1) * @TamanoPagina ROWS
    FETCH NEXT @TamanoPagina ROWS ONLY;
END;
GO

/* =========================================================
   TABLA: SPRINTS
   ========================================================= */
CREATE PROCEDURE dbo.sp_Sprint_Insertar
    @ProyectoID INT,
    @Nombre NVARCHAR(100),
    @Objetivo NVARCHAR(500) = NULL,
    @FechaInicio DATE,
    @FechaFin DATE,
    @Estado NVARCHAR(30) = N'Planificado'
AS
BEGIN
    SET NOCOUNT ON;
    IF @FechaFin < @FechaInicio
        THROW 50009, 'La fecha final del sprint no puede ser anterior a la inicial.', 1;

    INSERT INTO dbo.Sprints (ProyectoID, Nombre, Objetivo, FechaInicio, FechaFin, Estado)
    VALUES (@ProyectoID, @Nombre, @Objetivo, @FechaInicio, @FechaFin, @Estado);

    SELECT CAST(SCOPE_IDENTITY() AS INT) AS SprintID;
END;
GO

CREATE PROCEDURE dbo.sp_Sprint_Actualizar
    @SprintID INT,
    @ProyectoID INT,
    @Nombre NVARCHAR(100),
    @Objetivo NVARCHAR(500) = NULL,
    @FechaInicio DATE,
    @FechaFin DATE,
    @Estado NVARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.Sprints WHERE SprintID = @SprintID)
        THROW 50010, 'El sprint indicado no existe.', 1;
    IF @FechaFin < @FechaInicio
        THROW 50011, 'La fecha final del sprint no puede ser anterior a la inicial.', 1;

    UPDATE dbo.Sprints
    SET ProyectoID = @ProyectoID, Nombre = @Nombre, Objetivo = @Objetivo,
        FechaInicio = @FechaInicio, FechaFin = @FechaFin, Estado = @Estado
    WHERE SprintID = @SprintID;

    SELECT @@ROWCOUNT AS RegistrosActualizados;
END;
GO

CREATE PROCEDURE dbo.sp_Sprint_Listar
    @Pagina INT = 1,
    @TamanoPagina INT = 10
AS
BEGIN
    SET NOCOUNT ON;
    IF @Pagina < 1 OR @TamanoPagina < 1
        THROW 50012, 'La pagina y el tamano de pagina deben ser mayores que cero.', 1;

    SELECT s.SprintID, s.ProyectoID, p.Nombre AS NombreProyecto, s.Nombre,
           s.Objetivo, s.FechaInicio, s.FechaFin, s.Estado
    FROM dbo.Sprints AS s
    INNER JOIN dbo.Proyectos AS p ON p.ProyectoID = s.ProyectoID
    ORDER BY s.SprintID
    OFFSET (@Pagina - 1) * @TamanoPagina ROWS
    FETCH NEXT @TamanoPagina ROWS ONLY;
END;
GO

/* =========================================================
   TABLA: TAREAS
   ========================================================= */
CREATE PROCEDURE dbo.sp_Tarea_Insertar
    @SprintID INT,
    @AsignadoA INT = NULL,
    @Titulo NVARCHAR(150),
    @Descripcion NVARCHAR(600) = NULL,
    @Prioridad NVARCHAR(20) = N'Media',
    @Estado NVARCHAR(30) = N'Pendiente',
    @EstimacionHoras DECIMAL(8,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @EstimacionHoras IS NOT NULL AND @EstimacionHoras < 0
        THROW 50013, 'La estimacion de horas no puede ser negativa.', 1;

    INSERT INTO dbo.Tareas (SprintID, AsignadoA, Titulo, Descripcion, Prioridad, Estado, EstimacionHoras)
    VALUES (@SprintID, @AsignadoA, @Titulo, @Descripcion, @Prioridad, @Estado, @EstimacionHoras);

    SELECT CAST(SCOPE_IDENTITY() AS INT) AS TareaID;
END;
GO

CREATE PROCEDURE dbo.sp_Tarea_Actualizar
    @TareaID INT,
    @SprintID INT,
    @AsignadoA INT = NULL,
    @Titulo NVARCHAR(150),
    @Descripcion NVARCHAR(600) = NULL,
    @Prioridad NVARCHAR(20),
    @Estado NVARCHAR(30),
    @EstimacionHoras DECIMAL(8,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.Tareas WHERE TareaID = @TareaID)
        THROW 50014, 'La tarea indicada no existe.', 1;
    IF @EstimacionHoras IS NOT NULL AND @EstimacionHoras < 0
        THROW 50015, 'La estimacion de horas no puede ser negativa.', 1;

    UPDATE dbo.Tareas
    SET SprintID = @SprintID, AsignadoA = @AsignadoA, Titulo = @Titulo,
        Descripcion = @Descripcion, Prioridad = @Prioridad, Estado = @Estado,
        EstimacionHoras = @EstimacionHoras
    WHERE TareaID = @TareaID;

    SELECT @@ROWCOUNT AS RegistrosActualizados;
END;
GO

CREATE PROCEDURE dbo.sp_Tarea_Listar
    @Pagina INT = 1,
    @TamanoPagina INT = 10
AS
BEGIN
    SET NOCOUNT ON;
    IF @Pagina < 1 OR @TamanoPagina < 1
        THROW 50016, 'La pagina y el tamano de pagina deben ser mayores que cero.', 1;

    SELECT t.TareaID, t.SprintID, s.Nombre AS NombreSprint, t.AsignadoA,
           u.Nombre AS NombreAsignado, t.Titulo, t.Descripcion, t.Prioridad,
           t.Estado, t.EstimacionHoras, t.FechaCreacion
    FROM dbo.Tareas AS t
    INNER JOIN dbo.Sprints AS s ON s.SprintID = t.SprintID
    LEFT JOIN dbo.Usuarios AS u ON u.UsuarioID = t.AsignadoA
    ORDER BY t.TareaID
    OFFSET (@Pagina - 1) * @TamanoPagina ROWS
    FETCH NEXT @TamanoPagina ROWS ONLY;
END;
GO

/* =========================================================
   EJEMPLOS DE PRUEBA (DESCOMENTAR PARA EJECUTAR)
   Ejecutar en orden para respetar las relaciones entre tablas.
   =========================================================
EXEC dbo.sp_Usuario_Insertar
    @Nombre = N'Ana López',
    @Correo = N'ana@example.com',
    @Rol = N'Scrum Master',
    @Activo = 1;

EXEC dbo.sp_Proyecto_Insertar
    @Nombre = N'Sistema de planificación Scrum',
    @Descripcion = N'Proyecto académico para organizar sprints y tareas',
    @FechaInicio = '2026-10-01',
    @FechaFin = '2026-12-15',
    @Estado = N'En progreso',
    @ResponsableID = 1;

EXEC dbo.sp_Sprint_Insertar
    @ProyectoID = 1,
    @Nombre = N'Sprint 1',
    @Objetivo = N'Preparar la estructura inicial',
    @FechaInicio = '2026-10-01',
    @FechaFin = '2026-10-14',
    @Estado = N'En progreso';

EXEC dbo.sp_Tarea_Insertar
    @SprintID = 1,
    @AsignadoA = 1,
    @Titulo = N'Diseñar las tablas',
    @Descripcion = N'Crear el modelo inicial de la base de datos',
    @Prioridad = N'Alta',
    @Estado = N'Pendiente',
    @EstimacionHoras = 4;

EXEC dbo.sp_Usuario_Listar @Pagina = 1, @TamanoPagina = 10;
EXEC dbo.sp_Proyecto_Listar @Pagina = 1, @TamanoPagina = 10;
EXEC dbo.sp_Sprint_Listar @Pagina = 1, @TamanoPagina = 10;
EXEC dbo.sp_Tarea_Listar @Pagina = 1, @TamanoPagina = 10;
*/
