/**
    @name: ImageProfile
    @description:

    @version: 0.1
    @updated: "2023-05-03 23:21:25"
    @revision: 175
    @localfile: ?defaultpath\Scripts\?@name.lsl
    @license: MIT

    @ref:

    @notice:
*/

string homeURI = ""; //* set homeURI get override if osGetAvatarHomeURI not enabled, you can get it by link messages

//string homeURI = "http://grid.3rdrockgrid.com:8002/";
//string homeURI = "http://login.osgrid.org/";
//string homeURI = "http://hg.osgrid.org/";
//string homeURI = "http://discoverygrid.net:8002/";

integer face = 2; //* a face to change texture to put profile image on it

//*-----------------------------------------------------------

key http_request_image = NULL_KEY;
key avatarKey = NULL_KEY; //* avatar to get profile image
integer req_id = 0; //* just an id send to server and reposnd by it

/** JSON request

{
  "jsonrpc": "2.0",
  "id": "9dd85ed8-17d0-45f1-834d-032b24273c1d",
  "method": "avatar_properties_request",
  "params":
  {
    "UserId":"d09baea8-ea9f-4372-866c-338b7a54f72b"
  }
}
*/

/** JSON result
{
  "id": "ea6c1588-7571-4b42-84c6-357dda23a5cd",
  "jsonrpc": "2.0",
  "result": {
    "UserId": "2a2680ff-215b-4720-8549-684fa9ab0046",
    "Language": " ",
    "ImageId": "04b191a9-ecd1-4bad-b701-ea2cf15a01fc",
  }
}
*/

//* Using JSON-RPC to fetch the uuid of profile image of uuid
//* should send to service uri that come from XML-RPC
requestProfileImage(string profilServer, key aviKey)
{
    req_id++;
    string request = llList2Json(JSON_OBJECT, [
              "jsonrpc", "2.0",
              "id", (string)req_id,
              "method", "avatar_properties_request",
              "params", llList2Json(JSON_OBJECT, [
                "UserId", aviKey
        ])
    ]);
    http_request_image = llHTTPRequest(profilServer, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/json-rpc"], request);
}

key http_profile_server = NULL_KEY;

//* Using XML-RPC to get the uri of of profile server, i wish we can use jspn-rpc, maybe we need to ask it as feature request
requestProfileServer(key aviKey)
{
    avatarKey = aviKey;
    string home = getHomeURI(aviKey);
    req_id++;
    string request = "<?xml version=\"1.0\" encoding=\"utf-8\"?>";
    request += "<methodCall>";
        request += "<id>"+(string)req_id+"</id>";
        request += "<methodName>get_server_urls</methodName>";
        request += "<params>";
            request += "<param><value><struct>";
            request += "<member><name>userID</name><value><string>"+ (string)aviKey +"</string></value></member></struct></value></param>";
        request += "</params>";
    request += "</methodCall>";
    http_profile_server = llHTTPRequest(home, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/xml"], request);
}

//* a trick to get override if osGetAvatarHomeURI not exists
string getHomeURI(key aviKey)
{
    string home;
    if (homeURI == "")
        home = osGetAvatarHomeURI(aviKey);
    else
    {
        string name = llGetUsername(aviKey);
        integer p = llSubStringIndex(name, "@");
        if (p>0)
            home = "http://"+llStringTrim(llGetSubString(name, p + 1, llStringLength(name)), STRING_TRIM);
        else
            home = homeURI;
//		llOwnerSay(name);
    }
//	llOwnerSay("home:`"+home+"`");
    return home;
}

//* convert xml to strided list, stuid idea but it work :)
string parseXMLValue(string xml, string name)
{
    integer p = llSubStringIndex(xml, "?>"); //* remove xml header
    xml = llGetSubString(xml, p + 1, -1);

    //* if we have regex :( we will use "/<name>(.+)<\/name>|<string>(.+)<\/string>/" //* ChatGPT hand is here yes :D
    //* or this stupid idea do not laugh
    list matches = llParseString2List(xml, ["methodResponse>", "params>", "param>", "value>", "struct>", "member>", "name>", "string>", "</", "<", ">"], ["\n", " "]);

    p = llListFindList(matches, [name]);
    //llOwnerSay(llDumpList2String(matches, "\n"));
    //llOwnerSay("server: " + llList2String(matches, p+1));
    return llList2String(matches, p+1);
}

default
{
    state_entry()
    {
        llSetTexture(TEXTURE_BLANK, face);
    }

    touch_start(integer number)
    {
        if (llGetLinkNumber() == 0) //* for testing if it root we can take touch
        {
            avatarKey = llDetectedKey(0);
    //      requestProfileImage(homeURI, avatarKey); //* nop we need it from xml rpc
            requestProfileServer(avatarKey);
        }
    }

    http_response(key request_id, integer status, list metadata, string body)
    {
        if (request_id == http_profile_server)
        {
            string profileServer = parseXMLValue(body, "SRV_ProfileServerURI");
            if (profileServer!="")
                requestProfileImage(profileServer, avatarKey);
        }
        else if (request_id == http_request_image)
        {
            string imageID = llJsonGetValue(body, ["result", "ImageId"]);
            if (imageID == "")
                imageID = TEXTURE_BLANK;
            else
                llSetTexture(imageID, face);
        }
    }

    link_message(integer sender_num, integer num, string message, key id)
    {
        list params = llParseStringKeepNulls(message,[";"],[""]);
        string cmd = llToLower(llList2String(params,0));
        params = llDeleteSubList(params, 0, 0);
        if (cmd == "homeuri")
        {
            homeURI = llList2String(params, 0);
            llSetTexture(TEXTURE_BLANK, face);
//            llOwnerSay("homeURI:"+homeURI);
        }
        else if (cmd == "profile_image")
        {
             requestProfileServer(id);
        }
    }

}