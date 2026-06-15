  
  CREATE    PROCEDURE [dbo].[upsertpaymentadvices]        
    @jsondata NVARCHAR(MAX)        
AS        
BEGIN        
    SET NOCOUNT ON;        
        
    BEGIN TRY        
        BEGIN TRAN;        
        
        -------------------------------------------------------------        
        -- VALIDATE JSON        
        -------------------------------------------------------------        
        IF @jsondata IS NULL OR ISJSON(@jsondata) = 0        
        BEGIN        
            RAISERROR('Invalid or Null JSON Passed',16,1);        
            ROLLBACK TRAN;        
            RETURN;        
        END        
        
        -------------------------------------------------------------        
        -- LOG INPUT        
        -------------------------------------------------------------        
        INSERT INTO pojsonfromerp (ponumber, jsondata, createdat)        
        VALUES ('PaymentAdvice Before Insert', @jsondata, GETDATE());        
        
        -------------------------------------------------------------        
        -- TEMP TABLE        
        -------------------------------------------------------------        
        DECLARE @tempheader TABLE        
        (        
            record_id VARCHAR(36),        
            bank_account_num VARCHAR(30),        
            check_id BIGINT,        
            payment_number VARCHAR(50),        
            payment_date DATETIME,        
            payment_currency_code VARCHAR(15),        
            vendor_id BIGINT,        
            vendor_site_code VARCHAR(50),        
            vendor_name VARCHAR(200),        
            org_id BIGINT,        
            created_by VARCHAR(100),        
            created_at DATETIME,        
            updated_by VARCHAR(100),        
            updated_at DATETIME,        
            invoice_amount DECIMAL(18,2),        
            request_id INT,        
            error_msg VARCHAR(50),        
            dig_process_flag VARCHAR(50),        
   last_update_login int,        
            invoice_id INT,        
            invoice_num VARCHAR(50),        
            invoice_date DATETIME,        
            po_header_id VARCHAR(50),        
            po_number VARCHAR(50),        
   receipt_num varchar(30),        
   shipment_header_id int        
        );        
        
        -------------------------------------------------------------        
        -- OPENJSON PARSE (FIXED ALIGNMENT)        
        -------------------------------------------------------------        
        INSERT INTO @tempheader        
        (        
            invoice_amount,        
            record_id,        
            bank_account_num,        
            check_id,        
            payment_number,        
            payment_date,        
            payment_currency_code,        
            vendor_id,        
            vendor_site_code,        
            vendor_name,        
            org_id,        
            created_by,        
            created_at,        
            updated_by,        
            updated_at,        
            request_id,        
            error_msg,        
            dig_process_flag,        
   last_update_login,        
            invoice_id,        
            invoice_num,        
            invoice_date,        
            po_header_id,        
            po_number,        
   receipt_num ,        
   shipment_header_id          
        )        
        SELECT        
            TRY_CONVERT(DECIMAL(18,2), invoice_amount),        
            TRY_CONVERT(BIGINT, record_id),        
            bank_account_id,        
            TRY_CONVERT(BIGINT, check_id),        
            check_number,        
            check_date,        
            invoice_currency_code,        
            TRY_CONVERT(BIGINT, vendor_id),        
            vendor_number,        
            vendor_name,        
            TRY_CONVERT(BIGINT, org_id),        
            created_by,        
            creation_date,        
     last_updated_by,        
            last_update_date,        
            request_id,        
            error_msg,        
            dig_process_flag,        
   last_update_login,        
            invoice_id,        
           invoice_num,        
            invoice_date,        
            po_header_id,        
            po_number,        
   receipt_num ,        
   shipment_header_id          
        FROM OPENJSON(@jsondata)        
        WITH        
        (        
           invoice_amount VARCHAR(50),        
            record_id VARCHAR(50),        
            bank_account_id VARCHAR(50),        
            check_id VARCHAR(50),        
            check_number VARCHAR(50),        
            check_date DATETIME,        
            invoice_currency_code VARCHAR(15),        
            vendor_id VARCHAR(50),        
            vendor_number VARCHAR(50),        
            vendor_name VARCHAR(200),        
            org_id VARCHAR(50),        
            created_by VARCHAR(100),        
            creation_date DATETIME,        
            last_updated_by VARCHAR(100),        
            last_update_date DATETIME,        
            request_id INT,        
            error_msg VARCHAR(50),        
            dig_process_flag VARCHAR(50),        
   last_update_login int ,        
            invoice_id INT,        
            invoice_num VARCHAR(50),        
            invoice_date DATETIME,        
            po_header_id VARCHAR(50),        
            po_number VARCHAR(50),        
   receipt_num varchar(30),        
   shipment_header_id int        
        );        
        
        -------------------------------------------------------------        
        -- UPDATE PAYMENT RECEIPT        
        -------------------------------------------------------------        
        UPDATE tar        
        SET        
            tar.payment_amount = src.invoice_amount,        
            tar.payment_number = src.payment_number,        
            tar.payment_date = src.payment_date,        
            tar.check_id = src.check_id,        
            tar.payment_currency_code = src.payment_currency_code,        
            tar.vendor_id = src.vendor_id,        
            tar.vendor_site_code = src.vendor_site_code,        
            tar.vendor_name = src.vendor_name,        
            tar.org_id = src.org_id,        
            tar.updated_by = src.updated_by,        
            tar.updated_at = COALESCE(src.updated_at, GETDATE()),        
            tar.bank_account_num = src.bank_account_num,        
            tar.request_id = src.request_id,        
            tar.error_msg = src.error_msg,        
            tar.dig_process_flag = src.dig_process_flag,        
   tar.last_update_login=src.last_update_login        
        FROM PaymentReceipt tar        
        INNER JOIN @tempheader src        
            ON tar.check_id = src.check_id ;        
        
        -------------------------------------------------------------        
        -- UPDATE INVOICE MAPPING        
        -------------------------------------------------------------        
        UPDATE tar        
        SET        
            tar.payment_invoice_id =  src.invoice_id,      
          --  tar.payment_id = src.record_id,        
            tar.accounting_date = src.invoice_date,        
            tar.invoice_number = src.invoice_num,        
            tar.invoice_id = src.invoice_id,        
            tar.payment_number = src.payment_number,        
            tar.amount_paid = 0     
       
        FROM PaymentInvoiceMapping tar        
        INNER JOIN @tempheader src        
            ON tar.check_id = src.check_id       
   AND tar.invoice_id=src.invoice_id    
        
        -------------------------------------------------------------        
        -- UPDATE PO MAPPING        
        -------------------------------------------------------------        
        UPDATE tar        
        SET        
            tar.Payment_POHeaderId = src.po_header_id,        
            tar.PO_Number = src.po_number,        
            --tar.Payment_Id = src.record_id,        
            tar.updated_by = src.updated_by,        
            tar.updated_on = COALESCE(src.updated_at, GETDATE())        
        FROM PaymentPOHeaderMapping tar        
        INNER JOIN @tempheader src        
            ON tar.check_id = src.check_id AND tar.PO_Number=src.po_number        
        
        
     -------------------------------------------------------------        
        -- UPDATE PaymentASNMapping        
        -------------------------------------------------------------        
        UPDATE tar        
        SET        
            tar.Payment_ASNId = src.shipment_header_id,        
            tar.receipt_num = src.receipt_num,        
          --  tar.Payment_Id = src.record_id,        
            tar.updated_by = src.updated_by,        
            tar.updated_on = COALESCE(src.updated_at, GETDATE())        
        FROM PaymentASNMapping tar        
        INNER JOIN @tempheader src        
            ON tar.Payment_ASNId = src.shipment_header_id AND tar.check_id=src.check_id        
        
         
        -------------------------------------------------------------        
        -- INSERT PAYMENT RECEIPT        
        -------------------------------------------------------------        
        INSERT INTO PaymentReceipt        
        (        
            payment_amount,        
            payment_id,        
           bank_account_num,        
            check_id,        
            payment_number,        
            payment_date,        
            payment_currency_code,        
            vendor_id,        
            vendor_site_code,        
            vendor_name,        
            org_id,        
            created_by,        
            created_at,        
            updated_by,        
            updated_at,        
            payment_status,        
            request_id,        
            error_msg,        
            dig_process_flag,        
   last_update_login        
        )        
        SELECT        
            invoice_amount,        
            record_id,        
            bank_account_num,        
            check_id,        
            payment_number,        
            payment_date,        
            payment_currency_code,        
            vendor_id,        
            vendor_site_code,        
            vendor_name,        
            org_id,        
            created_by,        
            COALESCE(created_at, GETDATE()),        
            updated_by,        
            COALESCE(updated_at, GETDATE()),        
            'Completed',        
            request_id,        
            error_msg,        
            dig_process_flag,        
   last_update_login        
        FROM @tempheader src        
        WHERE NOT EXISTS (        
            SELECT 1 FROM PaymentReceipt p WHERE p.check_id = src.check_id     
        );        
        
        -------------------------------------------------------------        
        -- INSERT INVOICE MAPPING        
        -------------------------------------------------------------        
        INSERT INTO PaymentInvoiceMapping        
        (        
   check_id,    
            payment_invoice_id,        
            payment_id,        
            accounting_date,        
            invoice_number,        
            invoice_id,        
            payment_number,        
            amount_paid        
        )        
        SELECT        
   check_id,    
            invoice_id,        
            record_id,        
            invoice_date,        
            invoice_num,        
            invoice_id,        
            payment_number,        
            0        
        FROM @tempheader src        
        WHERE NOT EXISTS (        
            SELECT 1 FROM PaymentInvoiceMapping p WHERE p.check_id = src.check_id   AND p.invoice_id=src.invoice_id     
        );        
        
        -------------------------------------------------------------        
        -- INSERT PO MAPPING        
        -------------------------------------------------------------        
        INSERT INTO PaymentPOHeaderMapping        
        (        
   check_id,    
            Payment_POHeaderId,        
            PO_Number,        
            Payment_Id,        
            updated_by,        
            updated_on        
        )        
        SELECT        
   check_id,    
            po_header_id,        
            po_number,        
            record_id,        
            updated_by,        
            COALESCE(updated_at, GETDATE())        
   FROM @tempheader src        
        WHERE NOT EXISTS (        
            SELECT 1 FROM PaymentPOHeaderMapping p WHERE p.po_number = src.po_number  AND p.check_id=src.check_id       
        );        
        
        
        
          
     -------------------------------------------------------------        
        -- INSERT PaymentASNMapping        
        -------------------------------------------------------------        
         INSERT INTO PaymentASNMapping        
        (        
   check_id,    
            Payment_ASNId,        
            receipt_num,        
            Payment_Id,        
            updated_by,        
            updated_on        
        )        
        SELECT        
   check_id,    
            shipment_header_id,        
            receipt_num,        
            record_id,        
            updated_by,        
            COALESCE(updated_at, GETDATE())        
        FROM @tempheader src        
        WHERE NOT EXISTS (       
      SELECT 1 FROM PaymentASNMapping p WHERE p.Payment_ASNId = src.shipment_header_id   AND p.check_id=src.check_id      
        );        
        
        SELECT payment_number FROM @tempheader;        
        
      
  DECLARE @loop int,    
    @loopcount int,    
    @tempdossierid varchar(50),    
    @tempinvoiceid varchar(50)    
    
  declare @temppaymentdossier table    
  (    
   rowno int identity(1,1),    
   checkid bigint,    
   ponumber varchar(50),    
   invoiceid varchar(50)    
  )    
  insert into @temppaymentdossier    
  (checkid,ponumber,invoiceid)    
  select distinct check_id,po_number,invoice_id    
  from @tempheader    
  where po_number is not null    
    
   set @loop=1    
    
  SELECT @loopcount=count(*) FROM @temppaymentdossier     
    
    
    
    
  --Create dossier    
  EXEC [CreateInvoicePaymentDossierBulk] @userId =185    
    
    
        -------------------------------------------------------------        
        -- OUTPUT        
        -------------------------------------------------------------        
        SELECT payment_number FROM @tempheader;        
        
        INSERT INTO pojsonfromerp (ponumber, jsondata, createdat)        
        VALUES ('PaymentAdvice Completed', @jsondata, GETDATE());        
        
        COMMIT TRAN;        
        
    END TRY        
    BEGIN CATCH        
        IF @@TRANCOUNT > 0        
            ROLLBACK;        
        
        SELECT        
            'ERROR' AS Status,        
            ERROR_MESSAGE() AS ErrorMessage,        
            ERROR_LINE() AS ErrorLine;        
    END CATCH        
END        