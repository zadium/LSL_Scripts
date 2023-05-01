/**
    @name: ImageProfile
    @description:

    @version: 0.1
    @updated: "2023-05-01 23:32:11"
    @revision: 3
    @localfile: ?defaultpath\Scripts\?@name.lsl
    @license: MIT

    @ref:

    @notice:
*/
//string homeURI = "";
string homeURI = "http://grid.3rdrockgrid.com:8002/";
//string homeURI = "http://login.osgrid.org/";
//string homeURI = "http://discoverygrid.net:8002/";

integer face = 2;

//*-----------------------------------------------------------

key http_request_image = NULL_KEY;

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
    "WebUrl": " ",
    "WantToMask": 3,
    "WantToText": " ",
    "SkillsMask": 16,
    "SkillsText": " ",
    "Language": " ",
    "ImageId": "04b191a9-ecd1-4bad-b701-ea2cf15a01fc",
    "AboutText": "Lazy to write\n",
    "FirstLifeImageId": "3954c8cb-3495-4b74-a3b9-e08f6e992f90",
    "FirstLifeText": "Nop leave me alone"
  }
}
*/

requestProfileImage(string profilServer, key avatarKey)
{
    string request = llList2Json(JSON_OBJECT, [
      "jsonrpc", "2.0",
      "id", (string)llGenerateKey(),
      "method", "avatar_properties_request",
      "params", llList2Json( JSON_OBJECT, [
        "UserId", avatarKey
        ])
    ]);
    http_request_image = llHTTPRequest(profilServer, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/json-rpc"], request);
}

default
{
    state_entry()
    {
        llSetTexture(TEXTURE_BLANK, face);
    }

    touch_start(integer number)
    {
        key avatarKey = llDetectedKey(0);
        if (homeURI == "")
            homeURI = osGetGridHomeURI(); //* some grid/regions not enabled it
        requestProfileImage(homeURI, avatarKey);
    }

    http_response(key request_id, integer status, list metadata, string body)
    {
        if (request_id == http_request_image)
        {
            string imageID = llJsonGetValue(body, ["result", "ImageId"]);
            if (imageID == "")
                imageID = TEXTURE_BLANK;
            llSetTexture(imageID, face);
        }
    }
}