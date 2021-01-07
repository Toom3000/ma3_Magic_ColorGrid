--[[
Magic_ColorGrid v1.0.2

MIT License

Copyright 2020 Thomas Baumann

Permission is hereby granted, free of charge, to any person obtaining a copy 
of this software and associated documentation files (the "Software"), to deal 
in the Software without restriction, including without limitation the rights 
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
copies of the Software, and to permit persons to whom the Software is 
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in 
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
DEALINGS IN THE SOFTWARE.
--]]

local pluginName    = select(1,...);
local componentName = select(2,...);
local signalTable   = select(3,...);
local my_handle     = select(4,...);

_DEBUG = false

if _DEBUG == true then
	function Cmd(a)
	end

	function Confirm(a,b)
		return true
	end

	function Printf(a)
	end

	function Echo(a)
	end

	function GetTokenName(a)
	end
	
	function DataPool(a)
	end

	function PopupInput(a,b,c)
		return 1,"Install ColorGrid"
	end
end

-- Some wrappers to the internal functions
local C = Cmd
local Printf = Printf
local Echo = Echo

-- Some kind of version string
local cColorGridVersionText = "Magic ColorGrid by Toom"

local cGridTypeMacro = "macro"
local cGridTypeLabel = "label"

-- Main parameters structure
local gParams = {
	mVar = {
		mDelaytimeName = "CG_DELAYTIME",
		mDelaytimeDefaultVal = "0",
		mFadetimeName = "CG_FADETIME",
		mFadetimeDefaultVal = "0",
		mDelayDirStateNamePrefix = "CG_DELAYDIR_STATE_GROUP_",
		mDelayDirStateNameLastPrefix = "CG_DELAYDIR_STATE_GROUP_LAST_",
		mDelayDirStateMaxNo = 0,
		mColorValStateNamePrefix = "CG_COLORVAL_STATE_GROUP_",
		mColorValStateNameLastPrefix = "CG_COLORVAL_STATE_GROUP_LAST_",
		mColorValStateMaxNo = 0,
		mColorExecModeName = "CG_COLOREXEC_MODE",
		mColorExecModeDefaultVal = "direct",
		mSeqInvalidOffsetName = "CG_MACROINVALID_OFFSET",
		mSeqInvalidOffsetNameValActive = 10000,
		mSeqInvalidOffsetNameValInactive = 0,
	},
	mGroup = {
		mMaxCheckNo = 128,
		mCurrentGroupNo = 0,
		mGroups = {
		},
	},
	mImage = {
		mBaseExecNo = 2000,
		mBaseStorageNo = 0,
		mBaseStorageCurrentPos = 0,
		mGridItemInactiveNo,
		mGridItemActiveNo,
		mGridItemAllNo,
		mDelayLeftInactiveNo,
		mDelayRightInactiveNo,
		mDelayInOutInactiveNo,
		mDelayOutInInactiveNo,
		mDelayOffInactiveNo,
		mDelayLeftActiveNo,
		mDelayRightActiveNo,
		mDelayInOutActiveNo,
		mDelayOutInActiveNo,
		mDelayOffActiveNo,
	},
	mAppearance = {
		mBaseNo = 2000,
	},
	mPreset = {
		mBaseNo = 2000,
	},
	mSequence = {
		mBaseNo = 2000,
	},
	mMacro = {
		mBaseNo = 2000,
		mWaitTime = "0.1",
		mDelayWaitTime = "0.3",
		mDelayOffMacroNo = 0,
		mAllColorWhiteMacroNo = 0,
		mDelayTimeZeroMacroNo = 0,
		mFadeTimeZeroMacroNo = 0,
		mColorExecModeMacroNo = 0,
	},
	mLayout = {
		mBaseNo = 2000,
		mWidth = 50,
		mHeight = 50,
		mVisibilityObjectName = "off",
		mLayoutName = "Magic ColorGrid",
	},
	mMaxGelNo = 13,
	mMaxDelayMacroNo = 5,
	mMaxDelayTimeNo = 5,
	mColorGrid = {
		mCurrentRowNo = 1;
		mGrid = {
		}
	},
}

-- Gels array
-- Holds the names and the appearance colors in RGB-A
local gMaGels = {
	[1] = {
		mName = "White",
		mColor = "1.00,1.00,1.00,1.00"
	},
	[2] = {
		mName = "Red",
		mColor = "1.00,0.00,0.00,1.00"
	},
	[3] = {
		mName = "Orange",
		mColor = "1.00,0.50,0.00,1.00"
	},
	[4] = {
		mName = "Yellow",
		mColor = "1.00,1.00,0.00,1.00"
	},
	[5] = {
		mName = "Fern Green",
		mColor = "0.50,1.00,0.00,1.00"
	},
	[6] = {
		mName = "Green",
		mColor = "0.00,1.00,0.00,1.00"
	},
	[7] = {
		mName = "Sea Green",
		mColor = "0.00,1.00,0.50,1.00"
	},
	[8] = {
		mName = "Cyan",
		mColor = "0.00,1.00,1.00,1.00"
	},
	[9] = {
		mName = "Lavender",
		mColor = "0.00,0.50,1.00,1.00"
	},
	[10] = {
		mName = "Blue",
		mColor = "0.00,0.00,1.00,1.00"
	},
	[11] = {
		mName = "Violet",
		mColor = "0.50,0.00,1.00,1.00"
	},
	[12] = {
		mName = "Magenta",
		mColor = "1.00,0.00,1.00,1.00"
	},
	[13] = {
		mName = "Pink",
		mColor = "1.00,0.00,0.50,1.00"
	}
}

-- *********************************************************************
-- Shortcut Table for grandMA3 pools
-- *********************************************************************

local function getGma3Pools()
    return {
        -- token = PoolHandle
        Sequence        = DataPool().Sequences;
        World           = DataPool().Worlds;
        Filter          = DataPool().Filters;
        Group           = DataPool().Groups;
        Plugin          = DataPool().Plugins;
        Macro           = DataPool().Macros;
        Matricks        = DataPool().Matricks;
        Configuration   = DataPool().Configurations;
        Page            = DataPool().Pages;
        Layout          = DataPool().Layouts;
        Timecode        = DataPool().Timecodes;
        Preset          = DataPool().PresetPools;
        View            = Root().ShowData.UserProfiles.Default.ViewPool;
        Appearance      = Root().ShowData.Appearances;
        Camera          = Root().ShowData.UserProfiles.Default.CameraPool;
        Sound           = Root().ShowData.Sounds;
        User            = Root().ShowData.Users;
        Userprofile     = Root().ShowData.Userprofiles;
        Scribble        = Root().ShowData.ScribblePool;
        ViewButton      = Root().ShowData.UserProfiles.Default.ScreenConfigurations.Default["ViewButtonPages 2"];
        Screencontents  = Root().ShowData.UserProfiles.Default.ScreenConfigurations.Default.ScreenContents;
        Display         = Root().GraphicsRoot.PultCollect["Pult 1"].DisplayCollect;
        DataPool        = Root().ShowData.DataPools;
        Image           = Root().ShowData.ImagePools;
        Fixturetype     = Root().ShowData.LivePatch.FixtureTypes;
    }
end

local function log(inText)
	Printf("CG Generator: " .. tostring(inText))
end

-- *************************************************************
-- prepare_console
-- *************************************************************

local function prepare_console()
    C('cd root')
    C('clearall')
    C('unpark fixture thru')
end

-- *************************************************************
-- debug_logmetatable
-- *************************************************************

local function debug_logmetatable(inTable)
	for k,v in ipairs(inTable) do
		log("Key=" .. tostring(k) .. " Value=" .. tostring(v) .. " Name=" .. tostring(v.name))
	end	
end

-- *************************************************************
-- debug_logtable
-- *************************************************************

local function debug_logtable(inTable)
	for k,v in pairs(inTable) do
		log("Key=" .. tostring(k) .. " Value=" .. tostring(v))
	end	
end

-- *************************************************************
-- ImageSetDefault
-- *************************************************************

local function ImageCopy(inSourceNo,inTargetNo)
	C("Copy image 'Custom'." .. tostring(inSourceNo) .. " at image 'Custom'." .. tostring(inTargetNo) .. " /o" );
end

-- *************************************************************
-- ImagePrepare
-- *************************************************************

local function ImagePrepare(inName,inFileName)
	local myImageNo = gParams.mImage.mBaseStorageCurrentPos;
	if myImageNo == 0 then
		myImageNo = gParams.mImage.mBaseStorageNo;
	end
	log("[ImagePrepare] Handling image no " .. myImageNo );
	C("Delete Image 'Custom'." .. tostring(myImageNo));
	C("Import Image 'Custom'." .. tostring(myImageNo) .. " /File '" .. inFileName .. "' /nc /o" );
	C("set image 'Custom'." ..  tostring(myImageNo) .. " Property \"Name\" " .. inName );
	gParams.mImage.mBaseStorageCurrentPos = myImageNo + 1;
	return myImageNo;
end

-- *************************************************************
-- getGroupOffset
-- *************************************************************

local function getGroupOffset(inGroupNo)
	local myGroupNo = tonumber(inGroupNo) or 0
	return myGroupNo * (gParams.mMaxGelNo + gParams.mMaxDelayMacroNo + 1 );
end

-- *************************************************************
-- getSeqNo
-- *************************************************************

local function getSeqNo(inNo,inGroupNo)
	return gParams.mSequence.mBaseNo + inNo + getGroupOffset(inGroupNo);
end

-- *************************************************************
-- getMacroNo
-- *************************************************************

local function getMacroNo(inNo,inGroupNo)
	return gParams.mMacro.mBaseNo + inNo + getGroupOffset(inGroupNo);
end

-- *************************************************************
-- getPresetNo
-- *************************************************************

local function getPresetNo(inNo,inGroupNo)
	return gParams.mPreset.mBaseNo + inNo + getGroupOffset(inGroupNo);
end

-- *************************************************************
-- getAppearanceNo
-- *************************************************************

local function getAppearanceNo(inNo,inGroupNo)
	return gParams.mAppearance.mBaseNo + inNo + getGroupOffset(inGroupNo);
end

-- *************************************************************
-- getExecNo
-- *************************************************************

local function getExecNo(inNo,inGroupNo)
	return gParams.mImage.mBaseExecNo + inNo + getGroupOffset(inGroupNo);
end

-- *************************************************************
-- getImageActiveStorageNo
-- *************************************************************

local function getImageActiveStorageNo(inNo,inGroupNo)
	return gParams.mImage.mGridItemActiveNo + inNo + getGroupOffset(inGroupNo);
end

-- *************************************************************
-- getImageInactiveStorageNo
-- *************************************************************

local function getImageInactiveStorageNo(inNo,inGroupNo)
	return gParams.mImage.mGridItemInactiveNo + inNo + getGroupOffset(inGroupNo);
end

-- *************************************************************
-- getUiChannelIdxForAttributeName
-- *************************************************************

local function getUiChannelIdxForAttributeName(inFixtureIndex,inAttributeName)
	local myResult = nil;
	local myAttrIdx = GetAttributeIndex(inAttributeName);
	log("myAttrIdx=" .. myAttrIdx);
	if myAttrIdx ~= nil then
		myResult = GetUIChannelIndex(inFixtureIndex, myAttrIdx);
		log("myResult=" .. tostring(myResult));
	end
	return myResult;
end

local cColMixTypeNone = "None"
local cColMixTypeRGBCMY = "RGB_CMY"
local cColMixTypeWheelFixed = "ColorWheel"

-- *************************************************************
-- groupGetFixtureShortName
-- *************************************************************

local function groupGetFixtureShortName(inGroupNo)
	C("Clear" );
	C("SelFix Group " .. inGroupNo );
	local myFixtureIndex = SelectionFirst(true);
	log("[groupGetFixtureShortName] myFixtureIndex=" .. myFixtureIndex);
	local mySubFixture = GetSubfixture(myFixtureIndex);
	log("[groupGetFixtureShortName] mySubFixture=" .. type(mySubFixture));
	debug_logmetatable(mySubFixture);
	log("[groupGetFixtureShortName] mySubFixture.name=" .. mySubFixture.name);
	return mySubFixture.name;
end

-- *************************************************************
-- getFixtureTypeByName
-- *************************************************************

local function getFixtureTypeByName(inName)
	local myResult = nil;
	local myPools = getGma3Pools();
	local myFixtureType = myPools.Fixturetype;
	log("[getFixtureTypeByName] inName=" .. inName);
	for myKey,myValue in ipairs(myFixtureType) do
		-- This is probed out and seems to work at the moment. Also it is possible to obtain the full name in the .name child
		log("[getFixtureTypeByName]  myValue.name=" .. myValue.name);
		log("[getFixtureTypeByName]  myValue.shortname=" .. myValue.shortname);
		if ( myValue.shortname == inName ) then
			myResult = myValue;
		end
	end	
	return myResult;
end

local cMaxColorValuePerParameter=16777215 -- 256*256*256 It seems that grandMA3 uses 24bit values for any parameter for internal calculation
local cDmxCorrectionFactor8Bit=65793 -- 16777215 / 255


-- *************************************************************
-- convertDmxChannelValue8Bit
-- *************************************************************

local function convertDmxChannelValue8Bit(inValue)
	return math.floor(inValue / cDmxCorrectionFactor8Bit);
end

local cColWheelName="Color1"
local cColSlotAlternates = {
	["White"] = {"open"},
	["Sea Green"] = {"light green"},
	["Cyan"] = {"light blue"},
	["Violet"] = {"purple"},
}

-- *************************************************************
-- addSlotAlternates
-- *************************************************************

local function addSlotAlternates(inSlotName)
	local myResult = {inSlotName}
	local mySlotName = inSlotName
	local mySlotAlternates = cColSlotAlternates[inSlotName];
	if ( mySlotAlternates ~= nil ) then
		for myKey,myValue in pairs(mySlotAlternates) do
			table.insert(myResult,myValue);
		end
	end
	return myResult;
end


-- *************************************************************
-- getGroupColorWheelDmxValueForSlotName
-- *************************************************************

local function getGroupColorWheelDmxValueForSlotName(inGroupNo,inGroupName,inColMixType,inSlotName)
	local myResult = nil
	if ( inColMixType ~= cColMixTypeWheelFixed ) then
		log("[getGroupColorWheelDmxValueForSlotName] Group " .. inGroupNo .. "(" .. inGroupName .. ") does not support color wheel");
	else
		local myFixtureIndex = SelectionFirst(true);
		log("[getGroupColorWheelDmxValueForSlotName] myFixtureIndex=" .. myFixtureIndex);
		local mySubFixture = GetSubfixture(myFixtureIndex);
		log("[getGroupColorWheelDmxValueForSlotName] mySubFixture=" .. tostring(mySubFixture));
		local myColor1UiChannelIdx = getUiChannelIdxForAttributeName(myFixtureIndex,"Color1");
		log("[getGroupColorWheelDmxValueForSlotName] myColor1UiChannelIdx=" .. myColor1UiChannelIdx);
		local myUiChannel = GetUIChannel(myColor1UiChannelIdx);
		log("[getGroupColorWheelDmxValueForSlotName] myUiChannel=" .. tostring(myUiChannel));
		-- We will look for a color wheel named C1
		for myKey,myValue in ipairs(myUiChannel.logical_channel) do
			-- Check if string contains C1...i know this is a bit fuzzy...however we will try
			log("[getGroupColorWheelDmxValueForSlotName] myKey=" .. myKey .. " myValue=" .. tostring(myValue.name));
			if ( string.find(myValue.name,cColWheelName) ~= nil ) then
				log("Found wheel " .. myValue.name);
				-- We found something that looks promising, now try to access the color values.
				-- We will add some alternate names for the slots to have a higher chance of finding something.
				local mySlotAlternates = addSlotAlternates(inSlotName);
				for mySlotAlternateKey,mySlotAlternateValue in pairs(mySlotAlternates) do				
					log("[getGroupColorWheelDmxValueForSlotName] mySlotAlternateValue=" .. mySlotAlternateValue);
					local mySlot = myUiChannel.logical_channel[myKey][mySlotAlternateValue];
					if ( mySlot ~= nil ) then
						log("[getGroupColorWheelDmxValueForSlotName] Found slot " .. mySlot.name);
						local myDmxValue = convertDmxChannelValue8Bit(mySlot.dmxfrom);
						log( "[getGroupColorWheelDmxValueForSlotName] Found slot " .. mySlot.name .. " with DMX Value " ..  myDmxValue);
						myResult = myDmxValue;
						goto exit;
					end
				end
			end
			
		end
	end
::exit::
	return myResult;	
end

local function dummy_test(inColorUiChannelIdx)
	local uichannel = GetUIChannel(inColorUiChannelIdx);
	log("uichannel");
	debug_logtable(uichannel);
	log("uichannel.meta");
	debug_logmetatable(uichannel);
	log("uichannel.flags");
	debug_logtable(uichannel.flags);
	log("uichannel.logical_channel");
	debug_logmetatable(uichannel.logical_channel);
	log("uichannel.logical_channel.name=" .. uichannel.logical_channel.name);
	log("uichannel.logical_channel.name=" .. uichannel.logical_channel[1].name);
	log("uichannel.logical_channel.attribute=" .. uichannel.logical_channel[1].attribute);
	log("uichannel.logical_channel.dmxfrom=" .. uichannel.logical_channel[1].dmxfrom);
	log("uichannel.logical_channel.dmxto=" .. uichannel.logical_channel[1].dmxto);
	log("uichannel.logical_channel[1][\"red\"].name=" .. uichannel.logical_channel[1]["red"].name);
	log("uichannel.logical_channel[1][\"red\"].dmxfrom=" .. convertDmxChannelValue8Bit(uichannel.logical_channel[1]["red"].dmxfrom));
	log("uichannel.logical_channel[1][\"red\"].dmxto=" .. convertDmxChannelValue8Bit(uichannel.logical_channel[1]["red"].dmxto));
	debug_logmetatable(uichannel.logical_channel[1]);
	
	if true then
		local myPools = getGma3Pools();
		local myFixtureType = myPools.Fixturetype;
		log("Found " .. type(myFixtureType) );
		log("myFixtureType");
		debug_logmetatable(myFixtureType);
		log("myFixtureType.name=" .. myFixtureType.name);
		log("Found " .. myFixtureType:Count() .. " fixtures");
		local myTest = myFixtureType:Ptr(2);
		log("Name=" .. myTest.Name);
		log("shortname=" .. myTest.shortname);
		debug_logmetatable(myTest);
		local wheels = myTest.Wheels;	
		for key, wheel in pairs(wheels:Children()) do
				log("Name=" .. wheel.Name);
				debug_logmetatable(wheel);
				for index,slot in ipairs(wheel) do
					log("Index=" .. index .. " Name=" .. slot.Name .. " MediaFileName=" .. slot.MediaFileName);
					if ( slot.Color ~= nil ) then
						log("Color=" .. slot.Color);
					end
					if ( slot.SubAttrib ~= nil ) then
						log("Color=" .. slot.SubAttrib);
					end
					-- local path = slot.MediaFileName;
					-- if(path ~= "") then
						-- local found = filenames[path];
						-- assert(found,"Image " .. path .. " not found");
					-- end
				end
		end			
	end
end

-- *************************************************************
-- groupGetColMixType
-- *************************************************************

local function groupGetColMixType(inGroupNo)
	local myResult = nil;
	C("Clear" );
	C("SelFix Group " .. inGroupNo );
	local myFixtureIndex = SelectionFirst(true);
	log("[groupGetColMixType] myFixtureIndex=" .. myFixtureIndex);
	local mySubFixture = GetSubfixture(myFixtureIndex);
	log("[groupGetColMixType] mySubFixture=" .. type(mySubFixture));
	debug_logmetatable(mySubFixture);
	log("[groupGetColMixType] mySubFixture.name=" .. mySubFixture.name);
	if ( myFixtureIndex ~= nil ) then
		local myRgbRUiChannelIdx = getUiChannelIdxForAttributeName(myFixtureIndex,"ColorRGB_R");
		local myRgbCUiChannelIdx = getUiChannelIdxForAttributeName(myFixtureIndex,"ColorRGB_C");
		local myColor1UiChannelIdx = getUiChannelIdxForAttributeName(myFixtureIndex,"Color1");
		if ( myRgbCUiChannelIdx == nil ) and ( myRgbRUiChannelIdx == nil) then
			if ( myColor1UiChannelIdx == nil ) then
				-- This fixture does not seem to have any color attribute at all
				log("Warning: group " .. inGroupNo .. " does not have any color attributes.");
				myResult = cColMixTypeNone;
			else
				myResult = cColMixTypeWheelFixed;
				--dummy_test(myColor1UiChannelIdx);
			end
		else
			myResult = cColMixTypeRGBCMY;
		end
	end
	return myResult;
end

-- *************************************************************
-- RegisterGridItem
-- *************************************************************

local function RegisterGridItem(inRow,inCol,inX,inY,inWidth,inHeight,inType,inTypeExecNo,inVisibleName)
	log("[RegisterGridItem] Registering grid item. Row=" .. inRow .. " Col=" .. inCol .. " X=" .. tostring(inX) .. " Y=" .. tostring(inY) .. " Width=" .. tostring(inWidth) .. " Height=" .. tostring(inHeight) .. " Type=" .. inType .. " inTypeExecNo=" .. inTypeExecNo .. " VisibleName=" .. tostring(inVisibleName));
	myGridItem = {
		mRow = inRow,
		mCol = inCol,
		mX = inX,
		mY = inY,
		mWidth = inWidth,
		mHeight = inHeight,
		mType = inType,
		mTypeExecNo = inTypeExecNo,
		mVisibleName = inVisibleName,
	}
	table.insert(gParams.mColorGrid.mGrid,myGridItem);
end

-- *************************************************************
-- RegisterGroupItem
-- *************************************************************

local function RegisterGroupItem(inGroup)
	local myColMixType = groupGetColMixType(inGroup.no);
	local myFixtureName = groupGetFixtureShortName(inGroup.no);
	local myFixtureType = getFixtureTypeByName(myFixtureName);
	local myFixtureTypeName = "unknown";
	if ( myFixtureType ~= nil ) then
		myFixtureTypeName = myFixtureType.name;
	end
	log("[RegisterGroupItem] Registering group item no " .. inGroup.no .. "(" .. inGroup.name .. ")" .. " ColMixType=" .. myColMixType .. " FixtureShortName=" .. myFixtureName .. " FixtureName=" .. myFixtureTypeName);
	myGroupItem = {
		mNo = inGroup.no,
		mName = inGroup.name,
		mInclude = false,
		mColMixType = myColMixType,
		mFixtureName = myFixtureName,
		mFixtureType = myFixtureType,
	}
	table.insert(gParams.mGroup.mGroups,myGroupItem);
end

-- *************************************************************
-- initGroupRegister
-- *************************************************************

local function initGroupRegister()
	local myPools = getGma3Pools();
	local myGroups = myPools.Group;
	-- Since i have no sense on how to find out how many groups are actually present we 
	-- will check up to mMaxCheckNo groups. That should be sufficient for most applications.
	for myGroupNo=1,gParams.mGroup.mMaxCheckNo,1 do	
		local myGroup = myGroups:Ptr(myGroupNo);
		if myGroup ~= nil then
			RegisterGroupItem(myGroup);	
		end
	end		
end

-- *************************************************************
-- getColorCapableGroupNoAsCsvString
-- *************************************************************

local function getColorCapableGroupNoAsCsvString()
	local myResult = ""
	for myGKey,myGValue in pairs(gParams.mGroup.mGroups) do
		local myColMixType = myGValue.mColMixType;
		if ( myColMixType ~= cColMixTypeNone ) then
			myNo = myGValue.mNo;
			if next(gParams.mGroup.mGroups,myGKey) ~= nil then
				myResult = myResult .. myNo .. ",";
			else
				myResult = myResult .. myNo;
			end
		end
	end
	return myResult;
end

-- *************************************************************
-- getNonColorCapableGroupNoAsCsvString
-- *************************************************************

local function getNonColorCapableGroupNoAsCsvString()
	local myResult = ""
	for myGKey,myGValue in pairs(gParams.mGroup.mGroups) do
		local myColMixType = myGValue.mColMixType;
		if ( myColMixType == cColMixTypeNone ) then
			myNo = myGValue.mNo;
			if next(gParams.mGroup.mGroups,myGKey) ~= nil then
				myResult = myResult .. myNo .. ",";
			else
				myResult = myResult .. myNo;
			end
		end
	end
	return myResult;
end

-- *************************************************************
-- getAllGroupNoAsCsvString
-- *************************************************************

local function getAllGroupNoAsCsvString()
	local myResult = ""
	for myGKey,myGValue in pairs(gParams.mGroup.mGroups) do
		myNo = myGValue.mNo;
		if next(gParams.mGroup.mGroups,myGKey) ~= nil then
			myResult = myResult .. myNo .. ",";
		else
			myResult = myResult .. myNo;
		end
	end
	return myResult;
end

-- *************************************************************
-- getAllGroupHandlingState
-- *************************************************************

local function setGroupHandlingState(inNo,inState)
	local myResult = false;
	log("[setGroupHandlingState] Setting group " .. inNo .. " to include state " .. tostring(inState));
	for myGKey,myGValue in pairs(gParams.mGroup.mGroups) do
		if ( myGValue.mNo == inNo ) then
			myGValue.mInclude = inState;
			gParams.mGroup.mCurrentGroupNo = gParams.mGroup.mCurrentGroupNo + 1;
			myResult = true;
		end
	end
	return myResult;
end

-- *************************************************************
-- setGroupsForColorGridFromCsv
-- *************************************************************

local function setGroupsForColorGridFromCsv(inCsv)
	local myResult = false;
	local myPos = 1
	while true do 
		local myChar = string.sub(inCsv,myPos,myPos)
		if (myChar == "") then 
			break 
		end
		
		local myStart,myEnd = string.find(inCsv,',',myPos)
		if (myStart) then 
			myNo = tonumber(string.sub(inCsv,myPos,myStart-1));
			myResult = setGroupHandlingState(myNo,true);
			myPos = myEnd + 1
		else
			myNo = tonumber(string.sub(inCsv,myPos));
			myResult = setGroupHandlingState(myNo,true);
			myResult = true;
			break
		end 
	end
	return myResult;
end

-- *************************************************************
-- ColorPresetCreate
-- *************************************************************

local function ColorPresetCreate(inNo,inGroupNo,inName,inGroupName,inColMixType)
	local myResult = true; -- Assume we ill make it
	local myPresetNo = getPresetNo(inNo,inGroupNo);
	log("[ColorPresetCreate] Creating preset no " .. myPresetNo .. " for group " .. inGroupName .. " ColMixType=" .. inColMixType);
	if ( inColMixType == cColMixTypeWheelFixed ) then
		-- We will try to set the dmx values to the wheel as defined in the wheel definition. 
		-- This is fuzzy and may not work with all fixtures since it depends a lot on how their listing is.
		local myDmxValue = getGroupColorWheelDmxValueForSlotName(inGroupNo,inGroupName,inColMixType,inName)
		if ( myDmxValue ~= nil ) then
			C("Attribute \"Color1\" at absolute decimal8 " .. myDmxValue);
		else
			myResult = false;
		end
	else
		-- In here we handle the cmy and rgb colors
		C("At Gel \"Ma\".\"" .. inName .. "\"" );
	end
	C("Store Preset 'Color'." .. myPresetNo .. " /Selective /o" );
	C("Label Preset 'Color'." .. myPresetNo .. " \"" .. inGroupName.. "(" .. inName .. ")\"" );
	return myResult;
end

-- *************************************************************
-- AppearanceCreate
-- *************************************************************

local function AppearanceCreate(inNo,inGroupNo,inColor)
	local myAppearanceNo = getAppearanceNo(inNo,inGroupNo);
	log("[AppearanceCreate] Creating appearance no " .. myAppearanceNo .." with color \"" .. inColor .. "\"" );
	C("del appearance " .. myAppearanceNo .. "/NC");
	C("store appearance " .. myAppearanceNo);
	C("Set Appearance " .. myAppearanceNo .. " \"Appearance\" \"ShowData.ImagePools.Custom." .. myAppearanceNo .. "\"" );
	C("Set Appearance " .. myAppearanceNo .. " Property \"COLOR\" \"" .. inColor .. "\"" );
	C("Set Appearance " .. myAppearanceNo .. " Property \"ImageMode\" \"Stretch\"" );
end

-- *************************************************************
-- SequenceCreate
-- *************************************************************

local function SequenceCreate(inNo,inGroupNo,inName,inGroupName)
	local mySeqNo = getSeqNo(inNo,inGroupNo);
	local myPresetNo = getPresetNo(inNo,inGroupNo);
	log("[SequenceCreate] Creating sequence no " .. mySeqNo .. " for group " .. inGroupName);
	-- Since we have no conditional operators in shell we will use this trick to make sure our sequence wont be triggered again after being fired.
	mySeqCmd = "SetUserVar " .. gParams.mVar.mColorValStateNamePrefix .. inGroupNo .. " '" .. gParams.mVar.mSeqInvalidOffsetNameValActive;
	C("At Preset 'Color'." .. myPresetNo);
	C("Delete seq " .. mySeqNo .. "/NC");
	C("Store seq " .. mySeqNo);

	-- Add cmds to handle the images according to the sequence status
	C("set sequence " .. mySeqNo .. " cue 1 Property \"Cmd\" \"" .. mySeqCmd .. "\"" )

	C("Label Sequence " .. mySeqNo .. " \"" .. inGroupName .. "(" .. inName .. ")\"" )
end

-- *************************************************************
-- MacroCreate
-- *************************************************************

local function MacroCreate(inNo,inGroupNo,inName,inGroupName)
	local myMacroNo = getMacroNo(inNo,inGroupNo); 
	local mySeqNo = getSeqNo(inNo,inGroupNo);
	local myAppearanceNo = getAppearanceNo(inNo,inGroupNo);
	local myExecNo = getExecNo(inNo,inGroupNo);
	local myActiveStorageNo = gParams.mImage.mGridItemActiveNo;
	local myInactiveStorageNo = gParams.mImage.mGridItemInactiveNo;
	myInactivateText = ""
	log("[MacroCreate] Creating macro no " .. myMacroNo);

	C("Delete Macro " .. myMacroNo .. "/NC");
	C("Store macro " .. myMacroNo);
	C("set macro " .. myMacroNo .. " property \"appearance\" " ..  myAppearanceNo);

	-- Store our current state in a console user variable
	gParams.mVar.mColorValStateMaxNo = inGroupNo;
	C("store macro " .. myMacroNo .. " \"SetUserVar(" .. gParams.mVar.mColorValStateNamePrefix .. gParams.mVar.mColorValStateMaxNo ..	")\" Command \"SetUserVar " .. gParams.mVar.mColorValStateNamePrefix .. gParams.mVar.mColorValStateMaxNo .. " '" .. mySeqNo .. "'\"");

	C("store macro " .. myMacroNo .. " \"GoSeq" .. mySeqNo .. "\" Command \"go+ seq $" .. gParams.mVar.mSeqInvalidOffsetName .. "$" .. gParams.mVar.mColorValStateNamePrefix .. gParams.mVar.mColorValStateMaxNo .. "\"");
	for myPos=1,gParams.mMaxGelNo,1 do
		local myImagePos = gParams.mImage.mBaseExecNo + myPos + getGroupOffset(inGroupNo);
		local myGroupPos = myPos + getGroupOffset(inGroupNo);
		if myExecNo ~= myImagePos then
			myInactivateText = myInactivateText .. " image 'Custom'." .. (gParams.mImage.mBaseExecNo + myGroupPos);
		else
			C("store macro " .. myMacroNo .. " \"ActivateImage" .. myImagePos .. "\" Command \"copy image 'Custom'." .. gParams.mImage.mGridItemActiveNo .. " at image 'Custom'." .. (gParams.mImage.mBaseExecNo + myGroupPos) .. "\"");
		end
	end
	C("store macro " .. myMacroNo .. " \"InactivateImage \" Command \"copy image 'Custom'." .. gParams.mImage.mGridItemInactiveNo .. " at " .. myInactivateText .. "\"");

	-- Add cmds to handle the images according to the sequence status
	C("Label macro " .. myMacroNo .. " \"" .. inGroupName .. "(" .. inName .. ")\"" )
	RegisterGridItem(gParams.mColorGrid.mCurrentRowNo,inNo,nil,nil,nil,nil,cGridTypeMacro,myMacroNo,gParams.mLayout.mVisibilityObjectName);
end

-- *************************************************************
-- MacroDelayCreate
-- *************************************************************

local function MacroDelayCreate(inNo,inGroupNo,inName,inGroupName)
	local myExecNo = getExecNo(inNo,inGroupNo);
	local myMacroNo = getMacroNo(inNo,inGroupNo); 
	local myAppearanceNo = getAppearanceNo(inNo,inGroupNo);
	local myPresetStart = getPresetNo(1,inGroupNo);
	local myPresetEnd = myPresetStart + getGroupOffset(1) - 1;
	local myDelayString = "0"
	local myFadeString = "$" .. gParams.mVar.mFadetimeName;
	local myActiveStorageNo = gParams.mImage.mDelayOffActiveNo;
	local myInactiveStorageNo = gParams.mImage.mDelayOffInactiveNo;
	local myCmdString = ""
	if inName == ">" then
		myDelayString = "0 thru $" .. gParams.mVar.mDelaytimeName
		myActiveStorageNo = gParams.mImage.mDelayRightActiveNo;
		myInactiveStorageNo = gParams.mImage.mDelayRightInactiveNo;
	elseif inName == "<" then
		myDelayString = "$" .. gParams.mVar.mDelaytimeName ..  " thru 0"
		myActiveStorageNo = gParams.mImage.mDelayLeftActiveNo;
		myInactiveStorageNo = gParams.mImage.mDelayLeftInactiveNo;
	elseif inName == "<>" then
		myDelayString = "$" .. gParams.mVar.mDelaytimeName ..  " thru 0 thru " .. "$" .. gParams.mVar.mDelaytimeName
		myActiveStorageNo = gParams.mImage.mDelayInOutActiveNo;
		myInactiveStorageNo = gParams.mImage.mDelayInOutInactiveNo;
	elseif inName == "><" then
		myDelayString = "0 thru $" .. gParams.mVar.mDelaytimeName ..  " thru 0"
		myActiveStorageNo = gParams.mImage.mDelayOutInActiveNo;
		myInactiveStorageNo = gParams.mImage.mDelayOutInInactiveNo;
	else
		myDelayString = "0"
		myActiveStorageNo = gParams.mImage.mDelayOffActiveNo;
		myInactiveStorageNo = gParams.mImage.mDelayOffInactiveNo;
	end
	log("[MacroDelayCreate] Creating " .. inName .. " delay macro no " .. myMacroNo);

	-- Set default image at execute location
	ImageCopy(myActiveStorageNo,myExecNo);

	-- Prepare appearance
	AppearanceCreate(inNo,inGroupNo,"white");

	C("Delete Macro " .. myMacroNo .. "/NC");
	C("Store macro " .. myMacroNo);
	C("set macro " .. myMacroNo .. " property \"appearance\" " ..  myAppearanceNo);

	-- Store our current state in a console user variable
	gParams.mVar.mDelayDirStateMaxNo = inGroupNo;
	C("store macro " .. myMacroNo .. " \"SetUserVar(" .. gParams.mVar.mDelayDirStateNamePrefix .. gParams.mVar.mDelayDirStateMaxNo .. ")\" Command \"SetUserVar " .. gParams.mVar.mDelayDirStateNamePrefix .. gParams.mVar.mDelayDirStateMaxNo .. " '" .. myMacroNo .. "'\"");

	C("store macro " .. myMacroNo .. " \"ColorDelay(" .. inGroupName .. ")\" Command \"Group '" .. inGroupName .. "'\"");
	myCmdString = "Attribute 'ColorRGB_R' at delay " .. myDelayString .. " at fade " .. myFadeString
	myCmdString = myCmdString .. "; Attribute 'ColorRGB_G' at delay " .. myDelayString .. " at fade " .. myFadeString
	myCmdString = myCmdString .. "; Attribute 'ColorRGB_B' at delay " .. myDelayString .. " at fade " .. myFadeString
	myCmdString = myCmdString .. "; Attribute 'ColorRGB_C' at delay " .. myDelayString .. " at fade " .. myFadeString
	myCmdString = myCmdString .. "; Attribute 'ColorRGB_RY' at delay " .. myDelayString .. " at fade " .. myFadeString
	myCmdString = myCmdString .. "; Attribute 'ColorRGB_W' at delay " .. myDelayString .. " at fade " .. myFadeString
	myCmdString = myCmdString .. "; Attribute 'ColorRGB_G' at delay " .. myDelayString .. " at fade " .. myFadeString
	myCmdString = myCmdString .. "; Attribute 'ColorRGB_UV' at delay " .. myDelayString .. " at fade " .. myFadeString
	myCmdString = myCmdString .. "; Attribute 'ColorRGB_GY' at delay " .. myDelayString .. " at fade " .. myFadeString
	
	C("store macro " .. myMacroNo .. " \"ColorDelay(" .. inGroupName .. ")\" Command \"" .. myCmdString ..  "\"");
	-- Unfortunately the behaviour of the different approaches of removing the absolute values changes unpredictably from grandMA3 Release Version to Version.
	-- So this has to be adjusted on every release until they find a convenient solution for this.
	-- C("store macro " .. myMacroNo .. " \"ColorDelay(" .. inGroupName .. ")\" Command \"off absolute\""); -- This has been working until version 1.4.0.2, after that it knocks out the delay and fade values as well...However, the syntax of the command could be intended to do it this way :)
	C("store macro " .. myMacroNo .. " \"ColorDelay(" .. inGroupName .. ")\" Command \"off FeatureGroup 'Color'.'RGB' Absolute\""); -- This seems to work with version 1.4.0.2 and newer, it knocks out the absolute values and keeps the fade and delay values by not touching the other programmer values.
	C("store macro " .. myMacroNo .. " \"ColorDelay(" .. inGroupName .. ")\" Command \"store preset 4." .. myPresetStart .. " thru " .. myPresetEnd .. " /selective /m\"");

	for myPos=1,gParams.mMaxDelayMacroNo,1 do
		local myImagePos = gParams.mImage.mBaseExecNo + myPos + getGroupOffset(inGroupNo) + gParams.mMaxGelNo;
		local myTargetInactiveStorageNo = gParams.mImage.mDelayLeftInactiveNo + myPos - 1;
		local myTargetActiveStorageNo =gParams.mImage.mDelayLeftActiveNo + myPos - 1;
		if myExecNo ~= myImagePos then
			C("store macro " .. myMacroNo .. " \"InactivateImage" .. myImagePos .. "\" Command \"copy image 'Custom'." .. myTargetInactiveStorageNo .. " at image 'Custom'." .. myImagePos .."\"");
		else
			C("store macro " .. myMacroNo .. " \"ActivateImage" .. myImagePos .. "\" Command \"copy image 'Custom'." .. myTargetActiveStorageNo .. " at image 'Custom'." .. myImagePos .. "\"");
		end
	end

	--C("store macro " .. myMacroNo .. " \"Wait\" Command \"cd\"  Property \"wait\" " .. gParams.mMacro.mWaitTime);
	--C("store macro " .. myMacroNo .. " \"GoSeq" .. gParams.mVar.mColorValStateNamePrefix .. inGroupNo .. "\" Command \"go+ seq $" .. gParams.mVar.mColorValStateNamePrefix .. inGroupNo .. "\"");

	-- Add cmds to handle the images according to the sequence status
	C("Label macro " .. myMacroNo .. " \"" .. inGroupName .. "(" .. inName .. ")\"" )
	RegisterGridItem(gParams.mColorGrid.mCurrentRowNo,inNo,nil,nil,nil,nil,cGridTypeMacro,myMacroNo,gParams.mLayout.mVisibilityObjectName);
end

-- *************************************************************
-- MacroDelayCreateAll
-- *************************************************************

local function MacroDelayCreateAll(inNo,inName,inMaxGroups)
	local myExecNo = getExecNo(inNo,0);
	local myMacroNo = getMacroNo(inNo,0); 
	local myAppearanceNo = getAppearanceNo(inNo,0);
	local myActiveStorageNo = gParams.mImage.mDelayOffActiveNo;
	local myInactiveStorageNo = gParams.mImage.mDelayOffInactiveNo;
	if inName == ">" then
		myActiveStorageNo = gParams.mImage.mDelayRightActiveNo;
		myInactiveStorageNo = gParams.mImage.mDelayRightInactiveNo;
	elseif inName == "<" then
		myActiveStorageNo = gParams.mImage.mDelayLeftActiveNo;
		myInactiveStorageNo = gParams.mImage.mDelayLeftInactiveNo;
	elseif inName == "<>" then
		myActiveStorageNo = gParams.mImage.mDelayInOutActiveNo;
		myInactiveStorageNo = gParams.mImage.mDelayInOutInactiveNo;
	elseif inName == "><" then
		myActiveStorageNo = gParams.mImage.mDelayOutInActiveNo;
		myInactiveStorageNo = gParams.mImage.mDelayOutInInactiveNo;
	else
		myActiveStorageNo = gParams.mImage.mDelayOffActiveNo;
		myInactiveStorageNo = gParams.mImage.mDelayOffInactiveNo;
		gParams.mMacro.mDelayOffMacroNo = myMacroNo;
	end
	log("[MacroDelayCreateAll] Creating " .. inName .. " delay macro no " .. myMacroNo);

	-- Set default image at execute location
	ImageCopy(myActiveStorageNo,myExecNo);

	-- Prepare appearance
	AppearanceCreate(inNo,0,gMaGels[1].mColor);

	C("Delete Macro " .. myMacroNo .. "/NC");
	C("Store macro " .. myMacroNo);
	C("set macro " .. myMacroNo .. " property \"appearance\" " ..  myAppearanceNo);

	-- Activate all macros that are bound to this delay on all groups
	for myKey,myGroup in pairs(gParams.mGroup.mGroups) do
		if ( myGroup.mInclude == true and myGroup.mColMixType == cColMixTypeRGBCMY) then
			local myGroupNo = myGroup.mNo;
			local myExecMacroNo = getMacroNo(inNo,myGroupNo); 
			C("store macro " .. myMacroNo .. " \"GoMacro" .. myExecMacroNo .. "\" Command \"go+ macro " .. myExecMacroNo .. "\" Property \"wait\" " .. gParams.mMacro.mDelayWaitTime);
		end
	end

	C("Label macro " .. myMacroNo .. " \"" .. inName .. "\"" )
	RegisterGridItem(0,inNo,nil,nil,nil,nil,cGridTypeMacro,myMacroNo,gParams.mLayout.mVisibilityObjectName);
end


-- *************************************************************
-- MacroColorExecModeCreate
-- *************************************************************

local function MacroColorExecModeCreate(inNo,inName,inGroupNo)
	local myExecNo = getExecNo(inNo,inGroupNo);
	local myMacroNo = getMacroNo(inNo,inGroupNo); 
	local myAppearanceNo = getAppearanceNo(inNo,inGroupNo);
	local myActiveStorageNo = gParams.mImage.mGridItemActiveNo;
	local myInactiveStorageNo = gParams.mImage.mGridItemInactiveNo;

	log("[MacroColorExecModeCreate] Creating " .. inName .. " color exec mode macro no " .. myMacroNo);

	-- Set default image at execute location
	ImageCopy(myInactiveStorageNo,myExecNo);

	-- Prepare appearance
	AppearanceCreate(inNo,inGroupNo,gMaGels[1].mColor);

	C("Delete Macro " .. myMacroNo .. "/NC");
	C("Store macro " .. myMacroNo);
	C("set macro " .. myMacroNo .. " property \"appearance\" " ..  myAppearanceNo);

	C("store macro " .. myMacroNo .. " \"SetUserVar(" .. gParams.mVar.mSeqInvalidOffsetName .. ")\" Command \"SetUserVar " ..  gParams.mVar.mSeqInvalidOffsetName .. " '" .. gParams.mVar.mSeqInvalidOffsetNameValInactive .. "'; copy image 'Custom'." .. myInactiveStorageNo .. " at image 'Custom'." .. myExecNo .. "; Label macro " .. myMacroNo .. " 'direct'\" Property 'wait' 'Go'");
	C("store macro " .. myMacroNo .. " \"SetUserVar(" .. gParams.mVar.mSeqInvalidOffsetName .. ")\" Command \"SetUserVar " ..  gParams.mVar.mSeqInvalidOffsetName .. " '" .. gParams.mVar.mSeqInvalidOffsetNameValActive   .. "'; copy image 'Custom'." .. myActiveStorageNo .. " at image 'Custom'." .. myExecNo .. "; Label macro " .. myMacroNo .. " 'manual'\"\" Property 'wait' 'Go'");

	C("Label macro " .. myMacroNo .. " \"direct\"" )
	gParams.mMacro.mColorExecModeMacroNo = myMacroNo;
	RegisterGridItem(gParams.mColorGrid.mCurrentRowNo,inNo,nil,nil,nil,nil,cGridTypeMacro,myMacroNo,nil);
end

-- *************************************************************
-- MacroUpdateColor
-- *************************************************************

local function MacroUpdateColor(inMacroNo)
	for myKey,myGroup in pairs(gParams.mGroup.mGroups) do
		if ( myGroup.mInclude == true ) then
			local myGroupNo = myGroup.mNo;
			C("store macro " .. inMacroNo .. " \"GoMacro" .. gParams.mVar.mColorValStateNamePrefix .. myGroupNo .. "\" Command \"go+ macro $" .. gParams.mVar.mColorValStateNamePrefix .. myGroupNo .. "\" Property \"wait\" " .. gParams.mMacro.mWaitTime );
		end
	end
end

-- *************************************************************
-- MacroGoSeqColor
-- *************************************************************

local function MacroGoSeqColor(inMacroNo)
	for myKey,myGroup in pairs(gParams.mGroup.mGroups) do
		if ( myGroup.mInclude == true ) then
			local myGroupNo = myGroup.mNo;
			C("store macro " .. inMacroNo .. " \"GoSeq" .. gParams.mVar.mColorValStateNamePrefix .. myGroupNo .. "\" Command \"go+ seq $" .. gParams.mVar.mColorValStateNamePrefix .. myGroupNo .. "\"");
--			C("store macro " .. inMacroNo .. " \"GoSeq" .. gParams.mVar.mColorValStateNamePrefix .. myGroupNo .. "\" Command \"	Lua \"local myVars=UserVars(); local myNextSeq=GetVar(myVars, '" .. gParams.mVar.mColorValStateNamePrefix .. myGroupNo .. "');  local myLastSeq=GetVar(myVars, '" .. gParams.mVar.mColorValStateNameLastPrefix .. myGroupNo .. "'); if ( myNextSeq ~= '0' and myNextSeq ~= myLastSeq ) then Cmd('go+ seq " .. gParams.mVar.mColorValStateNamePrefix .. myGroupNo .. "'); end; return true;\"\"");
		end
	end
end

-- *************************************************************
-- MacroColorExecModeTriggerCreate
-- *************************************************************

local function MacroColorExecModeTriggerCreate(inNo,inName,inGroupNo)
	local myExecNo = getExecNo(inNo,inGroupNo);
	local myMacroNo = getMacroNo(inNo,inGroupNo); 
	local myAppearanceNo = getAppearanceNo(inNo,inGroupNo);
	local myActiveStorageNo = gParams.mImage.mGridItemActiveNo;
	local myInactiveStorageNo = gParams.mImage.mGridItemInactiveNo;

	log("[MacroColorExecModeCreate] Creating " .. inName .. " color exec mode trigger macro no " .. myMacroNo);

	-- Set default image at execute location
	ImageCopy(myInactiveStorageNo,myExecNo);

	-- Prepare appearance
	AppearanceCreate(inNo,inGroupNo,gMaGels[1].mColor);

	C("Delete Macro " .. myMacroNo .. "/NC");
	C("Store macro " .. myMacroNo);
	C("set macro " .. myMacroNo .. " property \"appearance\" " ..  myAppearanceNo);

	C("store macro " .. myMacroNo .. " \"SetUserVar(" .. gParams.mVar.mSeqInvalidOffsetName .. ")\" Command \"SetUserVar " ..  gParams.mVar.mSeqInvalidOffsetName .. " '" .. gParams.mVar.mSeqInvalidOffsetNameValInactive .. "'\"");

	C("store macro " .. myMacroNo .. " \"ActivateImage" .. myActiveStorageNo .. "\" Command \"copy image 'Custom'." .. myActiveStorageNo .. " at image 'Custom'." .. myExecNo .. "\"");
	-- We need to update the delay direction macros in order to make this active for the next color change
	MacroGoSeqColor(myMacroNo);

	C("store macro " .. myMacroNo .. " \"SetUserVar(" .. gParams.mVar.mSeqInvalidOffsetName .. ")\" Command \"SetUserVar " ..  gParams.mVar.mSeqInvalidOffsetName .. " '" .. gParams.mVar.mSeqInvalidOffsetNameValActive .. "'\"");
	C("store macro " .. myMacroNo .. " \"InactivateImage" .. myInactiveStorageNo .. "\" Command \"copy image 'Custom'." .. myInactiveStorageNo .. " at image 'Custom'." .. myExecNo .. "\"");

	C("Label macro " .. myMacroNo .. " \"" .. inName .. "\"" )
	RegisterGridItem(gParams.mColorGrid.mCurrentRowNo,inNo,100,nil,200,nil,cGridTypeMacro,myMacroNo,nil);

end

-- *************************************************************
-- MacroUpdateDelayDir
-- *************************************************************

local function MacroUpdateDelayDir(inMacroNo)
	for myGroupNo=1,gParams.mVar.mDelayDirStateMaxNo do
		if ( gParams.mGroup.mGroups[myGroupNo].mColMixType == cColMixTypeRGBCMY ) then
			C("store macro " .. inMacroNo .. " \"GoMacro" .. gParams.mVar.mDelayDirStateNamePrefix .. myGroupNo .. "\" Command \"go+ macro $" .. gParams.mVar.mDelayDirStateNamePrefix .. myGroupNo .. "\" Property \"wait\" " .. gParams.mMacro.mDelayWaitTime );
		end
	end
end

-- *************************************************************
-- MacroFadeTimeCreate
-- *************************************************************

local function MacroFadeTimeCreate(inNo,inName,inGroupNo)
	local myExecNo = getExecNo(inNo,inGroupNo);
	local myMacroNo = getMacroNo(inNo,inGroupNo); 
	local myAppearanceNo = getAppearanceNo(inNo,inGroupNo);
	local myActiveStorageNo = gParams.mImage.mGridItemActiveNo;
	local myInactiveStorageNo = gParams.mImage.mGridItemInactiveNo;

	log("[MacroFadeTimeCreate] Creating " .. inName .. " fade macro no " .. myMacroNo);

	-- Set default image at execute location
	ImageCopy(myActiveStorageNo,myExecNo);

	-- Prepare appearance
	AppearanceCreate(inNo,inGroupNo,gMaGels[1].mColor);

	C("Delete Macro " .. myMacroNo .. "/NC");
	C("Store macro " .. myMacroNo);
	C("set macro " .. myMacroNo .. " property \"appearance\" " ..  myAppearanceNo);

	C("store macro " .. myMacroNo .. " \"SetUserVar(" .. gParams.mVar.mFadetimeName .. ")\" Command \"SetUserVar " ..  gParams.mVar.mFadetimeName .. " '" .. inName .. "'\"");

	for myPos=1,gParams.mMaxDelayTimeNo,1 do
		local myImagePos = gParams.mImage.mBaseExecNo + myPos + getGroupOffset(inGroupNo);
		local myGroupPos = myPos + getGroupOffset(inGroupNo);
		if myExecNo ~= myImagePos then
			C("store macro " .. myMacroNo .. " \"InactivateImage" .. myImagePos .. "\" Command \"copy image 'Custom'." .. myInactiveStorageNo .. " at image 'Custom'." .. (gParams.mImage.mBaseExecNo + myGroupPos) .."\"");
		else
			C("store macro " .. myMacroNo .. " \"ActivateImage" .. myImagePos .. "\" Command \"copy image 'Custom'." .. myActiveStorageNo .. " at image 'Custom'." .. (gParams.mImage.mBaseExecNo + myGroupPos) .. "\"");
		end
	end

	-- We need to update the delay direction macros in order to make this active for the next color change
	MacroUpdateDelayDir(myMacroNo);
	
	-- We will have a short waitstate here in order to not get the sequences triggered when the programmer seems still busy.
	--C("store macro " .. myMacroNo .. " \"Wait\" Command \"cd\"  Property \"wait\" " .. gParams.mMacro.mWaitTime);
	
	-- We need to update the color values as well since for some reason the first change will be mixed with white otherwise.
	-- MacroGoSeqColor(myMacroNo);
	
	if inName == "0" then
		gParams.mMacro.mFadeTimeZeroMacroNo = myMacroNo;
	end
	
	-- Dirty hack due to schedule
	if inName == "0.5s" then
		inName = "1/2s";
	end
	C("Label macro " .. myMacroNo .. " \"" .. inName .. "\"" )
	RegisterGridItem(gParams.mColorGrid.mCurrentRowNo,inNo,nil,nil,nil,nil,cGridTypeMacro,myMacroNo,nil);
end

-- *************************************************************
-- MacroDelaySwapCreate
-- *************************************************************

local function MacroDelaySwapCreate(inNo,inName,inGroupNo)
	local myExecNo = getExecNo(inNo,inGroupNo);
	local myMacroNo = getMacroNo(inNo,inGroupNo); 
	local myAppearanceNo = getAppearanceNo(inNo,inGroupNo);
	local myActiveStorageNo = gParams.mImage.mGridItemActiveNo;
	local myInactiveStorageNo = gParams.mImage.mGridItemInactiveNo;

	log("[MacroDelaySwapCreate] Creating " .. inName .. " delay macro no " .. myMacroNo);

	-- Set default image at execute location
	ImageCopy(myActiveStorageNo,myExecNo);

	-- Prepare appearance
	AppearanceCreate(inNo,inGroupNo,gMaGels[1].mColor);

	C("Delete Macro " .. myMacroNo .. "/NC");
	C("Store macro " .. myMacroNo);
	C("set macro " .. myMacroNo .. " property \"appearance\" " ..  myAppearanceNo);

	-- We will read the swap the delaydirs by with the next group
	C("store macro " .. myMacroNo .. " \"SetUserVar(" .. gParams.mVar.mDelaytimeName .. ")\" Command \"SetUserVar " ..  gParams.mVar.mDelaytimeName .. " '" .. inName .. "'\"");

	for myPos=1,gParams.mMaxDelayTimeNo,1 do
		local myImagePos = gParams.mImage.mBaseExecNo + myPos + getGroupOffset(inGroupNo);
		local myGroupPos = myPos + getGroupOffset(inGroupNo);
		if myExecNo ~= myImagePos then
			C("store macro " .. myMacroNo .. " \"InactivateImage" .. myImagePos .. "\" Command \"copy image 'Custom'." .. myInactiveStorageNo .. " at image 'Custom'." .. (gParams.mImage.mBaseExecNo + myGroupPos) .."\"");
		else
			C("store macro " .. myMacroNo .. " \"ActivateImage" .. myImagePos .. "\" Command \"copy image 'Custom'." .. myActiveStorageNo .. " at image 'Custom'." .. (gParams.mImage.mBaseExecNo + myGroupPos) .. "\"");
		end
	end
	
	-- We need to update the delay direction macros in order to make this active for the next color change
	MacroUpdateDelayDir(myMacroNo);
	
	-- We will have a short waitstate here in order to not get the sequences triggered when the programmer seems still busy.
	--C("store macro " .. myMacroNo .. " \"Wait\" Command \"cd\"  Property \"wait\" " .. gParams.mMacro.mWaitTime);
	
	-- We need to update the color values as well since for some reason the first change will be mixed with white otherwise.
	--MacroGoSeqColor(myMacroNo);
	
	C("Label macro " .. myMacroNo .. " \"" .. inName .. "\"" )

end

-- *************************************************************
-- MacroDelayTimeCreate
-- *************************************************************

local function MacroDelayTimeCreate(inNo,inName,inGroupNo)
	local myExecNo = getExecNo(inNo,inGroupNo);
	local myMacroNo = getMacroNo(inNo,inGroupNo); 
	local myAppearanceNo = getAppearanceNo(inNo,inGroupNo);
	local myActiveStorageNo = gParams.mImage.mGridItemActiveNo;
	local myInactiveStorageNo = gParams.mImage.mGridItemInactiveNo;

	log("[MacroDelayTimeCreate] Creating " .. inName .. " delay macro no " .. myMacroNo);

	-- Set default image at execute location
	ImageCopy(myActiveStorageNo,myExecNo);

	-- Prepare appearance
	AppearanceCreate(inNo,inGroupNo,gMaGels[1].mColor);

	C("Delete Macro " .. myMacroNo .. "/NC");
	C("Store macro " .. myMacroNo);
	C("set macro " .. myMacroNo .. " property \"appearance\" " ..  myAppearanceNo);

	C("store macro " .. myMacroNo .. " \"SetUserVar(" .. gParams.mVar.mDelaytimeName .. ")\" Command \"SetUserVar " ..  gParams.mVar.mDelaytimeName .. " '" .. inName .. "'\"");

	for myPos=1,gParams.mMaxDelayTimeNo,1 do
		local myImagePos = gParams.mImage.mBaseExecNo + myPos + getGroupOffset(inGroupNo);
		local myGroupPos = myPos + getGroupOffset(inGroupNo);
		if myExecNo ~= myImagePos then
			C("store macro " .. myMacroNo .. " \"InactivateImage" .. myImagePos .. "\" Command \"copy image 'Custom'." .. myInactiveStorageNo .. " at image 'Custom'." .. (gParams.mImage.mBaseExecNo + myGroupPos) .."\"");
		else
			C("store macro " .. myMacroNo .. " \"ActivateImage" .. myImagePos .. "\" Command \"copy image 'Custom'." .. myActiveStorageNo .. " at image 'Custom'." .. (gParams.mImage.mBaseExecNo + myGroupPos) .. "\"");
		end
	end
	
	-- We need to update the delay direction macros in order to make this active for the next color change
	MacroUpdateDelayDir(myMacroNo);
	
	if inName == "0" then
		gParams.mMacro.mDelayTimeZeroMacroNo = myMacroNo;
	end
	
	-- Dirty hack due to schedule
	if inName == "0.5s" then
		inName = "1/2s";
	end
	C("Label macro " .. myMacroNo .. " \"" .. inName .. "\"" )
	RegisterGridItem(gParams.mColorGrid.mCurrentRowNo,inNo,nil,nil,nil,nil,cGridTypeMacro,myMacroNo,nil);
end


-- *************************************************************
-- MacroAllCreate
-- *************************************************************

local function MacroAllCreate(inNo,inGroupNo,inName,inMaxGroups)
	local myMacroNo = getMacroNo(inNo,inGroupNo); 
	local myAppearanceNo = getAppearanceNo(inNo,inGroupNo);
	local myExecNo = getExecNo(inNo,inGroupNo);
	local myActiveStorageNo = gParams.mImage.mGridItemActiveNo;
	local myInactiveStorageNo = gParams.mImage.mGridItemInactiveNo;
	log("[MacroAllCreate] Creating macro no " .. myMacroNo);

	if inName == "White" then
		gParams.mMacro.mAllColorWhiteMacroNo = myMacroNo;
	end

	C("Delete Macro " .. myMacroNo .. "/NC");
	C("Store macro " .. myMacroNo);
	C("set macro " .. myMacroNo .. " property \"appearance\" " ..  myAppearanceNo);

	-- Activate all seqs in advance to speed up the color change and afterwards call the colorchange macro
	for myKey,myGroup in pairs(gParams.mGroup.mGroups) do
		if ( myGroup.mInclude == true ) then
			local myGroupNo = myGroup.mNo;
			local myExecSeqNo = getSeqNo(inNo,myGroupNo);
			C("store macro " .. myMacroNo .. " \"SetUserVar(" .. gParams.mVar.mColorValStateNamePrefix .. myGroupNo ..	")\" Command \"SetUserVar " .. gParams.mVar.mColorValStateNamePrefix .. myGroupNo .. " '" .. myExecSeqNo .. "'\"");
		end
	end
	
	for myKey,myGroup in pairs(gParams.mGroup.mGroups) do
		if ( myGroup.mInclude == true ) then
			local myGroupNo = myGroup.mNo;
			local myExecSeqNo = getSeqNo(inNo,myGroupNo);
			C("store macro " .. myMacroNo .. " \"GoSeq" .. myExecSeqNo .. "\" Command \"go+ seq $" .. gParams.mVar.mSeqInvalidOffsetName .. "$" .. gParams.mVar.mColorValStateNamePrefix .. myGroupNo .. "\"");
		end
	end
	
	-- Activate all macros that are bound to this color on all groups
	for myKey,myGroup in pairs(gParams.mGroup.mGroups) do
		if ( myGroup.mInclude == true ) then
			local myGroupNo = myGroup.mNo;
			local myExecMacroNo = getMacroNo(inNo,myGroupNo); 
			C("store macro " .. myMacroNo .. " \"GoMacro" .. myExecMacroNo .. "\" Command \"go+ macro " .. myExecMacroNo .. "\" Property \"wait\" " .. gParams.mMacro.mWaitTime);
		end
	end

	-- Add cmds to handle the images according to the sequence status
	C("Label macro " .. myMacroNo .. " \"" .. inName .. "\"" )
	RegisterGridItem(inGroupNo,inNo,nil,nil,nil,nil,cGridTypeMacro,myMacroNo,gParams.mLayout.mVisibilityObjectName);
end

-- *************************************************************
-- LabelCreate
-- *************************************************************

local function LabelCreate(inGroupNo,inName,inX,inY,inWidth,inHeight)
	local pools = getGma3Pools();
	local myMacroNo = getMacroNo(0,inGroupNo);
	local myAppearanceNo = gParams.mAppearance.mBaseNo + getGroupOffset(inGroupNo);
	if inName ~= nil then
		myGroupName = inName;
	else
		-- In this case we will add the group name as label.
		local groups = pools.Group;
		local group = groups:Ptr(inGroupNo);
		myGroupName = group.name;
	end
	log("[LabelCreate] Creating label macro " .. myMacroNo .. " for group no " .. inGroupNo .. "(" .. myGroupName .. ")");
	-- Set default image at execute location
	C("Delete Image 'Custom'." .. gParams.mImage.mBaseExecNo + getGroupOffset(inGroupNo) .. "/NC");
	-- Prepare appearance
	AppearanceCreate(0,inGroupNo,gMaGels[1].mColor);
	-- Create empty macro as label...Workaround since i have no clue how to do it otherwise
	C("Delete Macro " .. myMacroNo .. "/NC");
	C("Store macro " .. myMacroNo);
	C("Label macro " .. myMacroNo .. " \"" .. myGroupName .. "\"" )
	C("set macro " .. myMacroNo .. " property \"appearance\" " ..  myAppearanceNo);
	RegisterGridItem(gParams.mColorGrid.mCurrentRowNo,0,inX,inY,inWidth,inHeight,cGridTypeMacro,myMacroNo,nil);
	return myMacroNo;
end

-- *************************************************************
-- LabelCreateAll
-- *************************************************************

local function LabelCreateAll(inGroupNo)
	local myMacroNo = getMacroNo(0,inGroupNo);
	local myAppearanceNo = gParams.mAppearance.mBaseNo + getGroupOffset(inGroupNo);
	local myGroupName = "ALL";
	log("[LabelCreateAll] Creating label macro " .. myMacroNo .. " for group no " .. inGroupNo .. "(" .. myGroupName .. ")");
	-- Set default image at execute location
	C("Delete Image 'Custom'." .. gParams.mImage.mBaseExecNo + getGroupOffset(inGroupNo) .. "/NC");
	-- Prepare appearance
	AppearanceCreate(0,inGroupNo,gMaGels[1].mColor);
	-- Create empty macro as label...Workaround since i have no clue how to do it otherwise
	C("Delete Macro " .. myMacroNo .. "/NC");
	C("Store macro " .. myMacroNo);
	C("Label macro " .. myMacroNo .. " \"" .. myGroupName .. "\"" )
	C("set macro " .. myMacroNo .. " property \"appearance\" " ..  myAppearanceNo);
	RegisterGridItem(inGroupNo,0,nil,nil,nil,nil,cGridTypeMacro,myMacroNo,nil);
end

-- *************************************************************
-- LayoutItemSetPositionAndSize
-- *************************************************************
local function LayoutItemSetPositionAndSize(inLayoutNo,inItemNo,inX,inY,inWidth,inHeight,inVisibleName)
	C("Set Layout " .. inLayoutNo .. "." .. inItemNo .. " Property \"PosX\" " ..  inX);
	C("Set Layout " .. inLayoutNo .. "." .. inItemNo .. " Property \"PosY\" " ..  inY);
	C("Set Layout " .. inLayoutNo .. "." .. inItemNo .. " Property \"PositionW\" " ..  inWidth);
	C("Set Layout " .. inLayoutNo .. "." .. inItemNo .. " Property \"PositionH\" " ..  inHeight);
	if inVisibleName ~= nil then
		C("Set Layout " .. inLayoutNo .. "." .. inItemNo .. " Property \"VisibilityObjectName\" " ..  inVisibleName .. " Executor");
	end
end

-- *************************************************************
-- LayoutCreate
-- *************************************************************

local function LayoutCreate()
	local myLayoutNo = gParams.mLayout.mBaseNo;
	myLayoutItemNo = 1;
	log("[LayoutCreate] Creating layout no " .. myLayoutNo);
	-- Create Layout view
	C("delete layout " .. myLayoutNo);
	
	for myGKey,myGValue in pairs(gParams.mColorGrid.mGrid) do
		local myHeight = myGValue.mHeight or gParams.mLayout.mHeight;
		local myWidth = myGValue.mWidth or gParams.mLayout.mWidth;
		local myCol = myGValue.mCol or 0;
		local myRow = myGValue.mRow;
		local myX = myGValue.mX or myWidth * myCol;
		local myY = myGValue.mY or myHeight * myRow * -1;
		local myType = myGValue.mType;
		local myTypeExecNo = myGValue.mTypeExecNo;
		local myVisibleName = myGValue.mVisibleName;
		log("myX=" .. myX .. " myY=" .. myY .. " myHeight=" .. myHeight .. " myWidth=" .. myWidth .. " myType=" .. myType .. " myTypeExecNo=" .. myTypeExecNo .. " myRow=" .. myRow);
		C("Assign " .. myType .. " " .. myTypeExecNo .. " at layout " .. myLayoutNo);
		LayoutItemSetPositionAndSize(myLayoutNo,myLayoutItemNo,myX,myY,myWidth,myHeight,myVisibleName);
		myLayoutItemNo = myLayoutItemNo + 1;
	end
	
	C("Label layout " .. myLayoutNo .. " \"" .. gParams.mLayout.mLayoutName .. "\"" );
end

-- *************************************************************
-- CreateGridEntry
-- *************************************************************

local function CreateGridEntry(inNo,inGroupItem)
	local myGroupNo = inGroupItem.mNo;
	local myGroupName = inGroupItem.mName;
	local myActiveStorageNo = gParams.mImage.mGridItemActiveNo;
	local myExecNo = getExecNo(inNo,myGroupNo);
	local myGelName = gMaGels[inNo].mName;
	local myGelColor = gMaGels[inNo].mColor;
	log("[CreateGridEntry] Creating entry no " .. inNo .. " " .. myGelName .. " for group " .. myGroupNo);

	-- Set default image at execute location
	ImageCopy(myActiveStorageNo,myExecNo);

	-- Prepare appearance
	AppearanceCreate(inNo,myGroupNo,myGelColor);

	-- Create Color Presets
	C("SelFix Group " .. myGroupNo );
	if ( ColorPresetCreate(inNo,myGroupNo,myGelName,myGroupName,inGroupItem.mColMixType) == true ) then
		-- Create sequence from preset
		SequenceCreate(inNo,myGroupNo,myGelName,myGroupName);

		-- Create macros for sequence launch and image replacement
		MacroCreate(inNo,myGroupNo,myGelName,myGroupName);
	end
end

-- *************************************************************
-- CreateGridEntryAll
-- *************************************************************

local function CreateGridEntryAll(inNo,inGroupNo,inMaxGroupNo)
	local myExecNo = getExecNo(inNo,inGroupNo);
	local myActiveStorageNo = gParams.mImage.mGridItemActiveNo;
	local myGelName = gMaGels[inNo].mName;
	local myGelColor = gMaGels[inNo].mColor;
	log("[CreateGridEntryAll] Creating entry no " .. inNo .. " " .. myGelName .. " for group " .. inGroupNo);

	-- Set default image at execute location
	ImageCopy(myActiveStorageNo,myExecNo);

	-- Prepare appearance
	AppearanceCreate(inNo,inGroupNo,myGelColor);

	-- Create macros for multi sequence launch and image replacement
	MacroAllCreate(inNo,inGroupNo,myGelName,inMaxGroupNo);
end

-- *************************************************************
-- CreateDelayMacros
-- *************************************************************

local function CreateDelayMacros(inNo,inGroupNo,inGroupName)
	myNo = inNo + 1;
	MacroDelayCreate(myNo,inGroupNo,"<",inGroupName);
	myNo = myNo + 1;
	MacroDelayCreate(myNo,inGroupNo,">",inGroupName);
	myNo = myNo + 1;
	MacroDelayCreate(myNo,inGroupNo,"<>",inGroupName);
	myNo = myNo + 1;
	MacroDelayCreate(myNo,inGroupNo,"><",inGroupName);
	myNo = myNo + 1;
	MacroDelayCreate(myNo,inGroupNo,"off",inGroupName);
	myNo = myNo + 1;
end

-- *************************************************************
-- CreateAllGroup
-- *************************************************************

local function CreateAllGroup(inMaxGroupNo)
	log("[CreateAllGroup] Installing group (ALL)");
	local myEntryNoBackup = 0;
	-- Install entries for all colors in our gel
	for myEntryNo=1,gParams.mMaxGelNo do
		CreateGridEntryAll(myEntryNo,0,inMaxGroupNo);
		myEntryNoBackup = myEntryNo;
	end
	myEntryNoBackup = myEntryNoBackup + 1;
	MacroDelayCreateAll(myEntryNoBackup,"<",inMaxGroupNo);
	myEntryNoBackup = myEntryNoBackup + 1;
	MacroDelayCreateAll(myEntryNoBackup,">",inMaxGroupNo);
	myEntryNoBackup = myEntryNoBackup + 1;
	MacroDelayCreateAll(myEntryNoBackup,"<>",inMaxGroupNo);
	myEntryNoBackup = myEntryNoBackup + 1;
	MacroDelayCreateAll(myEntryNoBackup,"><",inMaxGroupNo);
	myEntryNoBackup = myEntryNoBackup + 1;
	MacroDelayCreateAll(myEntryNoBackup,"off",inMaxGroupNo);
	myEntryNoBackup = myEntryNoBackup + 1;
	-- Create Label for layout view
	LabelCreateAll(0);
end

-- *************************************************************
-- CreateFadeGroup
-- *************************************************************

local function CreateFadeGroup(inGroupNo)
	log("[CreateFadeGroup] Installing group (Fade)");
	local myNo = 0;
	-- Install fade group macros
	myNo = myNo + 1;
	MacroFadeTimeCreate(myNo,"0",inGroupNo);
	myNo = myNo + 1;
	MacroFadeTimeCreate(myNo,"0.5s",inGroupNo);
	myNo = myNo + 1;
	MacroFadeTimeCreate(myNo,"1s",inGroupNo);
	myNo = myNo + 1;
	MacroFadeTimeCreate(myNo,"2s",inGroupNo);
	myNo = myNo + 1;
	MacroFadeTimeCreate(myNo,"5s",inGroupNo);
	myNo = myNo + 1;
	-- Create Label for layout view
	LabelCreate(inGroupNo,"Fade");
end

-- *************************************************************
-- CreateDelayGroup
-- *************************************************************

local function CreateDelayGroup(inGroupNo)
	log("[CreateDelayGroup] Installing group (Delay)");
	local myNo = 0;
	-- Install delay group macros
	myNo = myNo + 1;
	MacroDelayTimeCreate(myNo,"0",inGroupNo);
	myNo = myNo + 1;
	MacroDelayTimeCreate(myNo,"0.5s",inGroupNo);
	myNo = myNo + 1;
	MacroDelayTimeCreate(myNo,"1s",inGroupNo);
	myNo = myNo + 1;
	MacroDelayTimeCreate(myNo,"2s",inGroupNo);
	myNo = myNo + 1;
	MacroDelayTimeCreate(myNo,"5s",inGroupNo);
	myNo = myNo + 1;
	-- Create Label for layout view
	LabelCreate(inGroupNo,"Delay");
end

-- *************************************************************
-- CreateColorExecModeGroup
-- *************************************************************

local function CreateColorExecModeGroup(inGroupNo)
	log("[CreateColorExecModeGroup] Installing group (ColorExecMode)");
	local myNo = 0;
	myNo = myNo + 1;
	MacroColorExecModeCreate(myNo,"Mode",inGroupNo);
	myNo = myNo + 1;
	MacroColorExecModeTriggerCreate(myNo,"Trigger",inGroupNo);	
	LabelCreate(inGroupNo,"ColorExec");
end

-- *************************************************************
-- CreateDelaySwapGroup
-- *************************************************************

local function CreateDelaySwapGroup(inGroupNo)
	log("[CreateDelaySwapGroup] Installing group (DelaySwap)");
	local myNo = 0;
	-- Install delay swap macro
	myNo = myNo + 1;
	MacroDelaySwapCreate(myNo,"SWAP",inGroupNo);
	-- Create Label for layout view
	LabelCreate(inGroupNo,"DelaySwap");
end

-- *************************************************************
-- PrepareImages
-- *************************************************************

local function PrepareImages()
	log("[PrepareImages] Loading images to storage location.");
	gParams.mImage.mGridItemAllNo = ImagePrepare("active","grid_item_active.png.xml");
	gParams.mImage.mGridItemActiveNo = ImagePrepare("active","grid_item_active.png.xml");
	gParams.mImage.mGridItemInactiveNo = ImagePrepare("inactive","grid_item_inactive.png.xml");
	gParams.mImage.mDelayLeftActiveNo = ImagePrepare("delay_left_active","grid_item_delay_left_active.png.xml");
	gParams.mImage.mDelayRightActiveNo = ImagePrepare("delay_right_active","grid_item_delay_right_active.png.xml");
	gParams.mImage.mDelayInOutActiveNo = ImagePrepare("delay_in_out_active","grid_item_delay_in_out_active.png.xml");
	gParams.mImage.mDelayOutInActiveNo = ImagePrepare("delay_out_in_active","grid_item_delay_out_in_active.png.xml");
	gParams.mImage.mDelayOffActiveNo = ImagePrepare("delay_off_active","grid_item_delay_off_active.png.xml");
	gParams.mImage.mDelayLeftInactiveNo = ImagePrepare("delay_left_inactive","grid_item_delay_left_inactive.png.xml");
	gParams.mImage.mDelayRightInactiveNo = ImagePrepare("delay_right_inactive","grid_item_delay_right_inactive.png.xml");
	gParams.mImage.mDelayInOutInactiveNo = ImagePrepare("delay_in_out_inactive","grid_item_delay_in_out_inactive.png.xml");
	gParams.mImage.mDelayOutInInactiveNo = ImagePrepare("delay_out_in_inactive","grid_item_delay_out_in_inactive.png.xml");
	gParams.mImage.mDelayOffInactiveNo = ImagePrepare("delay_off_inactive","grid_item_delay_off_inactive.png.xml");
end

-- *************************************************************
-- CreateDialogFinish
-- *************************************************************

local function CreateDialogFinish()
	local myResult = {
		title="Installation finished",                 
		backColor="Global.Focus",                       
		icon="wizard",                                
		titleTextColor="Global.OrangeIndicator",		
		messageTextColor=nil,                           
		message="Yeeeehaaaa, the installation was successful.\nYou may now use your freshly squeezed ColorGrid on:\n\nLayout " .. gParams.mLayout.mBaseNo .. "(" .. gParams.mLayout.mLayoutName .. ")",   --string
		display= nil,                                   --int? | handle?
		commands={
			{value=0, name="Nice, Thank you :)"},                       --int, string
		},
	}
	return myResult;
end

-- *************************************************************
-- install
-- *************************************************************

local function CgInstall()
	local myEntryNoBackup = 0;
	local myGroupNo = 1;
	log("[CgInstall] Installing colorgrid");
	local myProgress = StartProgress("Installing Magic ColorGrid");
	prepare_console();
	
	-- Prepare Image pool
	PrepareImages();
	-- Install colorgrid for each group we have found
	for myKey,myGroupItem in pairs(gParams.mGroup.mGroups) do
		myGroupIncluded = myGroupItem.mInclude;
		if myGroupIncluded == true  then
			local myGroupName = myGroupItem.mName;
			myGroupNo = myGroupItem.mNo;
			log("[CgInstall] Installing group " .. myGroupNo .. "(" .. myGroupName .. ")");
			-- Install entries for all colors in our gel
			for myEntryNo=1,gParams.mMaxGelNo do
				CreateGridEntry(myEntryNo,myGroupItem);
				myEntryNoBackup = myEntryNo;
			end

			-- Create the delay macros if we are rgb or cmy, otherwise that does not make sense.
			if ( myGroupItem.mColMixType == cColMixTypeRGBCMY ) then
				CreateDelayMacros(myEntryNoBackup,myGroupNo,myGroupName);
			end
			
			-- Create Label for layout view
			LabelCreate(myGroupNo,nil);
			gParams.mColorGrid.mCurrentRowNo = gParams.mColorGrid.mCurrentRowNo + 1;
		end
	end

	-- Add "All" Grid items
	CreateAllGroup(myGroupNo);
	myGroupNo = myGroupNo + 1;
	
	-- Create delay time buttons
	CreateDelayGroup(myGroupNo);
	myGroupNo = myGroupNo + 1;
	gParams.mColorGrid.mCurrentRowNo = gParams.mColorGrid.mCurrentRowNo + 1;
	
	-- Create delay time buttons
	CreateFadeGroup(myGroupNo);
	myGroupNo = myGroupNo + 1;
	gParams.mColorGrid.mCurrentRowNo = gParams.mColorGrid.mCurrentRowNo + 1;
	
	-- Create color exec mode buttons
	CreateColorExecModeGroup(myGroupNo);
	myGroupNo = myGroupNo + 1;
	gParams.mColorGrid.mCurrentRowNo = gParams.mColorGrid.mCurrentRowNo + 1;
	
	-- Create signature label
	LabelCreate(myGroupNo,cColorGridVersionText,600,nil,200,nil);
	
	-- Actually create our colorgrid
	LayoutCreate();

	-- Set default delaytime variable
	C("SetUserVar " .. gParams.mVar.mDelaytimeName .. " \"" .. gParams.mVar.mDelaytimeDefaultVal .. "\"");
	-- Set first color and delay macro to off as default
	C("Go+ macro " .. gParams.mMacro.mDelayOffMacroNo);
	C("Go+ macro " .. gParams.mMacro.mDelayTimeZeroMacroNo);
	C("Go+ macro " .. gParams.mMacro.mFadeTimeZeroMacroNo);
	C("Go+ macro " .. gParams.mMacro.mAllColorWhiteMacroNo);
	C("Go+ macro " .. gParams.mMacro.mColorExecModeMacroNo);
	
	StopProgress(myProgress);
	
	MessageBox(CreateDialogFinish());
	log("[CgInstall] Finished successfully");
end

-- *************************************************************
-- CreateMainDialogChoose
-- *************************************************************

local function CreateMainDialogChoose()
	local myResult = {
		title="Colorgrid, Choose your destiny :)", 
		backColor="Global.Focus",               
		icon="wizard",                          
		titleTextColor="Global.OrangeIndicator",
		messageTextColor=nil,                   
		message="Please choose wheter you want to use the easy or expert installation configuration.",   --string
		display= nil,                           
		commands={
			{value=0, name="EASY (For regular human beings)"},          
			{value=1, name="EXPERT (For badass operators)"}
		},
	}
	return myResult;
end

local cDialogImageText="Base storage no";
local cDialogColorCapableGroupsText="Color capable groups";
local cDialogMaximumGroupNumberText="Maximum group number";

-- *************************************************************
-- getNonColorGroupInfo
-- *************************************************************

local function getNonColorGroupInfo()
	local myResult = "";
	local myNonColorGroups = getNonColorCapableGroupNoAsCsvString();	
	if ( myNonColorGroups ~= "" ) then	
		myResult = "\n\nThe Groups \"" .. myNonColorGroups .. "\" have been omitted since they do not support any color parameters.";
	end
	return myResult;
end

-- *************************************************************
-- CreateMainDialogEasy
-- *************************************************************

local function CreateMainDialogEasy()
	local myColorGroups = getColorCapableGroupNoAsCsvString();
	local myNonColorGroups = getNonColorCapableGroupNoAsCsvString();
	local myResult = {
		title="Installation Options",                   --string
		backColor="Global.Focus",                       --string: Color based on current theme.
		icon="wizard",                                  --int|string
		titleTextColor="Global.OrangeIndicator",		--int|string
		messageTextColor=nil,                           --int|string
		message="Please choose the fixture groups that should be included in the color grid by their number.\n\nBy default all groups will be added." .. getNonColorGroupInfo(),   --string
		display= nil,                                   --int? | handle?
		commands={
			{value=0, name="INSTALL"},                       --int, string
			{value=1, name="ABORT"}
		},
		inputs={
			{name=cDialogColorCapableGroupsText, value=myColorGroups, blackFilter="", whiteFilter="0123456789,", vkPlugin="TextInput"},
		},
	}
	return myResult;
end

-- *************************************************************
-- CreateMainDialogExpert
-- *************************************************************

local function CreateMainDialogExpert()
	local myColorGroups = getColorCapableGroupNoAsCsvString();


	local myResult = {
		title="Installation Options",                   --string
		backColor="Global.Focus",                       --string: Color based on current theme.
		icon="wizard",                                  --int|string
		titleTextColor="Global.OrangeIndicator",		--int|string
		messageTextColor=nil,                           --int|string
		message="Please choose the fixture groups that should be included in the color grid by their number.\n\nBy default all groups will be added.\n\nFurthermore you are able to adjust the maximum number of groups that are supported as well as the starting storage position for the new objects." .. getNonColorGroupInfo(),   --string
		display= nil,                                   --int? | handle?
		commands={
			{value=0, name="INSTALL"},                       --int, string
			{value=1, name="ABORT"}
		},
		inputs={
			{name=cDialogColorCapableGroupsText, value=myColorGroups, blackFilter="", whiteFilter="0123456789,", vkPlugin="TextInput"},
			{name=cDialogMaximumGroupNumberText, value=gParams.mGroup.mMaxCheckNo, blackFilter="", whiteFilter="0123456789", vkPlugin="TextInputNumOnly"},
			{name=cDialogImageText, value=gParams.mImage.mBaseExecNo, blackFilter="", whiteFilter="0123456789", vkPlugin="TextInputNumOnly"},
		},
	}
	return myResult;
end

-- *************************************************************
-- initDefaults
-- *************************************************************

local function initDefaults()
	gParams.mGroup.mCurrentGroupNo = 0;
	gParams.mGroup.mGroups = {};
	gParams.mColorGrid.mGrid = {};	
	gParams.mColorGrid.mCurrentRowNo = 1;
	gParams.mImage.mBaseStorageNo = gParams.mImage.mBaseExecNo + 1024;
end

-- *************************************************************
-- main
-- *************************************************************

local function main(inDisplayHandle,inArguments)
	local myRet;
	log("Magic ColorGrid Starting up... Tadaaa.");
	if GetTokenName(inArguments) ~= "/NoConfirm" then
		-- warning message
		local x = Confirm('Warning','Colorgrid will alter your current showfile and maybe break anything.\nYou have been warned :)',inDisplayHandle)
		if x == false then return; end
	end
	initDefaults();
	initGroupRegister();
	-- select mode
	myRet = MessageBox(CreateMainDialogChoose());
	if  (myRet.result == 0) then
		myRet = MessageBox(CreateMainDialogEasy());	
	elseif  (myRet.result == 1) then
		myRet = MessageBox(CreateMainDialogExpert());	
		gParams.mGroup.mMaxCheckNo = tonumber(myRet.inputs[cDialogMaximumGroupNumberText]);
		gParams.mImage.mBaseStorageNo = tonumber(myRet.inputs[cDialogImageText]);
		gParams.mAppearance.mBaseNo = tonumber(myRet.inputs[cDialogImageText]);
		gParams.mPreset.mBaseNo = tonumber(myRet.inputs[cDialogImageText]);
		gParams.mSequence.mBaseNo = tonumber(myRet.inputs[cDialogImageText]);
		gParams.mMacro.mBaseNo = tonumber(myRet.inputs[cDialogImageText]);
		gParams.mLayout.mBaseNo = tonumber(myRet.inputs[cDialogImageText]);
		gParams.mImage.mBaseStorageNo = gParams.mImage.mBaseExecNo + 1024;
	else
		goto exit;
	end
	
	-- Register groups that should be included in the grid
	if ( setGroupsForColorGridFromCsv(myRet.inputs[cDialogColorCapableGroupsText]) == false ) then
		local x = Confirm('Warning','No groups selected. At least one group is needed to work properly',inDisplayHandle)
		if x == false then return; end
	else
		if  (myRet.result == 0) then
			CgInstall();
		end
	end
::exit::
end


if _DEBUG == true then
	return main(1,0)
else
	return main
end

