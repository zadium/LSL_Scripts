/**
    @name: SplitTipJar
    @description: Free OpenSource Split Tip Jar

    @author: Zai Dium
    @version: 1.3
    @updated: "2024-04-22 22:26:24"
    @revision: 23
    @localfile: ?defaultpath\TipBottle\?@name.lsl
    @license: OpenSource: MIT

    @ref:

    @notice:
        change splitTo your partener name
        and splitRate to the rate 50% = 0.5
*/
//* settings

list moneyList = [2, 4, 6, 8];
float splitRate = 0.5; //* 50%
string splitTo = ""; //* Name of Avatar

integer particles = TRUE;
//* variables
string full_version = "Split Tip Jar 1.3";

integer total_amount = 0;
integer permitted = FALSE;

integer clearParticlesAfter = 3; //* after seconds

clearParticles()
{
    llParticleSystem ([]);
}

sendParticles(key target)
{
    clearParticlesAfter = 3;
    llSetTimerEvent(1);
    llParticleSystem (
    [
        PSYS_PART_FLAGS, PSYS_PART_TARGET_POS_MASK,
        PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_ANGLE_CONE,
        PSYS_SRC_BURST_PART_COUNT, 15,
        PSYS_SRC_BURST_RATE, 0.4,
        PSYS_PART_MAX_AGE, 1,

        PSYS_SRC_OMEGA, <0.25, 0.25, 0.25>,
//        PSYS_PART_START_SCALE, <0.25, 0.25, 0.25>,
//        PSYS_PART_END_SCALE,  <0.25, 0.25, 0.25>,


        PSYS_SRC_BURST_RADIUS, 5,
        PSYS_SRC_BURST_SPEED_MIN, 1,
        PSYS_SRC_BURST_SPEED_MAX, 10,
        PSYS_SRC_ANGLE_BEGIN, 0,
        PSYS_SRC_ANGLE_END, PI,
        PSYS_SRC_MAX_AGE, clearParticlesAfter,
        PSYS_SRC_TARGET_KEY, target,
        PSYS_SRC_TEXTURE,  "Money"
    ]
    );
}

key last_paid_id = NULL_KEY;

key getAviKey(string avi_name)
{
    avi_name = llToLower(avi_name);
    integer len = llStringLength(avi_name);
    list avatars = llGetAgentList(AGENT_LIST_PARCEL, []);
    integer count = llGetListLength(avatars);

    integer index;
    string name;
    key id;
    while (index < count)
    {
        id = llList2Key(avatars, index);
        name = llGetSubString(llToLower(llKey2Name(id)), 0, len - 1);
        if ((name == avi_name) && (!osIsNpc(id)))
            return id;
        ++index;
    }
    return NULL_KEY;
}

updateText()
{
    string s = "Total Tip " + (string)total_amount;
    if (last_paid_id != NULL_KEY)
         s += "\nLast tip from " + llGetDisplayName(last_paid_id);
    llSetText(s, <1.0, 1.0, 1.0>, 1.0);
}

default
{
    state_entry()
    {
        clearParticles();
        llSetPayPrice(PAY_HIDE, moneyList);

        if (llGetOwner() == llGetCreator())
            llSetObjectName(full_version);

        if (splitTo != "")
            llRequestPermissions(llGetOwner(), PERMISSION_DEBIT);
    }

    on_rez(integer number)
    {
        llResetScript();
    }

    touch_start(integer num_detected)
    {
        key id = llDetectedKey(0);
        if ((splitTo != "") && (!permitted)) {
            if (id == llGetOwner())
                llRequestPermissions(llGetOwner(), PERMISSION_DEBIT);
            else
                llRegionSayTo(id, 0, "Setup not complete, need permissions");
        }
        else
        {
            llRegionSayTo(id, 0, llGetDisplayName(id)+" right click, then click Pay button for donation");
        }
    }

    run_time_permissions(integer perm)
    {
        if(perm & PERMISSION_DEBIT) {
           permitted = TRUE;
            llSetPayPrice(PAY_HIDE, moneyList);
        }
    }

    money(key id, integer amount)
    {
        total_amount += amount;
        string msg = llGetDisplayName(id) + " donated " + (string)amount  + " to " + llGetDisplayName(llGetOwner());

        key playerID;
        if (splitTo == "")
            playerID = NULL_KEY;
        else
            playerID = getAviKey(splitTo);

        if (playerID != NULL_KEY)
        {
            msg = msg + " and " + splitTo;
            llGiveMoney(playerID, (integer)(amount * splitRate));
            llRegionSayTo(id, 0, "Thank you for payment, you donated " + (string)amount + " to " + llGetDisplayName(llGetOwner()) + " and " + splitTo);
            last_paid_id = id;
            updateText();
            if (particles)
                sendParticles(playerID);
        }
        else
        {
            if (splitTo != "")
                llOwnerSay(splitTo + " no exists in the same region");
            llRegionSayTo(id, 0, "Thank you for payment, you donated " + (string)amount + " to " + llGetDisplayName(llGetOwner()));
        }

        llInstantMessage(llGetOwner(), msg);
        llSay(0, msg);
    }

    timer()
    {
        if (clearParticlesAfter>0)
         {
            clearParticlesAfter--;
            if (clearParticlesAfter==0)
                clearParticles();
         }
    }
}
