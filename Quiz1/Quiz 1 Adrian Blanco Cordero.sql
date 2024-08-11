use Northwind

--1. Vista SalesOverview
CREATE VIEW SalesOverview 
as
SELECT C.CustomerID, C.CompanyName, O.OrderID, O.OrderDate, P.ProductID, P.ProductName, OD.Quantity, OD.UnitPrice, (OD.Quantity * OD.UnitPrice) TotalPrice  from Customers C
INNER JOIN Orders O on C.CustomerID = O.CustomerID
INNER JOIN [Order Details] OD on O.OrderID = OD.OrderID
INNER JOIN Products P on OD.ProductID = P.ProductID

select * from SalesOverview




--2. Procedimiento almacenado Insertar Ordenes


CREATE OR ALTER PROCEDURE P_Insertar_Ordenes


	@OrderID int,
    @CustomerID nchar(5),
    @EmployeeID int,
    @OrderDate datetime,
    @RequiredDate datetime,
    @ShippedDate datetime,
    @ShipVia int,
    @Freight money,
    @ShipName nvarchar(40),
    @ShipAddress nvarchar(60),
    @ShipCity nvarchar(15),
    @ShipRegion nvarchar(15),
    @ShipPostalCode nvarchar(10),
    @ShipCountry nvarchar(15),
    @ProductID int,
    @UnitPrice money,
    @Quantity smallint,
    @Discount real,
    @StatusCode  int OUTPUT,
    @StatusMessage  nvarchar(255) OUTPUT,
	@TempOrderID int OUTPUT
	
	AS
	BEGIN

	BEGIN TRANSACTION;


	BEGIN TRY

	CREATE TABLE #TempOrders(
			OrderID int,
            CustomerID nchar(5),
            EmployeeID int,
            OrderDate datetime,
            RequiredDate datetime,
            ShippedDate datetime,
            ShipVia int,
            Freight money,
            ShipName nvarchar(40),
            ShipAddress nvarchar(60),
            ShipCity nvarchar(15),
            ShipRegion nvarchar(15),
            ShipPostalCode nvarchar(10),
            ShipCountry nvarchar(15)
	);

	CREATE TABLE #TempOrderDetails (
            OrderID int,
            ProductID int,
            UnitPrice money,
            Quantity smallint,
            Discount real
        );

	INSERT INTO #TempOrders (OrderID, CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate, ShipVia, Freight, ShipName, ShipAddress, ShipCity, ShipRegion, ShipPostalCode, ShipCountry)
    VALUES (@OrderID, @CustomerID, @EmployeeID, @OrderDate, @RequiredDate, @ShippedDate, @ShipVia, @Freight, @ShipName, @ShipAddress, @ShipCity, @ShipRegion, @ShipPostalCode, @ShipCountry);


	INSERT INTO #TempOrderDetails (OrderID, ProductID, UnitPrice, Quantity, Discount)
    VALUES (@OrderID, @ProductID, @UnitPrice, @Quantity, @Discount);


	IF EXISTS (SELECT 1 FROM Orders WHERE OrderID = @OrderID)
        BEGIN
              SET @StatusCode = 400;
            SET @StatusMessage = 'Error en la entrada de datos. La orden ya existe.';
            SET @TempOrderID = NULL;
            RETURN;
            
        END
        ELSE
        BEGIN
          
            INSERT INTO Orders (CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate, ShipVia, Freight, ShipName, ShipAddress, ShipCity, ShipRegion, ShipPostalCode, ShipCountry)
            SELECT CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate, ShipVia, Freight, ShipName, ShipAddress, ShipCity, ShipRegion, ShipPostalCode, ShipCountry FROM #TempOrders;

            
            SET @TempOrderID = SCOPE_IDENTITY();

          
            INSERT INTO [Order Details](OrderID, ProductID, UnitPrice, Quantity, Discount)
            SELECT @TempOrderID, ProductID, UnitPrice, Quantity, Discount FROM #TempOrderDetails;
        END

       
        COMMIT TRANSACTION;

   
        SET @StatusCode = 200;
        SET @StatusMessage = 'Transacción exitosa.';


    END TRY
	BEGIN CATCH
        
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END


		DECLARE @ErrorMessage nvarchar(4000);
        SELECT @ErrorMessage = ERROR_MESSAGE();

		 SET @StatusCode = 500;
        SET @StatusMessage = 'Error no controlado: ' + @ErrorMessage;

    END CATCH
END;
GO



-- uso del procedimiento almacenado

DECLARE @OrderStatus int;
DECLARE @OrderMessage nvarchar(255);
DECLARE @TempOrderID int;

EXEC P_Insertar_Ordenes
    @OrderID = 1,
    @CustomerID = 'CHOPS',
    @EmployeeID = 2,
    @OrderDate = '2024-07-11',
    @RequiredDate = '2024-07-11',
    @ShippedDate = '2024-07-11',
    @ShipVia = 1,
    @Freight = 32.38,
    @ShipName = 'Carga Tica',
    @ShipAddress = 'San Jose',
    @ShipCity = 'San Jose',
    @ShipRegion = NULL,
    @ShipPostalCode = '11011',
    @ShipCountry = 'Costa Rica',
    @ProductID = 1,
    @UnitPrice = 13.00,
    @Quantity = 10,
    @Discount = 0,
    @StatusCode = @OrderStatus OUTPUT,
    @StatusMessage = @OrderMessage OUTPUT,
	@TempOrderID = @TempOrderID OUTPUT;

SELECT @OrderStatus AS Codigo, @OrderMessage AS Descripcion, @TempOrderID AS OrdenRealizada;


Select * from Orders
Where CustomerID = 'CHOPS'


