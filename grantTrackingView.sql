/****** Object:  View [dbo].[vwGrantTracking]    Script Date: 4/1/2019 12:47:28 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vwGrantTracking] as

Select 
	q.ContractId as ContractId, 
	t.ParentContractId as ParentContractId, 
	r.HeaderContractId as HeaderContract, 
	r.Recipient as Recipient
from  (Select Id as ContractId from Contract Where WorkflowId In (Select Id from Workflow Where ApplicationId = (Select top 1 Id from Application Where Name Like 'GrantTracking%' Order by CreatedDtTm desc) 
and (Name Like 'GrantTrackingApplicationHeader%' or Name Like 'GrantTrackingApplicationLine%')) ) q
full outer join (
		select Distinct 
	p.ContractId as ContractId,
	p1.ContractId as ParentContractId 
	from ContractProperty p
	join ContractProperty p1 on p.Value = p1.Value 
	Where
	p.WorkflowPropertyId = (Select Id from vwGrantTrackingApplicationLineWorkflowProperty Where Name = 'parentContractId')
	and
	(p1.WorkflowPropertyId = (Select Id from vwGrantTrackingApplicationLineWorkflowProperty Where Name = 'id')
	 or
	p1.WorkflowPropertyId = (Select Id from vwGrantTrackingApplicationHeaderWorkflowProperty Where Name = 'id'))
	and 
	(Select top 1 HeaderContract from vwGrantTrackingHeaderLineMapping Where ContractId = p.ContractId) = (Select top 1 HeaderContract from vwGrantTrackingHeaderLineMapping Where ContractId = p1.ContractId)) t 
on q.ContractId = t.ContractId

full outer  join (
	Select Distinct 
		pc.Id as HeaderContractId, 
		p.ContractId as ContracctId, 
		p.Value as HeaderContractAddress,
		concat(usr.FirstName,' ', usr.LastName) as Recipient 
	from Contract pc
	join ContractProperty p on p.Value = pc.LedgerIdentifier --get headercontract
	join ContractProperty p1 on p.ContractId = p1.ContractId
	join UserChainMapping ucm on ucm.ChainIdentifier = p1.Value
	join [User] usr on usr.Id = ucm.UserID
	Where pc.WorkflowId In (Select Id from Workflow Where ApplicationId = (Select top 1 Id from Application Where Name Like 'GrantTracking%' Order by CreatedDtTm desc) 
and (Name Like 'GrantTrackingApplicationHeader%' or Name Like 'GrantTrackingApplicationLine%'))
	and p.WorkflowPropertyId = (
	(Select Id from WorkflowProperty Where WorkflowId = (Select Id from Workflow Where ApplicationId = (Select top 1 Id from Application Where Name Like 'GrantTracking%' Order by CreatedDtTm desc)
 and Name Like 'GrantTrackingApplicationLine%') and (Name = 'headerContractAddress')))
 and p1.WorkflowPropertyId = (
	(Select Id from WorkflowProperty Where WorkflowId = (Select Id from Workflow Where ApplicationId = (Select top 1 Id from Application Where Name Like 'GrantTracking%' Order by CreatedDtTm desc)
 and Name Like 'GrantTrackingApplicationLine%') and (Name = 'recipient')))
	union
	Select 
		c.Id as ContractId, 
		c.Id as HeaderContractId, 
		c.LedgerIdentifier as HeaderContractAddress,
		concat(usr.FirstName,' ', usr.LastName) as Recipient 
	from Contract c
	join [User] usr on  c.DeployedByUserId = usr.Id
	Where WorkflowId =  (Select Id from Workflow Where ApplicationId = (Select top 1 Id from Application Where Name Like 'GrantTracking%' Order by CreatedDtTm desc) 
and Name Like 'GrantTrackingApplicationHeader%')) r 
on q.ContractId = r.ContracctId
GO


