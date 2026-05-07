USE [Vertiv]
GO

/****** Object:  StoredProcedure [dbo].[SaveGRNHeaderJson]    Script Date: 05-05-2026 11:01:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[SaveGRNHeaderJson]
    @JsonData NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRAN;

         
        IF @JsonData IS NULL OR ISJSON(@JsonData) = 0
        BEGIN
            THROW 50001, 'Invalid or NULL JSON passed', 1;
        END
		 
        DECLARE @Source TABLE (
            grn_id   VARCHAR(36),
            grn_number VARCHAR(30),
            invoice_no VARCHAR(50),
            receipt_date DATETIME,
            po_number VARCHAR(20),
            vendor_name VARCHAR(200),
            vendor_gstin VARCHAR(15),
            ship_to_location VARCHAR(150),
            receipt_source VARCHAR(20),
            bill_of_lading VARCHAR(50),
            packing_slip VARCHAR(50),
            waybill_number VARCHAR(50),
            freight_carrier VARCHAR(100),
            num_of_containers INT
        );

        INSERT INTO @Source
        SELECT
            CASE 
                WHEN grn_id IS NULL OR grn_id = '' 
                    THEN CAST(NEWID() AS VARCHAR(36))
                ELSE grn_id
            END,
            grn_number,
            NULLIF(invoice_no, ''),
            TRY_CAST(receipt_date AS DATETIME),
            po_number,
            vendor_name,
            vendor_gstin,
            ship_to_location,
            receipt_source,
            bill_of_lading,
            packing_slip,
            waybill_number,
            freight_carrier,
            TRY_CAST(num_of_containers AS INT)
        FROM OPENJSON(@JsonData, '$')
        WITH (
            grn_id VARCHAR(36),
            grn_number VARCHAR(30),
            invoice_no VARCHAR(50),
            receipt_date NVARCHAR(50),
            po_number VARCHAR(20),
            vendor_name VARCHAR(200),
            vendor_gstin VARCHAR(15),
            ship_to_location VARCHAR(150),
            receipt_source VARCHAR(20),
            bill_of_lading VARCHAR(50),
            packing_slip VARCHAR(50),
            waybill_number VARCHAR(50),
            freight_carrier VARCHAR(100),
            num_of_containers NVARCHAR(20)
        );

           DECLARE @InsertedGRNs TABLE (
            GRN_NUMBER VARCHAR(30),
            GRNCreatedOn DATETIME
        );

        MERGE dbo.GRNHeader AS TARGET
        USING @Source AS SOURCE
        ON TARGET.grn_id = SOURCE.grn_id

        WHEN MATCHED THEN
            UPDATE SET
                grn_number        = SOURCE.grn_number,
                invoice_no        = SOURCE.invoice_no,
                receipt_date      = SOURCE.receipt_date,
                po_number         = SOURCE.po_number,
                vendor_name       = SOURCE.vendor_name,
                vendor_gstin      = SOURCE.vendor_gstin,
                ship_to_location  = SOURCE.ship_to_location,
                receipt_source    = SOURCE.receipt_source,
                bill_of_lading    = SOURCE.bill_of_lading,
                packing_slip      = SOURCE.packing_slip,
                waybill_number    = SOURCE.waybill_number,
                freight_carrier   = SOURCE.freight_carrier,
                num_of_containers = SOURCE.num_of_containers

        WHEN NOT MATCHED THEN
            INSERT (
                grn_id,
                grn_number,
                invoice_no,
                receipt_date,
                po_number,
                vendor_name,
                vendor_gstin,
                ship_to_location,
                receipt_source,
                bill_of_lading,
                packing_slip,
                waybill_number,
                freight_carrier,
                num_of_containers
            )
            VALUES (
                SOURCE.grn_id,
                SOURCE.grn_number,
                SOURCE.invoice_no,
                SOURCE.receipt_date,
                SOURCE.po_number,
                SOURCE.vendor_name,
                SOURCE.vendor_gstin,
                SOURCE.ship_to_location,
                SOURCE.receipt_source,
                SOURCE.bill_of_lading,
                SOURCE.packing_slip,
                SOURCE.waybill_number,
                SOURCE.freight_carrier,
                SOURCE.num_of_containers
            )

        OUTPUT
            INSERTED.grn_number,
            INSERTED.created_at
        INTO @InsertedGRNs;

        COMMIT TRAN;

        -- Insert log
        DECLARE @ponumber VARCHAR(50);

        SELECT TOP 1 @ponumber = GRN_NUMBER
        FROM @InsertedGRNs;

        INSERT INTO POJsonfromERP
        VALUES (@ponumber, @JsonData, GETDATE());

        -- Return result
        SELECT * FROM @InsertedGRNs;

		declare @loop int,				
				@loopcount int,
				@tempgrnnumber varchar(30)

		select @loopcount=count(*) from @InsertedGRNs

		set @loop=1
		while(@loop<=@loopcount)
		begin
			select top 1 @tempgrnnumber=GRN_NUMBER
			from @InsertedGRNs
			if(@tempgrnnumber <>'')
			begin
				exec vertiv..GenerateDossierGRN @tempgrnnumber
			end

			delete from @InsertedGRNs where GRN_NUMBER=@tempgrnnumber

			set @tempgrnnumber=''

			set @loop=@loop+1
		end

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN;

        --  
        SELECT 
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_LINE() AS ErrorLine,
            ERROR_PROCEDURE() AS ErrorProcedure;

        THROW;
    END CATCH
END;
GO


