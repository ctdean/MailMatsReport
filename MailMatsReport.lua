----
---- MailMatsReport
----
---- Chris Dean

local MailMatsReport = LibStub("AceAddon-3.0"):NewAddon("MailMatsReport")

function MailMatsReport:OnInitialize()
    local defaults = {
        profile = {
            bank = true,
            items = {},
        }
    }
    local acedb = LibStub:GetLibrary("AceDB-3.0")
    self.db = acedb:New("MailMatsReportDB", defaults)
end

function MailMatsReport:Print( str )
   print( "|cff15ff00Mail Mats Report|r: " .. str )
end

function MailMatsReport:ValidItems()
    res = {}
    for item, flag in pairs(self.db.profile.items) do
       if( flag ) then
           table.insert( res, item )
       end
    end

    table.sort( res )
    return( res )
end

function MailMatsReport:Help()
    MailMatsReport:Print( "Send a report of your stuff via email" )
    MailMatsReport:Print( "/mlr send recipient -- send the mail" )
    MailMatsReport:Print( "/mlr list -- list all the items that are being tracked" )
    MailMatsReport:Print( "/mlr add count name -- track this item" )
    MailMatsReport:Print( "/mlr rm name -- don't track this item" )
end

function MailMatsReport:ItemSummary( name )
    local n = self.db.profile.items[name]
    return( string.format( "%s => %s / %s", name, GetItemCount(name, true), n ) )
end

function MailMatsReport:Send( recipient )
    if( not recipient ) then
       MailMatsReport:Print( "Need recipient" )
    else
        body = date( "Mail Mats Report for %a %d %b %Y %X\n\n" )
        for i, item in pairs(self:ValidItems()) do
            body = body .. self:ItemSummary( item ) .. "\n"
        end
        SendMail( recipient, "Mail Mats Report", body )
        MailMatsReport:Print( string.format( "sent to %s", recipient ) )
    end
end

function MailMatsReport:Say()
    local seen = false
    for i, item in pairs(self:ValidItems()) do
        SendChatMessage( self:ItemSummary( item ), "SAY", nil, nil )
        seen = true
    end
    if not seen then 
        self:Print("None") 
    end
end

function MailMatsReport:List()
    local seen = false
    for i, item in pairs(self:ValidItems()) do
        self:Print( self:ItemSummary( item ) )
        seen = true
    end
    if not seen then 
        self:Print("None") 
    end
end

function MailMatsReport:Add( arg )
    local num, item_name = string.match( arg, "%s*(%d+)%s+(.+)" )
    if( (not num) or (not item_name) ) then
        self:Print( "usage: add count item" )
    else 
        local name = GetItemInfo( item_name )
        self.db.profile.items[name] = tonumber( num )
        self:Print( string.format( "add %s for %s", num, name ) )
    end
end

function MailMatsReport:Remove( item_name )
    local name = GetItemInfo( item_name )
    if( not self.db.profile.items[name] ) then
        MailMatsReport:Print( string.format( "never seen %s", name ) )
    else
        self.db.profile.items[name] = nil
        MailMatsReport:Print( string.format( "removed %s", name ) )
    end
end

SLASH_MAILMATSREPORT1 = "/mmr"
SLASH_MAILMATSREPORT2 = "/mailmatsreport"
SlashCmdList["MAILMATSREPORT"] = function( msg )
    local cmd, arg = string.split(" ", msg or "", 2 )
    cmd = string.lower(cmd or "")

    if( cmd == "send" ) then
       MailMatsReport:Send( arg )
    elseif( cmd == "list" ) then
        MailMatsReport:List()
    elseif( cmd == "say" ) then
        MailMatsReport:Say()
    elseif( cmd == "add" ) then
        MailMatsReport:Add( arg )
    elseif( cmd == "rm" ) then
        MailMatsReport:Remove( arg )
    else
        MailMatsReport:Help()
    end
end
