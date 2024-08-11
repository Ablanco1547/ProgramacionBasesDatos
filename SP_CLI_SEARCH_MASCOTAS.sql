USE veterinaria_bd

SELECT * FROM dbo.Mascotas

SELECT * FROM Mascotas

CREATE PROCEDURE SP_CLI_SEARCH_MASCOTAS
    @nombreMascota NVARCHAR(100),
    @pi_codigo_salida INT OUTPUT,
    @pv_descripcion_salida NVARCHAR(4000) OUTPUT
AS 
BEGIN
    BEGIN TRY

	declare @nombre_sp varchar(60)='SP_CLI_SEARCH_MASCOTAS';
        -- COMIENZA TRANSACCION
        BEGIN TRANSACTION;
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

        -- CREACION TABLA TEMPORAL
        CREATE TABLE #tempMascotas(
            nombre NVARCHAR(100),
            especie NVARCHAR(50),
            raza NVARCHAR(50)
        ); 

        
        INSERT INTO #tempMascotas(nombre, especie, raza)
        
		
        SELECT M.Nombre, M.Especie, M.Raza
        FROM Mascotas M
        WHERE M.Nombre LIKE @nombreMascota;
        
       
        IF NOT EXISTS (SELECT 1 FROM #tempMascotas)
        BEGIN 
            SET @pi_codigo_salida = 400;
            SET @pv_descripcion_salida = 'No se encontro la mascota';
            ROLLBACK TRANSACTION;

			INSERT INTO [veterinaria_bd].[dbo].[TransaccionesLog]
				([CodigoRespuesta],[Descripcion],[Proceso],[NombreUsuario],[FechaRegistro])
				  VALUES(
				  @pi_codigo_salida,
				  @pv_descripcion_salida,
				  @nombre_sp,
				  USER_NAME(),
				  GETDATE()
				  );



            RETURN;








        END

        -- SE CONFIRMA LA TRANSACCION
        COMMIT TRANSACTION;
        SET @pi_codigo_salida = 200;
        SET @pv_descripcion_salida = 'La busqueda fue exitosa';

        -- seleccion de resultados
        SELECT * FROM #tempMascotas;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN 
            ROLLBACK TRANSACTION;
        END
        DECLARE @mensaje_error NVARCHAR(4000);
		DECLARE @severidad_error int;
		DECLARE @estado_error int;

        SELECT 
		@mensaje_error = ERROR_MESSAGE(),
		@severidad_error=ERROR_SEVERITY(),
		@estado_error=ERROR_STATE();

        SET @pi_codigo_salida = 500;
        SET @pv_descripcion_salida = 'Error: '+ @mensaje_error+' Severidad Error: '+convert(varchar,@severidad_error)+' Estado Error: '+convert(varchar,@estado_error);

	INSERT INTO [veterinaria_bd].[dbo].[TransaccionesLog]
	([CodigoRespuesta],[Descripcion],[Proceso],[NombreUsuario],[FechaRegistro])
	VALUES(
	@pi_codigo_salida,
	@pv_descripcion_salida,
	@nombre_sp,
	USER_NAME(),
	GETDATE()	
	);

    END CATCH
END;
GO

-- caso exitoso --

DECLARE	@pi_codigo_salida INT ;
DECLARE	@pv_descripcion_salida NVARCHAR(255) ;

EXEC SEARCH_MASCOTAS
	@nombreMascota = 'Akira',
	@pi_codigo_salida = @pi_codigo_salida OUTPUT,
	@pv_descripcion_salida = @pv_descripcion_salida OUTPUT



	SELECT @pi_codigo_salida, @pv_descripcion_salida


	-- error 400 --

	DECLARE	@pi_codigo_salida INT ;
DECLARE	@pv_descripcion_salida NVARCHAR(255) ;

EXEC SEARCH_MASCOTAS
	@nombreMascota = 'Sammy',
	@pi_codigo_salida = @pi_codigo_salida OUTPUT,
	@pv_descripcion_salida = @pv_descripcion_salida OUTPUT



	SELECT @pi_codigo_salida, @pv_descripcion_salida
		
	select * from TransaccionesLog

	-- error 500 --


	DROP TABLE Mascotas

		DECLARE	@pi_codigo_salida INT ;
DECLARE	@pv_descripcion_salida NVARCHAR(255) ;

EXEC SEARCH_MASCOTAS
	@nombreMascota = '',
	@pi_codigo_salida = @pi_codigo_salida OUTPUT,
	@pv_descripcion_salida = @pv_descripcion_salida OUTPUT



	SELECT @pi_codigo_salida, @pv_descripcion_salida
		
	select * from TransaccionesLog