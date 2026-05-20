USE [Vertiv]
GO

/****** Object:  StoredProcedure [dbo].[UpsertPaymentInvoiceMapping_FromJson]    Script Date: 20-05-2026 16:05:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

 ALTER       procedure [dbo].[UpsertPaymentInvoiceMapping_FromJson]       
    @jsondata nvarchar(max)        
as        
begin        
    set nocount on;        
        
        
    --   validate json    
        if @jsondata is null or isjson(@jsondata) = 0    
        begin    
            throw 50001, 'invalid or null json passed to savegrnlineitemsjson', 1;    
        end    
  
  insert into vertiv..pojsonfromerp        
  values('before PA insert lineitem',@jsondata,getdate())       
            
      
   declare @templineitems table      
   (      
        payment_invoice_id VARCHAR(36),    
        payment_id VARCHAR(36),    
        invoice_id BIGINT,    
        invoice_number VARCHAR(50),    
        invoice_payment_id BIGINT,    
        amount_paid DECIMAL(18, 2),    
        discount_taken DECIMAL(18, 2),    
        withholding_tax_amount DECIMAL(18, 2),    
        accounting_date DATETIME,    
        currency_code VARCHAR(15),    
        exchange_rate DECIMAL(18, 6),    
        base_amount DECIMAL(18, 2),    
        created_at DATETIME,    
        updated_at DATETIME,    
        payment_number VARCHAR(50)      
                   
  )      
  insert into @templineitems      
  (      
        payment_invoice_id,    
        payment_id,    
        invoice_id,    
        invoice_number,    
        invoice_payment_id,    
        amount_paid,    
        discount_taken,    
        withholding_tax_amount,    
        accounting_date,    
        currency_code,    
        exchange_rate,    
        base_amount,    
        created_at,    
        updated_at,    
        payment_number 
  )      
         
        select   
        
		payment_invoice_id,    
        payment_id,    
        invoice_id,    
        invoice_number,    
        invoice_payment_id,    
        amount_paid,    
        discount_taken,    
        withholding_tax_amount,    
        accounting_date,    
        currency_code,    
        exchange_rate,    
        base_amount,    
        created_at,    
        updated_at,    
        payment_number      
                      
        from openjson(@jsondata)        
        with (        
        payment_invoice_id VARCHAR(36),    
        payment_id VARCHAR(36),    
        invoice_id BIGINT,    
        invoice_number VARCHAR(50),    
        invoice_payment_id BIGINT,    
        amount_paid DECIMAL(18, 2),    
        discount_taken DECIMAL(18, 2),    
        withholding_tax_amount DECIMAL(18, 2),    
        accounting_date DATETIME,    
        currency_code VARCHAR(15),    
        exchange_rate DECIMAL(18, 6),    
        base_amount DECIMAL(18, 2),    
        created_at DATETIME,    
        updated_at DATETIME,    
        payment_number VARCHAR(50)        
        )        
          
   
  --update existing line items      
   update tar      
   set        
            
            tar.payment_invoice_id         = src.payment_invoice_id,    
            tar.payment_id                 = src.payment_id  ,   
            tar.invoice_id                 = src.invoice_id,    
            tar.invoice_number             = src.invoice_number,    
            tar.invoice_payment_id         = src.invoice_payment_id,    
            tar.amount_paid                = src.amount_paid,    
            tar.discount_taken             = src.discount_taken,    
            tar.withholding_tax_amount     = src.withholding_tax_amount,    
            tar.accounting_date            = src.accounting_date,    
            tar.currency_code              = src.currency_code,    
            tar.exchange_rate              = src.exchange_rate,    
            tar.base_amount                = src.base_amount,    
            tar.updated_at                 = src.updated_at 
		  
 from @templineitems src      
 join vertiv..PaymentInvoiceMapping tar       
 on  src.payment_invoice_id=tar.payment_invoice_id          
      
 --insert new line items      
      
        insert  into vertiv..PaymentInvoiceMapping      
  (        
        payment_invoice_id,    
        payment_id,    
        invoice_id,    
        invoice_number,    
        invoice_payment_id,    
        amount_paid,    
        discount_taken,    
        withholding_tax_amount,    
        accounting_date,    
        currency_code,    
        exchange_rate,    
        base_amount,    
        created_at,    
        updated_at,    
        payment_number    
        )       
  select    
        src.payment_invoice_id,    
        src.payment_id,    
        src.invoice_id,    
        src.invoice_number,    
        src.invoice_payment_id,    
        src.amount_paid,    
        src.discount_taken,    
        src.withholding_tax_amount,    
        src.accounting_date,    
        src.currency_code,    
        src.exchange_rate,    
        src.base_amount,    
        src.created_at,    
        src.updated_at,    
        src.payment_number
               
                 
  from @templineitems src
left join vertiv..PaymentInvoiceMapping pli
    on src.payment_invoice_id = pli.payment_invoice_id
where pli.payment_invoice_id is null;     
      
            
  insert into vertiv..pojsonfromerp        
  values('PA_lineitem',@jsondata,getdate())        
end 


GO


