--delete an Entity
use "LogRhythmEMDB"
go

--------------------------------------------------------------------------------------------
--------------------- PLEASE NEVER NEVER DELETE ENTITY ID 1 --------------------------------
--------------------------------------------------------------------------------------------
declare @EntityId int
declare @EntityName varchar(50)


Set @EntityName = 'zRetired'

DECLARE EntityCursor CURSOR
FOR Select entityid
    from dbo.Entity
    where FullName like @EntityName

Begin tran

Open EntityCursor; 
While (1 = 1)
Begin
	Fetch NEXT from EntityCursor
	into @EntityId;

	if (@@FETCH_STATUS <> 0)
	    break;

    if (@EntityId = 1 or @EntityId = -100)
	begin
	    raiserror('Deleting EntityID: %d Not Allowed',0,1,@EntityId) with nowait;
		break;
    end;

	Print 'Deleting records for EntityID: ' + convert(varchar(9),@EntityId);

	Print 'Deleting records from UserProfileLSPerm';
	Delete dbo.UserProfileLSPerm where MsgSourceID in (select MsgSourceID from dbo.MsgSource where (SystemMonitorID in (select SystemMonitorID from dbo.SystemMonitor where HostID in (select HostId from dbo.Host where EntityID = @EntityId)) OR  hostid in (select hostid from dbo.Host where EntityID = @EntityId)))

	Print 'Deleting records from AIEEngineToMsgSource';
	Delete dbo.AIEEngineToMsgSource where MsgSourceID in (select MsgSourceID from dbo.MsgSource where (SystemMonitorID in (select SystemMonitorID from dbo.SystemMonitor where HostID in (select HostId from dbo.Host where EntityID = @EntityId)) OR  hostid in (select hostid from dbo.Host where EntityID = @EntityId)))

	Print 'Deleting records from HostIdentifierToMsgSource';
	Delete dbo.HostIdentifierToMsgSource where MsgSourceID in (select msgsourceid from dbo.MsgSource where (SystemMonitorID in (select SystemMonitorID from dbo.SystemMonitor where HostID in (select HostId from dbo.Host where EntityID = @EntityId)) OR  hostid in (select hostid from dbo.Host where EntityID = @EntityId)))

	Print 'Deleting records from MsgSource';
	Delete dbo.MsgSource where (SystemMonitorID in (select SystemMonitorID from dbo.SystemMonitor where HostID in (select HostId from dbo.Host where EntityID = @EntityId)) OR  hostid in (select hostid from dbo.Host where EntityID = @EntityId))

	Print 'Deleting records from FIMPolicyToSystemMonitor';
	delete dbo.FIMPolicyToSystemMonitor where SystemMonitorID in (select SystemMonitorID from dbo.SystemMonitor where HostID in (select HostId from dbo.Host where EntityID = @EntityId))

	Print 'Deleting records from RIMPolicyToSystemMonitor';
	delete dbo.RIMPolicyToSystemMonitor where SystemMonitorID in (select SystemMonitorID from dbo.SystemMonitor where HostID in (select HostId from dbo.Host where EntityID = @EntityId))
	
	Print 'Deleting records from SMSNMPV3Credential';
	delete dbo.SMSNMPV3Credential where SystemMonitorID in (select SystemMonitorID from dbo.SystemMonitor where HostID in (select HostId from dbo.Host where EntityID = @EntityId))

	Print 'Deleting records from MediatorSession';
	Delete dbo.MediatorSession where SystemMonitorID in (select SystemMonitorID from dbo.SystemMonitor where HostID in (select HostId from dbo.Host where EntityID = @EntityId))

	Print 'Deleting records from SystemMonitorToMediator';
	Delete dbo.SystemMonitorToMediator where SystemMonitorID in (select SystemMonitorID from dbo.SystemMonitor where HostID in (select HostId from dbo.Host where EntityID = @EntityId))

	Print 'Deleting records from SMConfigPolicyToSM';
	Delete dbo.SMConfigPolicyToSM where SystemMonitorID in (select SystemMonitorID from dbo.SystemMonitor where HostID in (select HostId from dbo.Host where EntityID = @EntityId))

	Print 'Deleting records from AlarmRuleActionToSM';
	Delete dbo.AlarmRuleActionToSM where SystemMonitorID in (select SystemMonitorID from dbo.SystemMonitor where HostID in (select HostId from dbo.Host where EntityID = @EntityId))

	Print 'Deleting records from SystemMonitor';
	delete dbo.SystemMonitor where HostID in (select HostId from dbo.Host where EntityID = @EntityId)

	Print 'Deleting records from HostIdentifier';
	Delete dbo.HostIdentifier WHERE HostID in (select HostId from dbo.Host where EntityID = @EntityId)
	
	Print 'Deleting records from ObjectControl';
	Delete dbo.ObjectControl WHERE EntityId = @EntityId

	Print 'Deleting records from WatchItem';
	delete dbo.WatchItem where NetworkID in (select NetWorkID from dbo.Network WHERE EntityID = @EntityId)

	Print 'Deleting records from Network';
	Delete dbo.Network WHERE EntityId = @EntityId
	
	Print 'Deleting records from WatchItem';
	Delete dbo.WatchItem WHERE HostID in (select HostId from dbo.Host where EntityID = @EntityId)

	Print 'Deleting records from UserProfileEntityPerm';
	Delete dbo.UserProfileEntityPerm WHERE entityid = @EntityId

	Print 'Updating records in SCUser ';
	Update dbo.SCUser set DefaultEntityID = 1 where DefaultEntityID = @EntityId
	
	--once the above done for all entities, then delete each from the host
	Print 'Deleting records from Host';
	delete dbo.Host where EntityID = @EntityId

	--Check if this is parent entity or child
	Print 'Deleting Entity record';
	delete dbo.Entity where EntityID = @EntityId
End;

Close EntityCursor;
DEALLOCATE EntityCursor;

commit tran


