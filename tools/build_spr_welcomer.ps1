# Builds sprites/spr_welcomer from downloaded Welcomer walk pack (8 dirs x 4 frames).
$assetRoot = "c:\Users\bilod\Downloads\top-down_RPG_style_Welcomer_settlement_intake_offi\top-down_RPG_style_Welcomer_settlement_intake_offi"
$walkRoot = Join-Path $assetRoot "animations\Walking-aaaa55ca"
$sprDir = Join-Path $PSScriptRoot "..\sprites\spr_welcomer"
$layerName = "0679e5ba-f3fd-4212-b8a5-eb8993757d5a"

# facing_dir order used by obj_npc / GuidedIntro_FaceToward
$dirs = @("north", "north-east", "east", "south-east", "south", "south-west", "west", "north-west")

if (-not (Test-Path $walkRoot)) {
    Write-Error "Walk animation folder not found: $walkRoot"
    exit 1
}

Get-ChildItem $sprDir -Filter "*.png" -File | Remove-Item -Force
if (Test-Path (Join-Path $sprDir "layers")) {
    Remove-Item (Join-Path $sprDir "layers") -Recurse -Force
}

$frameGuids = New-Object System.Collections.Generic.List[string]
$seqKeyframes = New-Object System.Collections.Generic.List[string]

$fi = 0
foreach ($d in $dirs) {
    for ($f = 0; $f -lt 4; $f++) {
        $frameFile = ('frame_{0:d3}.png' -f $f)
        $src = Join-Path (Join-Path $walkRoot $d) $frameFile
        if (-not (Test-Path $src)) {
            Write-Error "Missing frame: $src"
            exit 1
        }
        $guid = [guid]::NewGuid().ToString()
        $frameGuids.Add($guid) | Out-Null
        Copy-Item $src (Join-Path $sprDir "$guid.png") -Force
        $layerDir = Join-Path $sprDir "layers\$guid"
        New-Item -ItemType Directory -Force -Path $layerDir | Out-Null
        Copy-Item $src (Join-Path $layerDir "$layerName.png") -Force

        $kfId = [guid]::NewGuid().ToString()
        $seqKeyframes.Add(@"
            {`"`$Keyframe<SpriteFrameKeyframe>`":`"`,`"Channels`":{
                `"0`":{`"`$SpriteFrameKeyframe`":`"`,`"Id`":{`"name`":`"$guid`",`"path`":`"sprites/spr_welcomer/spr_welcomer.yy`",},`"resourceType`":`"SpriteFrameKeyframe`",`"resourceVersion`":`"2.0`",},
              },`"Disabled`":false,`"id`":`"$kfId`",`"IsCreationKey`":false,`"Key`":$fi.0,`"Length`":1.0,`"resourceType`":`"Keyframe<SpriteFrameKeyframe>`",`"resourceVersion`":`"2.0`",`"Stretch`":false,},
"@) | Out-Null
        $fi++
    }
}

$framesJson = ($frameGuids | ForEach-Object {
    "    {`"`$GMSpriteFrame`":`"v1`",`"%Name`":`"$_`",`"name`":`"$_`",`"resourceType`":`"GMSpriteFrame`",`"resourceVersion`":`"2.0`",},"
}) -join "`n"

$seqJson = $seqKeyframes -join "`n"

$yy = @"
{
  "`$GMSprite":"v2",
  "%Name":"spr_welcomer",
  "bboxMode":0,
  "bbox_bottom":88,
  "bbox_left":28,
  "bbox_right":64,
  "bbox_top":18,
  "collisionKind":1,
  "collisionTolerance":0,
  "DynamicTexturePage":false,
  "edgeFiltering":false,
  "For3D":false,
  "frames":[
$framesJson
  ],
  "gridX":4,
  "gridY":4,
  "height":92,
  "HTile":false,
  "layers":[
    {"`$GMImageLayer":"","%Name":"$layerName","blendMode":0,"displayName":"default","isLocked":false,"name":"$layerName","opacity":100.0,"resourceType":"GMImageLayer","resourceVersion":"2.0","visible":true,},
  ],
  "name":"spr_welcomer",
  "nineSlice":null,
  "origin":7,
  "parent":{
    "name":"Welcomer",
    "path":"folders/Sprites/PlayerAndNPC/Welcomer.yy",
  },
  "preMultiplyAlpha":false,
  "resourceType":"GMSprite",
  "resourceVersion":"2.0",
  "sequence":{
    "`$GMSequence":"v1",
    "%Name":"spr_welcomer",
    "autoRecord":true,
    "backdropHeight":768,
    "backdropImageOpacity":0.5,
    "backdropImagePath":"",
    "backdropWidth":1366,
    "backdropXOffset":0.0,
    "backdropYOffset":0.0,
    "events":{
      "`$KeyframeStore<MessageEventKeyframe>":"",
      "Keyframes":[],
      "resourceType":"KeyframeStore<MessageEventKeyframe>",
      "resourceVersion":"2.0",
    },
    "eventStubScript":null,
    "eventToFunction":{},
    "length":32.0,
    "lockOrigin":false,
    "moments":{
      "`$KeyframeStore<MomentsEventKeyframe>":"",
      "Keyframes":[],
      "resourceType":"KeyframeStore<MomentsEventKeyframe>",
      "resourceVersion":"2.0",
    },
    "name":"spr_welcomer",
    "playback":1,
    "playbackSpeed":0.0,
    "playbackSpeedType":0,
    "resourceType":"GMSequence",
    "resourceVersion":"2.0",
    "showBackdrop":true,
    "showBackdropImage":false,
    "timeUnits":1,
    "tracks":[
      {"`$GMSpriteFramesTrack":"","builtinName":0,"events":[],"inheritsTrackColour":true,"interpolation":1,"isCreationTrack":false,"keyframes":{"`$KeyframeStore<SpriteFrameKeyframe>":"","Keyframes":[
$seqJson
          ],"resourceType":"KeyframeStore<SpriteFrameKeyframe>","resourceVersion":"2.0",},"modifiers":[],"name":"frames","resourceType":"GMSpriteFramesTrack","resourceVersion":"2.0","spriteId":null,"trackColour":0,"tracks":[],"traits":0,},
    ],
    "visibleRange":null,
    "volume":1.0,
    "xorigin":46,
    "yorigin":92,
  },
  "swatchColours":null,
  "swfPrecision":0.5,
  "textureGroupId":{
    "name":"Default",
    "path":"texturegroups/Default",
  },
  "type":0,
  "VTile":false,
  "width":92,
}
"@

$yyPath = Join-Path $sprDir "spr_welcomer.yy"
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($yyPath, $yy, $utf8NoBom)
Write-Host "Built spr_welcomer with $($frameGuids.Count) frames."
