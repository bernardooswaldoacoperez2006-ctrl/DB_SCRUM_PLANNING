USE [DB_SCRUM_PLANNING]
GO

CREATE OR ALTER PROC [SQM_SECURITY].[USP_Roles]
(
    @i_rolId INT = NULL,
    @i_rolName VARCHAR(80) = NULL,
    @i_rolCreationDate DATETIME = NULL,
    @i_rolCreatorId INT = NULL,
    @i_rolModificationDate DATETIME = NULL,
    @i_rolModificatorId INT = NULL,
    @i_rolEnable BIT = NULL,
    @i_PageNumber INT = 1,
    @i_RowsPerPage INT = 10,
    @w_Accion CHAR(1),
    @o_Numero INT = NULL OUT,
    @o_MensajeTecnico VARCHAR(500) = NULL OUT,
    @o_MensajeUsuario VARCHAR(500) = NULL OUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET @o_Numero = 0;
    SET @o_MensajeTecnico = NULL;
    SET @o_MensajeUsuario = NULL;

    IF @w_Accion = 'I'
    BEGIN
        BEGIN TRY
            INSERT INTO [SQM_SECURITY].[TBL_Roles] (rolName, rolCreationDate, rolCreatorId, rolModificationDate, rolModificatorId, rolEnable)
            VALUES (@i_rolName, COALESCE(@i_rolCreationDate, GETDATE()), @i_rolCreatorId, COALESCE(@i_rolModificationDate, GETDATE()), @i_rolModificatorId, COALESCE(@i_rolEnable, 1));
            SET @o_Numero = 201;
            SET @o_MensajeUsuario = 'ROLES REGISTRADO CORRECTAMENTE';
        END TRY
        BEGIN CATCH
            SET @o_Numero = 500;
            SET @o_MensajeUsuario = 'ERROR AL REGISTRAR ROLES';
            SET @o_MensajeTecnico = CONCAT_WS(' - ', ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE());
        END CATCH
    END
    ELSE IF @w_Accion = 'U'
    BEGIN
        IF ISNULL(@i_rolId, 0) = 0
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL ID ES OBLIGATORIO';
        END
        ELSE IF NOT EXISTS (SELECT 1 FROM [SQM_SECURITY].[TBL_Roles] WHERE rolId = @i_rolId)
        BEGIN
            SET @o_Numero = 404;
            SET @o_MensajeUsuario = 'EL REGISTRO NO EXISTE';
        END
        ELSE
        BEGIN
            BEGIN TRY
                UPDATE [SQM_SECURITY].[TBL_Roles]
                SET                 rolName = COALESCE(@i_rolName, rolName),
                rolModificationDate = GETDATE(),
                rolModificatorId = COALESCE(@i_rolModificatorId, rolModificatorId),
                rolEnable = COALESCE(@i_rolEnable, rolEnable)
                WHERE rolId = @i_rolId;
                SET @o_Numero = 200;
                SET @o_MensajeUsuario = 'REGISTRO ACTUALIZADO CORRECTAMENTE';
            END TRY
            BEGIN CATCH
                SET @o_Numero = 500;
                SET @o_MensajeUsuario = 'ERROR AL ACTUALIZAR REGISTRO';
                SET @o_MensajeTecnico = CONCAT_WS(' - ', ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE());
            END CATCH
        END
    END
    ELSE IF @w_Accion = 'S'
    BEGIN
        IF ISNULL(@i_PageNumber, 0) <= 0 OR ISNULL(@i_RowsPerPage, 0) <= 0
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'LOS PARAMETROS DE PAGINACION DEBEN SER MAYORES A CERO';
        END
        ELSE
        BEGIN
            BEGIN TRY
                SELECT rolId, rolName, rolCreationDate, rolCreatorId, rolModificationDate, rolModificatorId, rolEnable
                FROM [SQM_SECURITY].[TBL_Roles] WITH (NOLOCK)
                ORDER BY rolId
                OFFSET (@i_PageNumber - 1) * @i_RowsPerPage ROWS
                FETCH NEXT @i_RowsPerPage ROWS ONLY;
                IF @@ROWCOUNT > 0
                BEGIN
                    SET @o_Numero = 200;
                    SET @o_MensajeUsuario = 'REGISTROS LISTADOS CORRECTAMENTE';
                END
                ELSE
                BEGIN
                    SET @o_Numero = 204;
                    SET @o_MensajeUsuario = 'NO HAY MAS REGISTROS PARA LISTAR';
                END
            END TRY
            BEGIN CATCH
                SET @o_Numero = 500;
                SET @o_MensajeUsuario = 'ERROR AL LISTAR REGISTROS';
                SET @o_MensajeTecnico = CONCAT_WS(' - ', ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE());
            END CATCH
        END
    END
    ELSE
    BEGIN
        SET @o_Numero = 405;
        SET @o_MensajeUsuario = 'ACCION NO HABILITADA. USE I, U O S';
    END
END;
GO

CREATE OR ALTER PROC [SQM_CATALOGS].[USP_BusinessValues]
(
    @i_businessValueId INT = NULL,
    @i_businessValueName VARCHAR(80) = NULL,
    @i_businessValueCreationDate DATETIME = NULL,
    @i_businessValueCreatorId INT = NULL,
    @i_businessValueModificationDate DATETIME = NULL,
    @i_businessValueModificatorId INT = NULL,
    @i_businessValueEnable BIT = NULL,
    @i_PageNumber INT = 1,
    @i_RowsPerPage INT = 10,
    @w_Accion CHAR(1),
    @o_Numero INT = NULL OUT,
    @o_MensajeTecnico VARCHAR(500) = NULL OUT,
    @o_MensajeUsuario VARCHAR(500) = NULL OUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET @o_Numero = 0;
    SET @o_MensajeTecnico = NULL;
    SET @o_MensajeUsuario = NULL;

    IF @w_Accion = 'I'
    BEGIN
        BEGIN TRY
            INSERT INTO [SQM_CATALOGS].[TBL_BusinessValues] (businessValueName, businessValueCreationDate, businessValueCreatorId, businessValueModificationDate, businessValueModificatorId, businessValueEnable)
            VALUES (@i_businessValueName, COALESCE(@i_businessValueCreationDate, GETDATE()), @i_businessValueCreatorId, COALESCE(@i_businessValueModificationDate, GETDATE()), @i_businessValueModificatorId, COALESCE(@i_businessValueEnable, 1));
            SET @o_Numero = 201;
            SET @o_MensajeUsuario = 'BUSINESSVALUES REGISTRADO CORRECTAMENTE';
        END TRY
        BEGIN CATCH
            SET @o_Numero = 500;
            SET @o_MensajeUsuario = 'ERROR AL REGISTRAR BUSINESSVALUES';
            SET @o_MensajeTecnico = CONCAT_WS(' - ', ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE());
        END CATCH
    END
    ELSE IF @w_Accion = 'U'
    BEGIN
        IF ISNULL(@i_businessValueId, 0) = 0
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL ID ES OBLIGATORIO';
        END
        ELSE IF NOT EXISTS (SELECT 1 FROM [SQM_CATALOGS].[TBL_BusinessValues] WHERE businessValueId = @i_businessValueId)
        BEGIN
            SET @o_Numero = 404;
            SET @o_MensajeUsuario = 'EL REGISTRO NO EXISTE';
        END
        ELSE
        BEGIN
            BEGIN TRY
                UPDATE [SQM_CATALOGS].[TBL_BusinessValues]
                SET                 businessValueName = COALESCE(@i_businessValueName, businessValueName),
                businessValueModificationDate = GETDATE(),
                businessValueModificatorId = COALESCE(@i_businessValueModificatorId, businessValueModificatorId),
                businessValueEnable = COALESCE(@i_businessValueEnable, businessValueEnable)
                WHERE businessValueId = @i_businessValueId;
                SET @o_Numero = 200;
                SET @o_MensajeUsuario = 'REGISTRO ACTUALIZADO CORRECTAMENTE';
            END TRY
            BEGIN CATCH
                SET @o_Numero = 500;
                SET @o_MensajeUsuario = 'ERROR AL ACTUALIZAR REGISTRO';
                SET @o_MensajeTecnico = CONCAT_WS(' - ', ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE());
            END CATCH
        END
    END
    ELSE IF @w_Accion = 'S'
    BEGIN
        IF ISNULL(@i_PageNumber, 0) <= 0 OR ISNULL(@i_RowsPerPage, 0) <= 0
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'LOS PARAMETROS DE PAGINACION DEBEN SER MAYORES A CERO';
        END
        ELSE
        BEGIN
            BEGIN TRY
                SELECT businessValueId, businessValueName, businessValueCreationDate, businessValueCreatorId, businessValueModificationDate, businessValueModificatorId, businessValueEnable
                FROM [SQM_CATALOGS].[TBL_BusinessValues] WITH (NOLOCK)
                ORDER BY businessValueId
                OFFSET (@i_PageNumber - 1) * @i_RowsPerPage ROWS
                FETCH NEXT @i_RowsPerPage ROWS ONLY;
                IF @@ROWCOUNT > 0
                BEGIN
                    SET @o_Numero = 200;
                    SET @o_MensajeUsuario = 'REGISTROS LISTADOS CORRECTAMENTE';
                END
                ELSE
                BEGIN
                    SET @o_Numero = 204;
                    SET @o_MensajeUsuario = 'NO HAY MAS REGISTROS PARA LISTAR';
                END
            END TRY
            BEGIN CATCH
                SET @o_Numero = 500;
                SET @o_MensajeUsuario = 'ERROR AL LISTAR REGISTROS';
                SET @o_MensajeTecnico = CONCAT_WS(' - ', ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE());
            END CATCH
        END
    END
    ELSE
    BEGIN
        SET @o_Numero = 405;
        SET @o_MensajeUsuario = 'ACCION NO HABILITADA. USE I, U O S';
    END
END;
GO

CREATE OR ALTER PROC [SQM_GENERAL].[USP_Initiatives]
(
    @i_initiativeId INT = NULL,
    @i_initiativeSummary VARCHAR(200) = NULL,
    @i_initiativeDescription VARCHAR(2000) = NULL,
    @i_initiativeOwner INT = NULL,
    @i_initiativeGoals VARCHAR(255) = NULL,
    @i_initiativeBusinessValue INT = NULL,
    @i_initiativeTargetStart DATE = NULL,
    @i_initiativeTargetEnd DATE = NULL,
    @i_initiativeCreationDate DATETIME = NULL,
    @i_initiativeCreatorId INT = NULL,
    @i_initiativeModificationDate DATETIME = NULL,
    @i_initiativeModificatorId INT = NULL,
    @i_initiativeStatus INT = NULL,
    @i_PageNumber INT = 1,
    @i_RowsPerPage INT = 10,
    @w_Accion CHAR(1),
    @o_Numero INT = NULL OUT,
    @o_MensajeTecnico VARCHAR(500) = NULL OUT,
    @o_MensajeUsuario VARCHAR(500) = NULL OUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET @o_Numero = 0;
    SET @o_MensajeTecnico = NULL;
    SET @o_MensajeUsuario = NULL;

    IF @w_Accion = 'I'
    BEGIN
        BEGIN TRY
            INSERT INTO [SQM_GENERAL].[TBL_Initiatives] (initiativeSummary, initiativeDescription, initiativeOwner, initiativeGoals, initiativeBusinessValue, initiativeTargetStart, initiativeTargetEnd, initiativeCreationDate, initiativeCreatorId, initiativeModificationDate, initiativeModificatorId, initiativeStatus)
            VALUES (@i_initiativeSummary, @i_initiativeDescription, @i_initiativeOwner, @i_initiativeGoals, @i_initiativeBusinessValue, @i_initiativeTargetStart, @i_initiativeTargetEnd, COALESCE(@i_initiativeCreationDate, GETDATE()), @i_initiativeCreatorId, COALESCE(@i_initiativeModificationDate, GETDATE()), @i_initiativeModificatorId, @i_initiativeStatus);
            SET @o_Numero = 201;
            SET @o_MensajeUsuario = 'INITIATIVES REGISTRADO CORRECTAMENTE';
        END TRY
        BEGIN CATCH
            SET @o_Numero = 500;
            SET @o_MensajeUsuario = 'ERROR AL REGISTRAR INITIATIVES';
            SET @o_MensajeTecnico = CONCAT_WS(' - ', ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE());
        END CATCH
    END
    ELSE IF @w_Accion = 'U'
    BEGIN
        IF ISNULL(@i_initiativeId, 0) = 0
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL ID ES OBLIGATORIO';
        END
        ELSE IF NOT EXISTS (SELECT 1 FROM [SQM_GENERAL].[TBL_Initiatives] WHERE initiativeId = @i_initiativeId)
        BEGIN
            SET @o_Numero = 404;
            SET @o_MensajeUsuario = 'EL REGISTRO NO EXISTE';
        END
        ELSE
        BEGIN
            BEGIN TRY
                UPDATE [SQM_GENERAL].[TBL_Initiatives]
                SET                 initiativeSummary = COALESCE(@i_initiativeSummary, initiativeSummary),
                initiativeDescription = COALESCE(@i_initiativeDescription, initiativeDescription),
                initiativeOwner = COALESCE(@i_initiativeOwner, initiativeOwner),
                initiativeGoals = COALESCE(@i_initiativeGoals, initiativeGoals),
                initiativeBusinessValue = COALESCE(@i_initiativeBusinessValue, initiativeBusinessValue),
                initiativeTargetStart = COALESCE(@i_initiativeTargetStart, initiativeTargetStart),
                initiativeTargetEnd = COALESCE(@i_initiativeTargetEnd, initiativeTargetEnd),
                initiativeModificationDate = GETDATE(),
                initiativeModificatorId = COALESCE(@i_initiativeModificatorId, initiativeModificatorId),
                initiativeStatus = COALESCE(@i_initiativeStatus, initiativeStatus)
                WHERE initiativeId = @i_initiativeId;
                SET @o_Numero = 200;
                SET @o_MensajeUsuario = 'REGISTRO ACTUALIZADO CORRECTAMENTE';
            END TRY
            BEGIN CATCH
                SET @o_Numero = 500;
                SET @o_MensajeUsuario = 'ERROR AL ACTUALIZAR REGISTRO';
                SET @o_MensajeTecnico = CONCAT_WS(' - ', ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE());
            END CATCH
        END
    END
    ELSE IF @w_Accion = 'S'
    BEGIN
        IF ISNULL(@i_PageNumber, 0) <= 0 OR ISNULL(@i_RowsPerPage, 0) <= 0
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'LOS PARAMETROS DE PAGINACION DEBEN SER MAYORES A CERO';
        END
        ELSE
        BEGIN
            BEGIN TRY
                SELECT initiativeId, initiativeSummary, initiativeDescription, initiativeOwner, initiativeGoals, initiativeBusinessValue, initiativeTargetStart, initiativeTargetEnd, initiativeCreationDate, initiativeCreatorId, initiativeModificationDate, initiativeModificatorId, initiativeStatus
                FROM [SQM_GENERAL].[TBL_Initiatives] WITH (NOLOCK)
                ORDER BY initiativeId
                OFFSET (@i_PageNumber - 1) * @i_RowsPerPage ROWS
                FETCH NEXT @i_RowsPerPage ROWS ONLY;
                IF @@ROWCOUNT > 0
                BEGIN
                    SET @o_Numero = 200;
                    SET @o_MensajeUsuario = 'REGISTROS LISTADOS CORRECTAMENTE';
                END
                ELSE
                BEGIN
                    SET @o_Numero = 204;
                    SET @o_MensajeUsuario = 'NO HAY MAS REGISTROS PARA LISTAR';
                END
            END TRY
            BEGIN CATCH
                SET @o_Numero = 500;
                SET @o_MensajeUsuario = 'ERROR AL LISTAR REGISTROS';
                SET @o_MensajeTecnico = CONCAT_WS(' - ', ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE());
            END CATCH
        END
    END
    ELSE
    BEGIN
        SET @o_Numero = 405;
        SET @o_MensajeUsuario = 'ACCION NO HABILITADA. USE I, U O S';
    END
END;
GO

CREATE OR ALTER PROC [SQM_CATALOGS].[USP_Priorities]
(
    @i_priorityId INT = NULL,
    @i_priorityName VARCHAR(80) = NULL,
    @i_priorityCreationDate DATETIME = NULL,
    @i_priorityCreatorId INT = NULL,
    @i_priorityModificationDate DATETIME = NULL,
    @i_priorityModificatorId INT = NULL,
    @i_priorityEnable BIT = NULL,
    @i_PageNumber INT = 1,
    @i_RowsPerPage INT = 10,
    @w_Accion CHAR(1),
    @o_Numero INT = NULL OUT,
    @o_MensajeTecnico VARCHAR(500) = NULL OUT,
    @o_MensajeUsuario VARCHAR(500) = NULL OUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET @o_Numero = 0;
    SET @o_MensajeTecnico = NULL;
    SET @o_MensajeUsuario = NULL;

    IF @w_Accion = 'I'
    BEGIN
        BEGIN TRY
            INSERT INTO [SQM_CATALOGS].[TBL_Priorities] (priorityName, priorityCreationDate, priorityCreatorId, priorityModificationDate, priorityModificatorId, priorityEnable)
            VALUES (@i_priorityName, COALESCE(@i_priorityCreationDate, GETDATE()), @i_priorityCreatorId, COALESCE(@i_priorityModificationDate, GETDATE()), @i_priorityModificatorId, COALESCE(@i_priorityEnable, 1));
            SET @o_Numero = 201;
            SET @o_MensajeUsuario = 'PRIORITIES REGISTRADO CORRECTAMENTE';
        END TRY
        BEGIN CATCH
            SET @o_Numero = 500;
            SET @o_MensajeUsuario = 'ERROR AL REGISTRAR PRIORITIES';
            SET @o_MensajeTecnico = CONCAT_WS(' - ', ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE());
        END CATCH
    END
    ELSE IF @w_Accion = 'U'
    BEGIN
        IF ISNULL(@i_priorityId, 0) = 0
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL ID ES OBLIGATORIO';
        END
        ELSE IF NOT EXISTS (SELECT 1 FROM [SQM_CATALOGS].[TBL_Priorities] WHERE priorityId = @i_priorityId)
        BEGIN
            SET @o_Numero = 404;
            SET @o_MensajeUsuario = 'EL REGISTRO NO EXISTE';
        END
        ELSE
        BEGIN
            BEGIN TRY
                UPDATE [SQM_CATALOGS].[TBL_Priorities]
                SET                 priorityName = COALESCE(@i_priorityName, priorityName),
                priorityModificationDate = GETDATE(),
                priorityModificatorId = COALESCE(@i_priorityModificatorId, priorityModificatorId),
                priorityEnable = COALESCE(@i_priorityEnable, priorityEnable)
                WHERE priorityId = @i_priorityId;
                SET @o_Numero = 200;
                SET @o_MensajeUsuario = 'REGISTRO ACTUALIZADO CORRECTAMENTE';
            END TRY
            BEGIN CATCH
                SET @o_Numero = 500;
                SET @o_MensajeUsuario = 'ERROR AL ACTUALIZAR REGISTRO';
                SET @o_MensajeTecnico = CONCAT_WS(' - ', ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE());
            END CATCH
        END
    END
    ELSE IF @w_Accion = 'S'
    BEGIN
        IF ISNULL(@i_PageNumber, 0) <= 0 OR ISNULL(@i_RowsPerPage, 0) <= 0
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'LOS PARAMETROS DE PAGINACION DEBEN SER MAYORES A CERO';
        END
        ELSE
        BEGIN
            BEGIN TRY
                SELECT priorityId, priorityName, priorityCreationDate, priorityCreatorId, priorityModificationDate, priorityModificatorId, priorityEnable
                FROM [SQM_CATALOGS].[TBL_Priorities] WITH (NOLOCK)
                ORDER BY priorityId
                OFFSET (@i_PageNumber - 1) * @i_RowsPerPage ROWS
                FETCH NEXT @i_RowsPerPage ROWS ONLY;
                IF @@ROWCOUNT > 0
                BEGIN
                    SET @o_Numero = 200;
                    SET @o_MensajeUsuario = 'REGISTROS LISTADOS CORRECTAMENTE';
                END
                ELSE
                BEGIN
                    SET @o_Numero = 204;
                    SET @o_MensajeUsuario = 'NO HAY MAS REGISTROS PARA LISTAR';
                END
            END TRY
            BEGIN CATCH
                SET @o_Numero = 500;
                SET @o_MensajeUsuario = 'ERROR AL LISTAR REGISTROS';
                SET @o_MensajeTecnico = CONCAT_WS(' - ', ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE());
            END CATCH
        END
    END
    ELSE
    BEGIN
        SET @o_Numero = 405;
        SET @o_MensajeUsuario = 'ACCION NO HABILITADA. USE I, U O S';
    END
END;
GO

CREATE OR ALTER PROC [SQM_GENERAL].[USP_Epics]
(
    @i_epicId INT = NULL,
    @i_epicName VARCHAR(100) = NULL,
    @i_epicSummary VARCHAR(500) = NULL,
    @i_epicDescription VARCHAR(4000) = NULL,
    @i_epicParentLink INT = NULL,
    @i_epicOwner INT = NULL,
    @i_epicStartDate DATE = NULL,
    @i_epicDueDate DATE = NULL,
    @i_epicPriority INT = NULL,
    @i_epicCreationDate DATETIME = NULL,
    @i_epicCreatorId INT = NULL,
    @i_epicModificationDate DATETIME = NULL,
    @i_epicModificatorId INT = NULL,
    @i_epicStatus INT = NULL,
    @i_PageNumber INT = 1,
    @i_RowsPerPage INT = 10,
    @w_Accion CHAR(1),
    @o_Numero INT = NULL OUT,
    @o_MensajeTecnico VARCHAR(500) = NULL OUT,
    @o_MensajeUsuario VARCHAR(500) = NULL OUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET @o_Numero = 0;
    SET @o_MensajeTecnico = NULL;
    SET @o_MensajeUsuario = NULL;

    IF @w_Accion = 'I'
    BEGIN
        BEGIN TRY
            INSERT INTO [SQM_GENERAL].[TBL_Epics] (epicName, epicSummary, epicDescription, epicParentLink, epicOwner, epicStartDate, epicDueDate, epicPriority, epicCreationDate, epicCreatorId, epicModificationDate, epicModificatorId, epicStatus)
            VALUES (@i_epicName, @i_epicSummary, @i_epicDescription, @i_epicParentLink, @i_epicOwner, @i_epicStartDate, @i_epicDueDate, @i_epicPriority, COALESCE(@i_epicCreationDate, GETDATE()), @i_epicCreatorId, COALESCE(@i_epicModificationDate, GETDATE()), @i_epicModificatorId, @i_epicStatus);
            SET @o_Numero = 201;
            SET @o_MensajeUsuario = 'EPICS REGISTRADO CORRECTAMENTE';
        END TRY
        BEGIN CATCH
            SET @o_Numero = 500;
            SET @o_MensajeUsuario = 'ERROR AL REGISTRAR EPICS';
            SET @o_MensajeTecnico = CONCAT_WS(' - ', ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE());
        END CATCH
    END
    ELSE IF @w_Accion = 'U'
    BEGIN
        IF ISNULL(@i_epicId, 0) = 0
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL ID ES OBLIGATORIO';
        END
        ELSE IF NOT EXISTS (SELECT 1 FROM [SQM_GENERAL].[TBL_Epics] WHERE epicId = @i_epicId)
        BEGIN
            SET @o_Numero = 404;
            SET @o_MensajeUsuario = 'EL REGISTRO NO EXISTE';
        END
        ELSE
        BEGIN
            BEGIN TRY
                UPDATE [SQM_GENERAL].[TBL_Epics]
                SET                 epicName = COALESCE(@i_epicName, epicName),
                epicSummary = COALESCE(@i_epicSummary, epicSummary),
                epicDescription = COALESCE(@i_epicDescription, epicDescription),
                epicParentLink = COALESCE(@i_epicParentLink, epicParentLink),
                epicOwner = COALESCE(@i_epicOwner, epicOwner),
                epicStartDate = COALESCE(@i_epicStartDate, epicStartDate),
                epicDueDate = COALESCE(@i_epicDueDate, epicDueDate),
                epicPriority = COALESCE(@i_epicPriority, epicPriority),
                epicModificationDate = GETDATE(),
                epicModificatorId = COALESCE(@i_epicModificatorId, epicModificatorId),
                epicStatus = COALESCE(@i_epicStatus, epicStatus)
                WHERE epicId = @i_epicId;
                SET @o_Numero = 200;
                SET @o_MensajeUsuario = 'REGISTRO ACTUALIZADO CORRECTAMENTE';
            END TRY
            BEGIN CATCH
                SET @o_Numero = 500;
                SET @o_MensajeUsuario = 'ERROR AL ACTUALIZAR REGISTRO';
                SET @o_MensajeTecnico = CONCAT_WS(' - ', ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE());
            END CATCH
        END
    END
    ELSE IF @w_Accion = 'S'
    BEGIN
        IF ISNULL(@i_PageNumber, 0) <= 0 OR ISNULL(@i_RowsPerPage, 0) <= 0
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'LOS PARAMETROS DE PAGINACION DEBEN SER MAYORES A CERO';
        END
        ELSE
        BEGIN
            BEGIN TRY
                SELECT epicId, epicName, epicSummary, epicDescription, epicParentLink, epicOwner, epicStartDate, epicDueDate, epicPriority, epicCreationDate, epicCreatorId, epicModificationDate, epicModificatorId, epicStatus
                FROM [SQM_GENERAL].[TBL_Epics] WITH (NOLOCK)
                ORDER BY epicId
                OFFSET (@i_PageNumber - 1) * @i_RowsPerPage ROWS
                FETCH NEXT @i_RowsPerPage ROWS ONLY;
                IF @@ROWCOUNT > 0
                BEGIN
                    SET @o_Numero = 200;
                    SET @o_MensajeUsuario = 'REGISTROS LISTADOS CORRECTAMENTE';
                END
                ELSE
                BEGIN
                    SET @o_Numero = 204;
                    SET @o_MensajeUsuario = 'NO HAY MAS REGISTROS PARA LISTAR';
                END
            END TRY
            BEGIN CATCH
                SET @o_Numero = 500;
                SET @o_MensajeUsuario = 'ERROR AL LISTAR REGISTROS';
                SET @o_MensajeTecnico = CONCAT_WS(' - ', ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE());
            END CATCH
        END
    END
    ELSE
    BEGIN
        SET @o_Numero = 405;
        SET @o_MensajeUsuario = 'ACCION NO HABILITADA. USE I, U O S';
    END
END;
GO

CREATE OR ALTER PROC [SQM_GENERAL].[USP_Features]
(
    @i_featureId INT = NULL,
    @i_featureSummary VARCHAR(500) = NULL,
    @i_featureDescription VARCHAR(2000) = NULL,
    @i_featuresAcceptanceCriteria VARCHAR(4000) = NULL,
    @i_featureParentLink INT = NULL,
    @i_featureOwner INT = NULL,
    @i_featureStartDate DATE = NULL,
    @i_featureDueDate DATE = NULL,
    @i_featurePriority INT = NULL,
    @i_featureCreationDate DATETIME = NULL,
    @i_featureCreatorId INT = NULL,
    @i_featureModificationDate DATETIME = NULL,
    @i_featureModificatorId INT = NULL,
    @i_featureStatus INT = NULL,
    @i_PageNumber INT = 1,
    @i_RowsPerPage INT = 10,
    @w_Accion CHAR(1),
    @o_Numero INT = NULL OUT,
    @o_MensajeTecnico VARCHAR(500) = NULL OUT,
    @o_MensajeUsuario VARCHAR(500) = NULL OUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET @o_Numero = 0;
    SET @o_MensajeTecnico = NULL;
    SET @o_MensajeUsuario = NULL;

    IF @w_Accion = 'I'
    BEGIN
        BEGIN TRY
            INSERT INTO [SQM_GENERAL].[TBL_Features] (featureSummary, featureDescription, featuresAcceptanceCriteria, featureParentLink, featureOwner, featureStartDate, featureDueDate, featurePriority, featureCreationDate, featureCreatorId, featureModificationDate, featureModificatorId, featureStatus)
            VALUES (@i_featureSummary, @i_featureDescription, @i_featuresAcceptanceCriteria, @i_featureParentLink, @i_featureOwner, @i_featureStartDate, @i_featureDueDate, @i_featurePriority, COALESCE(@i_featureCreationDate, GETDATE()), @i_featureCreatorId, COALESCE(@i_featureModificationDate, GETDATE()), @i_featureModificatorId, @i_featureStatus);
            SET @o_Numero = 201;
            SET @o_MensajeUsuario = 'FEATURES REGISTRADO CORRECTAMENTE';
        END TRY
        BEGIN CATCH
            SET @o_Numero = 500;
            SET @o_MensajeUsuario = 'ERROR AL REGISTRAR FEATURES';
            SET @o_MensajeTecnico = CONCAT_WS(' - ', ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE());
        END CATCH
    END
    ELSE IF @w_Accion = 'U'
    BEGIN
        IF ISNULL(@i_featureId, 0) = 0
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL ID ES OBLIGATORIO';
        END
        ELSE IF NOT EXISTS (SELECT 1 FROM [SQM_GENERAL].[TBL_Features] WHERE featureId = @i_featureId)
        BEGIN
            SET @o_Numero = 404;
            SET @o_MensajeUsuario = 'EL REGISTRO NO EXISTE';
        END
        ELSE
        BEGIN
            BEGIN TRY
                UPDATE [SQM_GENERAL].[TBL_Features]
                SET                 featureSummary = COALESCE(@i_featureSummary, featureSummary),
                featureDescription = COALESCE(@i_featureDescription, featureDescription),
                featuresAcceptanceCriteria = COALESCE(@i_featuresAcceptanceCriteria, featuresAcceptanceCriteria),
                featureParentLink = COALESCE(@i_featureParentLink, featureParentLink),
                featureOwner = COALESCE(@i_featureOwner, featureOwner),
                featureStartDate = COALESCE(@i_featureStartDate, featureStartDate),
                featureDueDate = COALESCE(@i_featureDueDate, featureDueDate),
                featurePriority = COALESCE(@i_featurePriority, featurePriority),
                featureModificationDate = GETDATE(),
                featureModificatorId = COALESCE(@i_featureModificatorId, featureModificatorId),
                featureStatus = COALESCE(@i_featureStatus, featureStatus)
                WHERE featureId = @i_featureId;
                SET @o_Numero = 200;
                SET @o_MensajeUsuario = 'REGISTRO ACTUALIZADO CORRECTAMENTE';
            END TRY
            BEGIN CATCH
                SET @o_Numero = 500;
                SET @o_MensajeUsuario = 'ERROR AL ACTUALIZAR REGISTRO';
                SET @o_MensajeTecnico = CONCAT_WS(' - ', ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE());
            END CATCH
        END
    END
    ELSE IF @w_Accion = 'S'
    BEGIN
        IF ISNULL(@i_PageNumber, 0) <= 0 OR ISNULL(@i_RowsPerPage, 0) <= 0
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'LOS PARAMETROS DE PAGINACION DEBEN SER MAYORES A CERO';
        END
        ELSE
        BEGIN
            BEGIN TRY
                SELECT featureId, featureSummary, featureDescription, featuresAcceptanceCriteria, featureParentLink, featureOwner, featureStartDate, featureDueDate, featurePriority, featureCreationDate, featureCreatorId, featureModificationDate, featureModificatorId, featureStatus
                FROM [SQM_GENERAL].[TBL_Features] WITH (NOLOCK)
                ORDER BY featureId
                OFFSET (@i_PageNumber - 1) * @i_RowsPerPage ROWS
                FETCH NEXT @i_RowsPerPage ROWS ONLY;
                IF @@ROWCOUNT > 0
                BEGIN
                    SET @o_Numero = 200;
                    SET @o_MensajeUsuario = 'REGISTROS LISTADOS CORRECTAMENTE';
                END
                ELSE
                BEGIN
                    SET @o_Numero = 204;
                    SET @o_MensajeUsuario = 'NO HAY MAS REGISTROS PARA LISTAR';
                END
            END TRY
            BEGIN CATCH
                SET @o_Numero = 500;
                SET @o_MensajeUsuario = 'ERROR AL LISTAR REGISTROS';
                SET @o_MensajeTecnico = CONCAT_WS(' - ', ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE());
            END CATCH
        END
    END
    ELSE
    BEGIN
        SET @o_Numero = 405;
        SET @o_MensajeUsuario = 'ACCION NO HABILITADA. USE I, U O S';
    END
END;
GO

CREATE OR ALTER PROC [SQM_CATALOGS].[USP_ActivityTypes]
(
    @i_activityTypeId INT = NULL,
    @i_activityTypeName VARCHAR(80) = NULL,
    @i_activityTypeCreationDate DATETIME = NULL,
    @i_activityTypeCreatorId INT = NULL,
    @i_activityTypeModificationDate DATETIME = NULL,
    @i_activityTypeModificatorId INT = NULL,
    @i_activityTypeEnable BIT = NULL,
    @i_PageNumber INT = 1,
    @i_RowsPerPage INT = 10,
    @w_Accion CHAR(1),
    @o_Numero INT = NULL OUT,
    @o_MensajeTecnico VARCHAR(500) = NULL OUT,
    @o_MensajeUsuario VARCHAR(500) = NULL OUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET @o_Numero = 0;
    SET @o_MensajeTecnico = NULL;
    SET @o_MensajeUsuario = NULL;

    IF @w_Accion = 'I'
    BEGIN
        BEGIN TRY
            INSERT INTO [SQM_CATALOGS].[TBL_ActivityTypes] (activityTypeName, activityTypeCreationDate, activityTypeCreatorId, activityTypeModificationDate, activityTypeModificatorId, activityTypeEnable)
            VALUES (@i_activityTypeName, COALESCE(@i_activityTypeCreationDate, GETDATE()), @i_activityTypeCreatorId, COALESCE(@i_activityTypeModificationDate, GETDATE()), @i_activityTypeModificatorId, COALESCE(@i_activityTypeEnable, 1));
            SET @o_Numero = 201;
            SET @o_MensajeUsuario = 'ACTIVITYTYPES REGISTRADO CORRECTAMENTE';
        END TRY
        BEGIN CATCH
            SET @o_Numero = 500;
            SET @o_MensajeUsuario = 'ERROR AL REGISTRAR ACTIVITYTYPES';
            SET @o_MensajeTecnico = CONCAT_WS(' - ', ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE());
        END CATCH
    END
    ELSE IF @w_Accion = 'U'
    BEGIN
        IF ISNULL(@i_activityTypeId, 0) = 0
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL ID ES OBLIGATORIO';
        END
        ELSE IF NOT EXISTS (SELECT 1 FROM [SQM_CATALOGS].[TBL_ActivityTypes] WHERE activityTypeId = @i_activityTypeId)
        BEGIN
            SET @o_Numero = 404;
            SET @o_MensajeUsuario = 'EL REGISTRO NO EXISTE';
        END
        ELSE
        BEGIN
            BEGIN TRY
                UPDATE [SQM_CATALOGS].[TBL_ActivityTypes]
                SET                 activityTypeName = COALESCE(@i_activityTypeName, activityTypeName),
                activityTypeModificationDate = GETDATE(),
                activityTypeModificatorId = COALESCE(@i_activityTypeModificatorId, activityTypeModificatorId),
                activityTypeEnable = COALESCE(@i_activityTypeEnable, activityTypeEnable)
                WHERE activityTypeId = @i_activityTypeId;
                SET @o_Numero = 200;
                SET @o_MensajeUsuario = 'REGISTRO ACTUALIZADO CORRECTAMENTE';
            END TRY
            BEGIN CATCH
                SET @o_Numero = 500;
                SET @o_MensajeUsuario = 'ERROR AL ACTUALIZAR REGISTRO';
                SET @o_MensajeTecnico = CONCAT_WS(' - ', ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE());
            END CATCH
        END
    END
    ELSE IF @w_Accion = 'S'
    BEGIN
        IF ISNULL(@i_PageNumber, 0) <= 0 OR ISNULL(@i_RowsPerPage, 0) <= 0
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'LOS PARAMETROS DE PAGINACION DEBEN SER MAYORES A CERO';
        END
        ELSE
        BEGIN
            BEGIN TRY
                SELECT activityTypeId, activityTypeName, activityTypeCreationDate, activityTypeCreatorId, activityTypeModificationDate, activityTypeModificatorId, activityTypeEnable
                FROM [SQM_CATALOGS].[TBL_ActivityTypes] WITH (NOLOCK)
                ORDER BY activityTypeId
                OFFSET (@i_PageNumber - 1) * @i_RowsPerPage ROWS
                FETCH NEXT @i_RowsPerPage ROWS ONLY;
                IF @@ROWCOUNT > 0
                BEGIN
                    SET @o_Numero = 200;
                    SET @o_MensajeUsuario = 'REGISTROS LISTADOS CORRECTAMENTE';
                END
                ELSE
                BEGIN
                    SET @o_Numero = 204;
                    SET @o_MensajeUsuario = 'NO HAY MAS REGISTROS PARA LISTAR';
                END
            END TRY
            BEGIN CATCH
                SET @o_Numero = 500;
                SET @o_MensajeUsuario = 'ERROR AL LISTAR REGISTROS';
                SET @o_MensajeTecnico = CONCAT_WS(' - ', ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE());
            END CATCH
        END
    END
    ELSE
    BEGIN
        SET @o_Numero = 405;
        SET @o_MensajeUsuario = 'ACCION NO HABILITADA. USE I, U O S';
    END
END;
GO

CREATE OR ALTER PROC [SQM_GENERAL].[USP_Tasks]
(
    @i_taskId INT = NULL,
    @i_taskSummary VARCHAR(500) = NULL,
    @i_taskDescription VARCHAR(2000) = NULL,
    @i_taskOwner INT = NULL,
    @i_taskParentLink INT = NULL,
    @i_taskOriginalEstimate DECIMAL(4,2) = NULL,
    @i_taskCompletedWork DECIMAL(4,2) = NULL,
    @i_taskRemaningWork DECIMAL(4,2) = NULL,
    @i_taskStartDate DATE = NULL,
    @i_taskCompletedDate DATE = NULL,
    @i_taskDueDate DATE = NULL,
    @i_taskActivityType INT = NULL,
    @i_taskCreationDate DATETIME = NULL,
    @i_taskCreatorId INT = NULL,
    @i_taskModificationDate DATETIME = NULL,
    @i_taskModificatorId INT = NULL,
    @i_taskStatus INT = NULL,
    @i_PageNumber INT = 1,
    @i_RowsPerPage INT = 10,
    @w_Accion CHAR(1),
    @o_Numero INT = NULL OUT,
    @o_MensajeTecnico VARCHAR(500) = NULL OUT,
    @o_MensajeUsuario VARCHAR(500) = NULL OUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET @o_Numero = 0;
    SET @o_MensajeTecnico = NULL;
    SET @o_MensajeUsuario = NULL;

    IF @w_Accion = 'I'
    BEGIN
        BEGIN TRY
            INSERT INTO [SQM_GENERAL].[TBL_Tasks] (taskSummary, taskDescription, taskOwner, taskParentLink, taskOriginalEstimate, taskCompletedWork, taskRemaningWork, taskStartDate, taskCompletedDate, taskDueDate, taskActivityType, taskCreationDate, taskCreatorId, taskModificationDate, taskModificatorId, taskStatus)
            VALUES (@i_taskSummary, @i_taskDescription, @i_taskOwner, @i_taskParentLink, @i_taskOriginalEstimate, @i_taskCompletedWork, @i_taskRemaningWork, @i_taskStartDate, @i_taskCompletedDate, @i_taskDueDate, @i_taskActivityType, COALESCE(@i_taskCreationDate, GETDATE()), @i_taskCreatorId, COALESCE(@i_taskModificationDate, GETDATE()), @i_taskModificatorId, @i_taskStatus);
            SET @o_Numero = 201;
            SET @o_MensajeUsuario = 'TASKS REGISTRADO CORRECTAMENTE';
        END TRY
        BEGIN CATCH
            SET @o_Numero = 500;
            SET @o_MensajeUsuario = 'ERROR AL REGISTRAR TASKS';
            SET @o_MensajeTecnico = CONCAT_WS(' - ', ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE());
        END CATCH
    END
    ELSE IF @w_Accion = 'U'
    BEGIN
        IF ISNULL(@i_taskId, 0) = 0
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL ID ES OBLIGATORIO';
        END
        ELSE IF NOT EXISTS (SELECT 1 FROM [SQM_GENERAL].[TBL_Tasks] WHERE taskId = @i_taskId)
        BEGIN
            SET @o_Numero = 404;
            SET @o_MensajeUsuario = 'EL REGISTRO NO EXISTE';
        END
        ELSE
        BEGIN
            BEGIN TRY
                UPDATE [SQM_GENERAL].[TBL_Tasks]
                SET                 taskSummary = COALESCE(@i_taskSummary, taskSummary),
                taskDescription = COALESCE(@i_taskDescription, taskDescription),
                taskOwner = COALESCE(@i_taskOwner, taskOwner),
                taskParentLink = COALESCE(@i_taskParentLink, taskParentLink),
                taskOriginalEstimate = COALESCE(@i_taskOriginalEstimate, taskOriginalEstimate),
                taskCompletedWork = COALESCE(@i_taskCompletedWork, taskCompletedWork),
                taskRemaningWork = COALESCE(@i_taskRemaningWork, taskRemaningWork),
                taskStartDate = COALESCE(@i_taskStartDate, taskStartDate),
                taskCompletedDate = COALESCE(@i_taskCompletedDate, taskCompletedDate),
                taskDueDate = COALESCE(@i_taskDueDate, taskDueDate),
                taskActivityType = COALESCE(@i_taskActivityType, taskActivityType),
                taskModificationDate = GETDATE(),
                taskModificatorId = COALESCE(@i_taskModificatorId, taskModificatorId),
                taskStatus = COALESCE(@i_taskStatus, taskStatus)
                WHERE taskId = @i_taskId;
                SET @o_Numero = 200;
                SET @o_MensajeUsuario = 'REGISTRO ACTUALIZADO CORRECTAMENTE';
            END TRY
            BEGIN CATCH
                SET @o_Numero = 500;
                SET @o_MensajeUsuario = 'ERROR AL ACTUALIZAR REGISTRO';
                SET @o_MensajeTecnico = CONCAT_WS(' - ', ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE());
            END CATCH
        END
    END
    ELSE IF @w_Accion = 'S'
    BEGIN
        IF ISNULL(@i_PageNumber, 0) <= 0 OR ISNULL(@i_RowsPerPage, 0) <= 0
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'LOS PARAMETROS DE PAGINACION DEBEN SER MAYORES A CERO';
        END
        ELSE
        BEGIN
            BEGIN TRY
                SELECT taskId, taskSummary, taskDescription, taskOwner, taskParentLink, taskOriginalEstimate, taskCompletedWork, taskRemaningWork, taskStartDate, taskCompletedDate, taskDueDate, taskActivityType, taskCreationDate, taskCreatorId, taskModificationDate, taskModificatorId, taskStatus
                FROM [SQM_GENERAL].[TBL_Tasks] WITH (NOLOCK)
                ORDER BY taskId
                OFFSET (@i_PageNumber - 1) * @i_RowsPerPage ROWS
                FETCH NEXT @i_RowsPerPage ROWS ONLY;
                IF @@ROWCOUNT > 0
                BEGIN
                    SET @o_Numero = 200;
                    SET @o_MensajeUsuario = 'REGISTROS LISTADOS CORRECTAMENTE';
                END
                ELSE
                BEGIN
                    SET @o_Numero = 204;
                    SET @o_MensajeUsuario = 'NO HAY MAS REGISTROS PARA LISTAR';
                END
            END TRY
            BEGIN CATCH
                SET @o_Numero = 500;
                SET @o_MensajeUsuario = 'ERROR AL LISTAR REGISTROS';
                SET @o_MensajeTecnico = CONCAT_WS(' - ', ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE());
            END CATCH
        END
    END
    ELSE
    BEGIN
        SET @o_Numero = 405;
        SET @o_MensajeUsuario = 'ACCION NO HABILITADA. USE I, U O S';
    END
END;
GO

CREATE OR ALTER PROC [SQM_GENERAL].[USP_TaskComments]
(
    @i_taskCommentId INT = NULL,
    @i_taskCommentParentLink INT = NULL,
    @i_taskCommentOwner INT = NULL,
    @i_taskCommentText NVARCHAR(4000) = NULL,
    @i_taskCommentCreationDate DATETIME = NULL,
    @i_taskCommentCreatorId INT = NULL,
    @i_taskCommentModificationDate DATETIME = NULL,
    @i_taskCommentModificatorId INT = NULL,
    @i_taskCommentStatus BIT = NULL,
    @i_PageNumber INT = 1,
    @i_RowsPerPage INT = 10,
    @w_Accion CHAR(1),
    @o_Numero INT = NULL OUT,
    @o_MensajeTecnico VARCHAR(500) = NULL OUT,
    @o_MensajeUsuario VARCHAR(500) = NULL OUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET @o_Numero = 0;
    SET @o_MensajeTecnico = NULL;
    SET @o_MensajeUsuario = NULL;

    IF @w_Accion = 'I'
    BEGIN
        BEGIN TRY
            INSERT INTO [SQM_GENERAL].[TBL_TaskComments] (taskCommentParentLink, taskCommentOwner, taskCommentText, taskCommentCreationDate, taskCommentCreatorId, taskCommentModificationDate, taskCommentModificatorId, taskCommentStatus)
            VALUES (@i_taskCommentParentLink, @i_taskCommentOwner, @i_taskCommentText, COALESCE(@i_taskCommentCreationDate, GETDATE()), @i_taskCommentCreatorId, COALESCE(@i_taskCommentModificationDate, GETDATE()), @i_taskCommentModificatorId, COALESCE(@i_taskCommentStatus, 1));
            SET @o_Numero = 201;
            SET @o_MensajeUsuario = 'TASKCOMMENTS REGISTRADO CORRECTAMENTE';
        END TRY
        BEGIN CATCH
            SET @o_Numero = 500;
            SET @o_MensajeUsuario = 'ERROR AL REGISTRAR TASKCOMMENTS';
            SET @o_MensajeTecnico = CONCAT_WS(' - ', ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE());
        END CATCH
    END
    ELSE IF @w_Accion = 'U'
    BEGIN
        IF ISNULL(@i_taskCommentId, 0) = 0
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'EL ID ES OBLIGATORIO';
        END
        ELSE IF NOT EXISTS (SELECT 1 FROM [SQM_GENERAL].[TBL_TaskComments] WHERE taskCommentId = @i_taskCommentId)
        BEGIN
            SET @o_Numero = 404;
            SET @o_MensajeUsuario = 'EL REGISTRO NO EXISTE';
        END
        ELSE
        BEGIN
            BEGIN TRY
                UPDATE [SQM_GENERAL].[TBL_TaskComments]
                SET                 taskCommentParentLink = COALESCE(@i_taskCommentParentLink, taskCommentParentLink),
                taskCommentOwner = COALESCE(@i_taskCommentOwner, taskCommentOwner),
                taskCommentText = COALESCE(@i_taskCommentText, taskCommentText),
                taskCommentModificationDate = GETDATE(),
                taskCommentModificatorId = COALESCE(@i_taskCommentModificatorId, taskCommentModificatorId),
                taskCommentStatus = COALESCE(@i_taskCommentStatus, taskCommentStatus)
                WHERE taskCommentId = @i_taskCommentId;
                SET @o_Numero = 200;
                SET @o_MensajeUsuario = 'REGISTRO ACTUALIZADO CORRECTAMENTE';
            END TRY
            BEGIN CATCH
                SET @o_Numero = 500;
                SET @o_MensajeUsuario = 'ERROR AL ACTUALIZAR REGISTRO';
                SET @o_MensajeTecnico = CONCAT_WS(' - ', ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE());
            END CATCH
        END
    END
    ELSE IF @w_Accion = 'S'
    BEGIN
        IF ISNULL(@i_PageNumber, 0) <= 0 OR ISNULL(@i_RowsPerPage, 0) <= 0
        BEGIN
            SET @o_Numero = 400;
            SET @o_MensajeUsuario = 'LOS PARAMETROS DE PAGINACION DEBEN SER MAYORES A CERO';
        END
        ELSE
        BEGIN
            BEGIN TRY
                SELECT taskCommentId, taskCommentParentLink, taskCommentOwner, taskCommentText, taskCommentCreationDate, taskCommentCreatorId, taskCommentModificationDate, taskCommentModificatorId, taskCommentStatus
                FROM [SQM_GENERAL].[TBL_TaskComments] WITH (NOLOCK)
                ORDER BY taskCommentId
                OFFSET (@i_PageNumber - 1) * @i_RowsPerPage ROWS
                FETCH NEXT @i_RowsPerPage ROWS ONLY;
                IF @@ROWCOUNT > 0
                BEGIN
                    SET @o_Numero = 200;
                    SET @o_MensajeUsuario = 'REGISTROS LISTADOS CORRECTAMENTE';
                END
                ELSE
                BEGIN
                    SET @o_Numero = 204;
                    SET @o_MensajeUsuario = 'NO HAY MAS REGISTROS PARA LISTAR';
                END
            END TRY
            BEGIN CATCH
                SET @o_Numero = 500;
                SET @o_MensajeUsuario = 'ERROR AL LISTAR REGISTROS';
                SET @o_MensajeTecnico = CONCAT_WS(' - ', ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE());
            END CATCH
        END
    END
    ELSE
    BEGIN
        SET @o_Numero = 405;
        SET @o_MensajeUsuario = 'ACCION NO HABILITADA. USE I, U O S';
    END
END;
GO
