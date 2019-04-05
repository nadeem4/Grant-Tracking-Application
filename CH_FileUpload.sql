/****** Object:  StoredProcedure [dbo].[CH_FileUpload]    Script Date: 4/3/2019 6:31:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CH_FileUpload]
(
    @contractId int
)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

  SELECT DISTINCT
	cp.WorkflowPropertyValue as TrackingId,
	cp.ContractId as ContractId,
	cp1.WorkflowPropertyValue as ParentTrackingId,
	cp2.ContractId as ParentContractId,
	cp2.ContractLedgerIdentifier, 
	ucm.ChainIdentifier as Recipient, 
	cp.ConnectionId as ConnectionId 

  FROM [dbo].[vwContractPropertyV0] cp
  Join [dbo].[vwContractPropertyV0]  cp1 on cp1.ContractId = cp.ContractId 
  Join [dbo].[vwContractPropertyV0]  cp2 on cp2.WorkflowPropertyValue = cp1.WorkflowPropertyValue 
  join UserChainMapping ucm on ucm.UserID = cp.ContractDeployedByUserId
  Where  cp.ContractId = @contractId 
  and (cp.WorkflowPropertyName='id')
  and cp1.WorkflowPropertyName='parentContractId'
  and cp2.WorkflowPropertyName='id'
END


GO


