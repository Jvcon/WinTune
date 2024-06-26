SaveOptimizeConfigAll(SelectedFile) {
	Config:={}
	Loop Layout.Length {
		If (Layout[A_Index].ID = "" || !Layout[A_Index].HasOwnProp("Items"))
			Continue
		ItemList:=Layout[A_Index].Items
		Loop ItemList.Length {
			ItemId:=ItemList[A_Index]
			s:=CheckStatusItem(ItemId, Data.%ItemId%)
			If s<=-1
				Continue
			Config.%ItemID%:=s
		}
		
		ObjStartMenu:={}
		StartMenuLayout(&ObjStartMenu)
		Config.StartMenuLayout:=ObjStartMenu		
	}	
	try
		FileDelete SelectedFile
	FileAppend JSON.stringify(Config), SelectedFile
}
LoadOptimizeConfig(SelectedFile, g:="") {
	ConfigText:=FileRead(SelectedFile)
	Config:=JSON.parse(ConfigText,,False)
	IsRunDisableMSDefender:=0
	For ItemId, ItemValue in Config.OwnProps() {
		If ItemId="PackageManager" {
			Loop ItemValue.Length {
				If ItemValue[A_Index].Act="RemovePackage" {
					If ItemValue[A_Index].HasOwnProp("FamilyNames") {
						FamilyNames:=ItemValue[A_Index].FamilyNames
						AllUsers:=ItemValue[A_Index].HasOwnProp("AllUsers")?ItemValue[A_Index].AllUsers:0
						Deprovision:=ItemValue[A_Index].HasOwnProp("Deprovision")?ItemValue[A_Index].Deprovision:0
						Loop FamilyNames.Length {
							Packages:=PackageManager.FindPackagesByPackageFamilyName(FamilyNames[A_Index])
							Loop Packages.Length {
								UninstallPackage(Packages[A_Index], AllUsers, Deprovision)
							}
						}
					}
				}
			}
		} Else If ItemId="StartMenuLayout" {
			StartMenuLayout(&ItemValue, "set")
		} Else {
			If !Data.HasOwnProp(ItemID)
				Continue
			s:=CheckStatusItem(ItemId, Data.%ItemId%)
			If s<=-1 || ItemValue=s
				Continue
			If ItemId="DisableMSDefender" {
				IsRunDisableMSDefender:=1
				Continue
			}
			ProgNow(ItemId, ItemValue, Data.%ItemId%, 1)
		}
	}
	
	If IsRunDisableMSDefender {
		ItemId:="DisableMSDefender"
		ProgNow(ItemId, Config.%ItemId%, Data.%ItemId%, 1)
	} 
	
	If g
		NavItem_Click(g)
}