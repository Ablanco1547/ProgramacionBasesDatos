use northwind

--Construir una consulta SQL que utilice múltiples joins (5)

Select P.ProductName, S.CompanyName, OD.UnitPrice, O.OrderDate, E.FirstName, T.TerritoryDescription from Products P
INNER JOIN Suppliers S on P.SupplierID = S.SupplierID
INNER JOIN [Order Details] OD on P.ProductID = OD.ProductID
INNER JOIN Orders O on OD.OrderID = O.OrderID
INNER JOIN Employees E on O.EmployeeID = E.EmployeeID
INNER JOIN EmployeeTerritories ET on ET.EmployeeID = E.EmployeeID
INNER JOIN Territories T on ET.TerritoryID = T.TerritoryID


--Hacer dos consultas que utilice sub consultas (1)
Select O.ShipName, O.ShipCity 
FROM Orders O
WHERE EXISTS (
    SELECT 1
    FROM [Order Details] OD
    WHERE OD.OrderID = O.OrderID
      AND OD.UnitPrice > (SELECT AVG(UnitPrice) FROM [Order Details])
);


--Hacer dos consultas que utilice sub consultas (2)
SELECT * 
FROM Employees E
WHERE E.TitleOfCourtesy <> 'Mr.'
AND EXISTS (
    SELECT 1 
    FROM EmployeeTerritories ET 
    JOIN Territories T 
    ON T.TerritoryID = ET.TerritoryID 
    WHERE ET.EmployeeID = E.EmployeeID 
    AND T.TerritoryDescription = 'Boston'
);



--Realice 2 SP que utilice try catch (1)
CREATE PROCEDURE SP_Crear_Clientes
    @CustomerID nchar(5),
    @CompanyName nvarchar(40),
    @ContactName nvarchar(30) = NULL,
    @ContactTitle nvarchar(30) = NULL,
    @Address nvarchar(60) = NULL,
    @City nvarchar(15) = NULL,
    @Region nvarchar(15) = NULL,
    @PostalCode nvarchar(10) = NULL,
    @Country nvarchar(15) = NULL,
    @Phone nvarchar(24) = NULL,
    @Fax nvarchar(24) = NULL,
    @pi_id_Registro nchar(5) OUTPUT,
    @pi_Codigo_Salida SMALLINT OUTPUT,
    @pv_Descripcion_Salida varchar(max) OUTPUT
AS
BEGIN 
    BEGIN TRY
        INSERT INTO [dbo].[Customers] (
            CustomerID,
            CompanyName,
            ContactName,
            ContactTitle,
            Address,
            City,
            Region,
            PostalCode,
            Country,
            Phone,
            Fax
        )
        VALUES (
            @CustomerID,
            @CompanyName,
            @ContactName,
            @ContactTitle,
            @Address,
            @City,
            @Region,
            @PostalCode,
            @Country,
            @Phone,
            @Fax
        );

        SET @pi_id_Registro = @CustomerID;
        SET @pi_Codigo_Salida = 201;
        SET @pv_Descripcion_Salida = 'Se ejecuto correctamente';
    END TRY
    BEGIN CATCH
        SET @pi_Codigo_Salida = 500;
        SET @pv_Descripcion_Salida = 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;



DECLARE @pi_id_Registro nchar(5);
DECLARE @pi_Codigo_Salida SMALLINT;
DECLARE @pv_Descripcion_Salida varchar(max);

EXEC SP_Crear_Clientes 
    @CustomerID = "ABLANCO",
    @CompanyName = 'Adrian Blanco',
    @ContactName = 'Adrian Blanco',
    @ContactTitle = 'Ventas',
    @Address = 'Alajuela',
    @City = 'Palmares',
    @Region = NULL,
    @PostalCode = '20701',
    @Country = 'Costa Rica',
    @Phone = '83182887',
    @Fax = '83182887',
    @pi_id_Registro = @pi_id_Registro OUTPUT,
    @pi_Codigo_Salida = @pi_Codigo_Salida OUTPUT,
    @pv_Descripcion_Salida = @pv_Descripcion_Salida OUTPUT;


SELECT 
    @pi_id_Registro AS CustomerID,
    @pi_Codigo_Salida AS StatusCode,
    @pv_Descripcion_Salida AS StatusMessage;


SELECT * FROM Customers






--Realice 2 SP que utilice try catch (2)
CREATE PROCEDURE SP_Crear_Territorios
    @TerritoryID nvarchar(20),
    @TerritoryDescription nchar(50),
    @RegionID int,
    @pi_id_Registro nvarchar(20) OUTPUT,
    @pi_Codigo_Salida SMALLINT OUTPUT,
    @pv_Descripcion_Salida varchar(max) OUTPUT
AS
BEGIN 
    BEGIN TRY
        INSERT INTO [dbo].[Territories] (
            TerritoryID,
            TerritoryDescription,
            RegionID
        )
        VALUES (
            @TerritoryID,
            @TerritoryDescription,
            @RegionID
        );

        SET @pi_id_Registro = @TerritoryID;
        SET @pi_Codigo_Salida = 201;
        SET @pv_Descripcion_Salida = 'Se ejecuto correctamente';
    END TRY
    BEGIN CATCH
        SET @pi_Codigo_Salida = 500;
        SET @pv_Descripcion_Salida = 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;




DECLARE @pi_id_Registro nvarchar(20);
DECLARE @pi_Codigo_Salida SMALLINT;
DECLARE @pv_Descripcion_Salida varchar(max);


EXEC SP_Crear_Territorios 
    @TerritoryID = '20701',
    @TerritoryDescription = 'Occidente',
    @RegionID = 1,
    @pi_id_Registro = @pi_id_Registro OUTPUT,
    @pi_Codigo_Salida = @pi_Codigo_Salida OUTPUT,
    @pv_Descripcion_Salida = @pv_Descripcion_Salida OUTPUT;


SELECT 
    @pi_id_Registro AS TerritoryID,
    @pi_Codigo_Salida AS StatusCode,
    @pv_Descripcion_Salida AS StatusMessage;

SELECT * FROM Territories;



--Realice un SP que utilice tablas temporales 

CREATE PROCEDURE SP_Crear_Categorias_Con_Temporales
    @CategoryName nvarchar(15),
    @Description nvarchar(max) = NULL,
    @Picture image = NULL,
    @pi_id_Registro int OUTPUT,
    @pi_Codigo_Salida SMALLINT OUTPUT,
    @pv_Descripcion_Salida varchar(max) OUTPUT
AS
BEGIN
 
    CREATE TABLE #TempCategories (
        TempCategoryID int IDENTITY(1,1) NOT NULL,
        TempCategoryName nvarchar(15),
        TempDescription nvarchar(max) NULL,
        TempPicture image NULL
    );

  
    BEGIN TRY
       
        INSERT INTO #TempCategories (TempCategoryName, TempDescription, TempPicture)
        VALUES (@CategoryName, @Description, @Picture);

        
        SELECT * FROM #TempCategories;

    
        INSERT INTO [dbo].[Categories](
            CategoryName,
            Description,
            Picture
        )
        SELECT 
            TempCategoryName,
            TempDescription,
            TempPicture
        FROM #TempCategories;

   
        SET @pi_id_Registro = SCOPE_IDENTITY();
        SET @pi_Codigo_Salida = 201;
        SET @pv_Descripcion_Salida = 'Se ejecuto correctamente';
    END TRY
    BEGIN CATCH
  
        SET @pi_Codigo_Salida = 500;
        SET @pv_Descripcion_Salida = 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;




DECLARE @pi_id_Registro int;
DECLARE @pi_Codigo_Salida SMALLINT;
DECLARE @pv_Descripcion_Salida varchar(max);

EXEC SP_Crear_Categorias_Con_Temporales 
    @CategoryName = 'Comidas',
    @Description = 'Comidas enlatadas',
    @Picture = NULL,
    @pi_id_Registro = @pi_id_Registro OUTPUT,
    @pi_Codigo_Salida = @pi_Codigo_Salida OUTPUT,
    @pv_Descripcion_Salida = @pv_Descripcion_Salida OUTPUT;

SELECT 
    @pi_id_Registro AS CategoryID,
    @pi_Codigo_Salida AS StatusCode,
    @pv_Descripcion_Salida AS StatusMessage;

SELECT * FROM Categories;