CreatePopupLang(Ctr, *) {
	If WinExist(App.Name "_Popup")
		WinClose
	Ctr.GetPos(&xCtr,&yCtr,&wCtr,&hCtr)
	g:=Ctr.Gui
	g.GetPos(&xG,&yG)
	g2:=CreateDlg(g, 0)
	
	NavSelectW:=200, NavSelectH:=30
	
	g2.AddPic("Hidden vNavBGHover xm")
	g2.AddPic("vNavBGActive Hidden xm")
	pToken:=Gdip_Startup()
	CreateBGNavSelect(g2["NavBGHover"], g2["NavBGActive"], NavSelectW, NavSelectH ,6)

	SpaceName:="            "
    for k,v in LangData.OwnProps() {
		y:=(A_Index-1)*34
		hFlag:=Gdip_CreateARGBHBITMAPFromBase64(v.Flag)
		Flag:=g2.AddPic("BackgroundTrans h20 w20 xm8 ym" y+6, "HBITMAP:" hFlag)
		DeleteObject(hFlag)
		NavItem:=g2.AddText("BackgroundTrans 0x200 0x100 h" NavSelectH " w" NavSelectW " xm ym" y " vNavItem_" k, SpaceName v.Name)
		NavItem.OnEvent("Click", Lang_Code_Click)
    }
	Gdip_Shutdown(pToken)
	
	g2["NavItem_" LangSelected].GetPos(&xNavItem, &yNavItem)
	g2["NavBGActive"].Move(xNavItem, yNavItem)
	g2["NavBGActive"].Visible:=True
	
    Lang_Code_Click(Ctr, *) {
		LangClicked:=SubStr(Ctr.Name,9)
		Global LangSelected
		If LangClicked=LangSelected {
			g2.Destroy()
			Return
		}
		LangSelected:=LangClicked
		Lang:=LangData.%LangSelected%
		For , GuiCtrlObj in g {
			If InStr(GuiCtrlObj.Name,"NavItem_") && GuiCtrlObj.Name!= "NavItem_UserName" {
				NavItemID:=SubStr(GuiCtrlObj.Name,9)
				GuiCtrlObj.Text:=SpaceName GetLangName(Layout[NavItemID].ID)
			} Else If GuiCtrlObj.Name && Lang.HasOwnProp(GuiCtrlObj.Name) 
					&& Lang.%GuiCtrlObj.Name%.HasOwnProp("Name") && Lang.%GuiCtrlObj.Name%.Name {
				GuiCtrlObj.Text:=GetLangName(GuiCtrlObj.Name)
			}
		}
		pToken:=Gdip_Startup()
		hFlag:=Gdip_CreateARGBHBITMAPFromBase64(LangData.%LangSelected%.Flag)
		g["BtnSys_Language"].Value:="HBITMAP:" hFlag
		DeleteObject(hFlag)
		Gdip_Shutdown(pToken)
		IniWrite LangClicked, "config.ini", "General", "Language"
		g2.Destroy()
		NavItem_Click(g)
    }
    tX:=xG+xCtr-(NavSelectW+12-wCtr)/2
	tY:=yG+yCtr+hCtr+6
	g2.Show("x" tX " y" tY)
	If WinWaitNotActive(g2)
		g2.Destroy()
}