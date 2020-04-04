room = {}
--['峨嵋山八十四盘']='ne;nd',
--['峨嵋山九老洞']=function() if location.exit["enter"] then return 'enter' else return 'drop fire;leave;leave;leave;leave' end end,
--['峨嵋山十二盘']='ne;ed;ne;ed',
--['大雪山吐蕃织造作坊']='e;n;e',
--['大雪山佛照门']='w;n;w',
--['大雪山猛虎营']='e;n;e',
--['大雪山明霞门']='n;n;e',
--['大雪山巨水门']='s;s;s;e',
--['华山山涧']='nw;ne;ne;eu;se',
--['黄河流域黄河岸边']='nu;#2(sw);#2w',
--['黄河流域树林']='e;ne;#2n',
--['黄河流域草地']='e;s',
--['黄河流域田地']='#2e;ne;n',
--['明教小沙丘']='#4e',
--['明教栈道']='#2(sw);#2(se);s',
--['明教山路']='ed;wd;sd;nd',
--['明教树林深处']=function() if location.id["老虎"] then return 'halt;n;w;nu' elseif location.id["小树枝"] then return 'halt;w;nw;n;w;nu' elseif location.id["无名尸体"] then return 'halt;nw;n;w;nu' elseif location.id["大树干"] then return 'halt;w;n;w;nu' else return location.dir end end,
--['明教树林']=function() if location.id["大石头"] then return 'halt;e;nu' elseif location.id["大树干"] then return 'halt;w;nu' else return location.dir end end,
--['嵩山少林石阶']='sd;sd;sd;ed;sd;e',
-- ain
--['武当山黄土路']='e;e',
--['襄阳城山间小路']='ne;nd;se;se;#2s;n;e',
--['星宿海星宿海']='se;#7n',
--['星宿海山洞']='out;use fire;zuan out;ed',
--['扬州城长江北岸']='w;w;e;n',
--['扬州城长江南岸']='w;w;e;s;se;s',

DangerousRoom = {
    ["苗疆蛇房"] = true,
	["明教龙王殿"] = true,
	["昆仑山灵獒宫"] = true,
	["桃花岛积翠亭"] = true,
}

mjMenid = {
    ["风字门"] = "mingjiao/didao/men-feng",
	["雷字门"] = "mingjiao/didao/men-lei",
	["天字门"] = "mingjiao/didao/men-tian",
	["地字门"] = "mingjiao/didao/men-di",
	}
AddrIgnores = {
	["燕子坞"] = true,
	["姑苏慕容"] = true,
    ["桃花岛"] = true,
	["神龙岛"] = true,
	["曼佗罗山庄"] = true,
	["萧府"] = true,
	["桃源县"] = true,
}
sxAddrIgnores = { --送信任务放弃的区域
--	["燕子坞"] = true,
--	["姑苏慕容"] = true,
--    ["桃花岛"] = true,
	["神龙岛"] = true,
--	["曼佗罗山庄"] = true,
	["萧府"] = true,
--	["桃源县"] = true,
--	["天山"] = true,
	["绝情谷"] = true,
}
MrArea = {
    ["燕子坞"] = true,
	["姑苏慕容"] = true,
	["曼佗罗山庄"] = true,
}
ZsfArea = {
    ["武当山后山小院"] = true,
	["武当山院门"] = true,
}
hsAddrIgnores = { --华山任务放弃的区域
--    ["桃花岛"] = true,
--	["神龙岛"] = true,
--	["萧府"] = true,
--	["桃源县"] = true, --桃源县分为一二三区，huashan.lua里面设置为自动放弃二三区。一区在大理南，可去。
}
AddrIgnoresWDHard = {
--	["神龙岛"] = "已入化境|极其厉害",
--	["桃源县"] = "已入化境|极其厉害",
	}
WhereIgnores = {
	["福州城山路"] = true,
--	["武当山院门"] = true,
--	["武当山后山小院"] = true,
--	["苗疆山路"] = true,
--	["绝情谷中堂"] = true,
--	["绝情谷小室"] = true,
--	["绝情谷大室"] = true,
	["昆仑山石路"] = true,
}
sxWhereIgnores = { --送信任务放弃的地方
	["福州城山路"] = true,
	["星宿海山洞"] = true,
	["血刀门山洞"] = true,
    ["明教天字门"] = true,
    ["明教地字门"] = true,
    ["明教风字门"] = true,
    ["明教雷字门"] = true,
 --   ["苗疆山路"] = true,  --有9阳的明教可以不放弃。其他门派建议放弃。
--    ["嵩山少林石板路"] = true,
--    ["嵩山少林石阶"] = true,
    ["福州城山路"] = true,
    ["全真派药剂室"] = true,
	["绝情谷大室"] = true,
	["绝情谷小室"] = true,
	["明教紫杉林"] = true,
	["平定州客房"] = true,
	["血刀门山路"] = true,
--	["杭州青石大道"] = true,
	["长安城官道"] = true,
	["昆仑山可可西里山"] = true,
	["昆仑山石路"] = true,
}
xsWhereIgnores = {
	["福州城山路"] = true,
	["苗疆山路"] = true,
	["绝情谷中堂"] = true,
	["绝情谷小室"] = true,
	["绝情谷大室"] = true,
	["桃花岛绿竹林"] = true,
}
ssWhereIgnores = {
	["福州城山路"] = true,
	["苗疆山路"] = true,
	["绝情谷中堂"] = true,
	["绝情谷小室"] = true,
	["绝情谷大室"] = true,
}
tdhWhereIgnores = {
	["福州城山路"] = true,
	["苗疆山路"] = true,
	["绝情谷中堂"] = true,
	["绝情谷小室"] = true,
	["绝情谷大室"] = true,
	}
tdh_yili = {
	["伊犁城铁铺"] = true,
	["伊犁城城中心"] = true,
	["伊犁城客栈"] = true,
	["伊犁城巴依家院"] = true,
	["伊犁城商铺"] = true,
}
WhereNoScan = {
    ["星宿海大沙漠"] = true,
	["回疆针叶林"] = true,
	["明教紫杉林"] = true,
}
jqg_far="绝情谷中堂|绝情谷小室|绝情谷卧室|绝情谷大室|绝情谷谷中小路|绝情谷花丛|绝情谷水潭岸边|绝情谷峭壁|绝情谷谷底|绝情谷谷底水潭|绝情谷水潭表面"
jqg_near="绝情谷山间小路|绝情谷小溪边"
taoyuan1="桃源县小饭铺|桃源县山间小路|桃源县陡路上岭|桃源县山谷瀑布|桃源县茅屋"
taoyuan2="桃源县瀑布中|桃源县铁舟上|桃源县山洞|桃源县岸边|桃源县山顶|桃源县山坡|桃源县石梁|桃源县石梁尽头"
taoyuan3="桃源县河塘|桃源县小石桥|桃源县禅院大殿|桃源县禅院后院|桃源县青石小径|桃源县竹林|桃源县石屋正房|桃源县石屋厢房|桃源县斋堂|桃源县练功房|桃源县西厢房|桃源县东厢房"
NwArea = {
    ["昆仑山"] = true,
	["回疆"] = true,
	["明教"] = true,
	["天山"] = true,
	["星宿海"] = true,
	["伊犁城"] = true,
	["逍遥派"] = true,
}
NeArea = {
    ["沧州城"] = true,
	["恒山"] = true,
	["黑木崖"] = true,
	["平定州"] = true,
	["塘沽城"] = true,
	["神龙岛"] = true,
}
CjSouthArea = {
    ["莆田少林"] = true,
	["苏州城"] = true,
	["牛家村"] = true,
	["归云庄"] = true,
	["杭州城"] = true,
	["宁波城"] = true,
	["福州城"] = true,
	["桃花岛"] = true,
}
CjSouthRooms = {
    ["丐帮后院"] = true,
	["丐帮土地庙"] = true,
	["丐帮杏子林"] = true,
	["丐帮空地"] = true,
	["丐帮田径"] = true,
}
NearArea = {
    ["成都城"] = true,
	["扬州城"] = true,
	["大理城"] = true,
	["大理城西"] = true,
	["大理城南"] = true,
	["大理城东"] = true,
	["大理王府"] = true,
	["大理皇宫"] = true,
	["玉虚观"] = true,
	["全真教"] = true,
	["华山"] = true,
	["南阳城"] = true,
	["华山村"] = true,
	["嵩山"] = true,
	["泰山"] = true,
	["武当山"] = true,
	["襄阳城"] = true,
	["武当山"] = true,
	["柳宗镇"] = true,
	["长乐帮"] = true,
	["嵩山少林"] = true,
	["苗疆"] = true,
	["峨嵋山"] = true,
	["长安城"] = true,
	["天龙寺"] = true,
	["大雪山"] = true,
	["中原神州"] = true,
	["蒙古"] = true,
	["无量山"] = true,
	["蝴蝶谷"] = true,
	["黄河流域"] = true,
	["铁掌山"] = true,
	["终南山"] = true,
	["成都郊外"] = true,
	["襄阳郊外"] = true,
	["凌霄城"] = true,
}

-- ---------------------------------------------------------------
-- 部分迷宫走法集合
-- ---------------------------------------------------------------
roomMaze = {
    ['成都城北大街']='s',
    ['成都城南大街']='n',
    ['成都城东大街']='w',
    ['成都城西大街']='e',
    ['成都城南侧街']='s',
    ['成都城城跟路']='e;se;se;s;s',
    
    ['大草原草海']=function() return location.dir end,
    
    ['长安城东城墙']='#8n;#4s',
    ['长安城南城墙']='#10w;#5e',
    ['长安城西城墙']='#8n;#4s',
    ['长安城北城墙']='#10w;#5e',
    
    ['大理城大理西大街']='s;w',
    ['大理城大理南大街']='s',
    ['大理城大理北大街']='e;n',
    ['大理城大理东大街']='s;e',
    
    ['峨嵋山八十四盘']='ne;nd',
    ['峨嵋山九老洞']=function() if location.exit["enter"] then return 'enter' else return 'drop fire;leave;leave;leave;leave' end end,
    ['峨嵋山冷杉林']='sw;se',
    ['峨嵋山十二盘']='ne;ed;ne;ed',
    ['峨嵋山钻天坡']='ed;ed',
    --['峨嵋山洗象池边']='s;su',
    
    ['佛山镇林间道']='#2e;nw;ne;se;n',
    
    ['杭州城柳林']='#3n',
    
    ['回疆针叶林']=function() if math.random(1,4)==1 then return 'ne;#10e' elseif math.random(1,4)==2 then return 'ne;#10w' elseif math.random(1,4)==3 then return 'ne;#10s' else return 'ne;#10n' end end,
    
    ['华山松树林']='n;e;e;e;n;e;e;e',
    
    ['黄河流域黄河岸边']='nu;#2(sw);#2w',
    ['黄河流域树林']='e;ne;#2n',
    ['黄河流域草地']='e;s',
    ['黄河流域田地']='#2e;ne;n',
    
    ['丐帮杏子林']='e;n;w;n',
    
    ['归云庄树林深处']='s;se;w;#2s;w;s',
    ['归云庄树林']='#2e;w;#2s',
    ['归云庄草地']='#2e;w;s',
    
    ['姑苏慕容柳树林']='e;n;w;n;yue tree',
    
    ['绝情谷崖壁']='pa up',
    --['绝情谷谷底水潭']='drop stone;qian up;pa up',
    --['绝情谷谷底水潭']=function() if math.random(1,2)==1 then return 'drop stone;qian up;pa up' else return 'drop silver;drop jian;drop blade;drop whip;drop hammer;drop xiao;drop staff' end end,
    ['绝情谷谷底水潭']=function() if math.random(1,2)==1 then return 'drop stone;qian up;pa up' else return gmDropStoneCmd() end end,
    
    ['明教小沙丘']='#4e',
    ['明教栈道']='#2(sw);#2(se);s',
    ['明教山路']='ed;wd;sd;nd',
    ['明教树林深处']=function() if location.id["老虎"] then return 'halt;n;w;nu' elseif location.id["小树枝"] then return 'halt;w;nw;n;w;nu' elseif location.id["无名尸体"] then return 'halt;nw;n;w;nu' elseif location.id["大树干"] then return 'halt;w;n;w;nu' else return location.dir end end,
    ['明教树林']=function() if location.id["大石头"] then return 'halt;e;nu' elseif location.id["大树干"] then return 'halt;w;nu' else return location.dir end end,
    
    ['神龙岛沙滩']='sw;se',
    ['神龙岛树林']='sw;se;s',
    ['神龙岛走廊']='#2e;n',
    ['神龙岛山坡']='d;wd;su;sd;wd',
    ['神龙岛山路']='s;sd;d;wd;su',
    
    ['神龙岛陷阱']='climb up',
    ['神龙岛牢房']='push flag',
    
    ['嵩山少林竹林']='nw;w;e;e;s;w;n;nw;n;s',
    ['嵩山少林菜园子']='s;w;n;n;n;nw;n;n;w;w;w',
    ['嵩山少林小路']='n;nw;n;n;w;w',
    ['嵩山少林饭厅']='s;s;n;w',
    ['嵩山少林回廊']='n;w;n',
    ['嵩山少林练武场']='s;s;n;e',
    ['嵩山少林武僧堂']='n;n;n;e',
    ['嵩山少林香积厨']='n;w;w',
    ['嵩山少林石阶']='ed;sd;e',
    -- ain
    --['嵩山少林塔林']= 's;e;ne;se;s;se;open door;e',
    ['嵩山少林塔林']=function()
        local r=math.random(1,11)
        if r==1 then return 'ne;se;n;e;sw;e;ne;se;s;se;open door;e' end
        if r==2 then return 'se;n;e;sw;e;ne;se;s;se;open door;e' end
        if r==3 then return 'n;e;sw;e;ne;se;s;se;open door;e' end
        if r==4 then return 'e;sw;e;ne;se;s;se;open door;e' end
        if r==5 then return 'sw;e;ne;se;s;se;open door;e' end
        if r==6 then return 'e;ne;se;s;se;open door;e' end
        if r==7 then return 'ne;se;s;se;open door;e' end
        if r==8 then return 'se;s;se;open door;s' end
        if r==9 then return 's;se;open door;e' end
        if r==10 then return 'se;open door;e' end
        if r==11 then return 'open door;e' end
    end,
    ['嵩山少林槐树林']='w;n',
    ['嵩山少林松树林']='w;n;nw',
    ['嵩山少林僧舍']=function() if location.id["慧合尊者"] then return 'w;s;e' elseif location.id["慧虚尊者"] then return 'e;s;w' else return location.dir end end,
    
    ['天龙寺松树林']='s;w;s;w;#8s',
    
    ['武当山黄土路']='e;e',
    ['武当山小径']='#5n',
    
    ['铁掌山松树林']='n;e;n;w;n',
    
    ['襄阳城山间小路']='ne;nd;se;se;#2s;n;e',
    
    ['襄阳郊外树林']=function()
        local r=math.random(1,4)
        if r>1 then
            local r=math.random(1,4)
            if r==4 then
                local r1=math.random(1,4)
                if r1==4 then return 'w;e;w;s;n;s;s;n;s'
                elseif r1==3 then return 's;e;w;s;n;s;s;n;s'
                elseif r1==2 then return 'n;e;w;s;n;s;s;n;s'
                else return 'e;e;w;s;n;s;s;n;s' end
            elseif r==3 then
                return 'w;s;e;w;s;n;s;s;n;s'
            elseif r==2 then
                return 'e;s;e;w;s;n;s;s;n;s'
            else
                return 'n;e;e;w;s;n;s;s;n;s'
            end
        else
            local r=math.random(1,10)
            if r==1 then return 'n;e;n;e;w;s;n;s;s;n;s'
            elseif r==2 then return 'e;n;e;w;s;n;s;s;n;s'
            elseif r==3 then return 'n;e;w;s;n;s;s;n;s'
            elseif r==4 then return 'e;w;s;n;s;s;n;s'
            elseif r==5 then return 'w;s;n;s;s;n;s'
            elseif r==6 then return 's;n;s;s;n;s'
            elseif r==7 then return 'n;s;s;n;s'
            elseif r==8 then return 's;s;n;s'
            elseif r==9 then return 's;n;s'
            else return 'n;s'
            end
        end
    end,
    
    ['桃源县石梁']='jump front',
    ['嵩山少林僧舍']=function() if location.id["慧合尊者"] then return 'w;s;e' elseif location.id["慧虚尊者"] then return 'e;s;w' else return location.dir end end,
    ['星宿海星宿海']='se;#7n',
    ['星宿海大沙漠']='#8w',
    ['扬州城长江北岸']='w;w;e;n',
    ['扬州城长江南岸']='w;w;e;s;se;s',
    ['扬州城西大街']='e;n',
    ['扬州城南大街']='s;w',
    ['扬州城北大街']='e',
    ['扬州城东大街']='w;n',
    ['曼佗罗山庄花丛中']='south;#3w;#2e;#3s',
}
--['峨嵋山九老洞']={'leave'},
roomNodir = {
    ["大理皇宫正厅"] = {"north"},
    ["兰州城青城"] = {"northeast"},
    ["长安城土路"] = {"east", "west"},
    ["杭州城山路"] = {"east", "west"},
    ["杭州城小筑"] = {"southwest"},
    ["黄河流域树林"] = {"southwest"},
    ["华山村村中心"] = {"northwest", "northeast"},
    ["华山空地"] = {"southdown"},
    ["华山山脚下"] = {"south"},
    ["绝情谷山顶平地"] = {"northdown"},
    ["兰州城苗家庄门口"] = {"west"},
    ["昆仑山铁琴居"] = {"west"},
    ["昆仑山九曲廊"] = {"southwest"},
    ["昆仑山后院门"] = {"east"},
    ["昆仑山后院"] = {"south"},
    ["梅庄小路"] = {"south"},
    ["明教黄土坪"] = {"south", "east"},
    ["明教巨木旗"] = {"west", "east"},
    ["明教烈火旗"] = {"west"},
    ["明教洪水旗"] = {"east"},
    ["明教锐金旗"] = {"east"},
    ["明教厚土旗"] = {"east", "west"},
    ["明教聚议厅"] = {"west"},
    ["苗疆山脚"] = {"northup", "northwest"},
    ["莆田少林戒持院"] = {"south"},
    ["嵩山少林演武堂"] = {"west"},
    ["嵩山少林舍利院"] = {"west"},
    ["嵩山少林山路"] = {"east", "northwest"},
    ["嵩山寝殿"] = {"north"},
    ["苏州城后院"] = {"north"},
    ["武当山小径"] = {"south", "west", "east"},
    ["无量山荆棘林"] = {"north", "west"},
    ["无量山后院"] = {"north"},
    ["星宿海吐谷浑伏俟城"] = {"south"},
    ["星宿海天山脚下"] = {"southwest"},
    ["星宿海星宿海"] = {"south", "north", "east"},
    ["星宿海日月洞口"] = {"west", "east"},
    ["星宿海日月洞"] = {"north"},
    ["星宿海小路"] = {"south", "west"},
    ["星宿海海边荒路"] = {"south", "north", "east"}
}
MidNight = {
    ["酉"] = true,
    ["戌"] = true,
    ["亥"] = true,
    ["子"] = true,
    ["丑"] = true,
    ["寅"] = false,
    ["卯"] = false,
    ["辰"] = false,
    ["巳"] = false,
    ["午"] = false,
    ["未"] = false,
    ["申"] = false 
}
YiliNight = {
    ["酉"] = true,
    ["戌"] = true,
    ["亥"] = true,
    ["子"] = true,
    ["丑"] = true,
    ["寅"] = true,
    ["卯"] = false,
    ["辰"] = false,
    ["巳"] = false,
    ["午"] = false,
    ["未"] = false,
    ["申"] = false
}
YiliNightHs = {
    ["酉"] = false,
    ["戌"] = false,
    ["亥"] = false,
    ["子"] = true,
    ["丑"] = true,
    ["寅"] = true,
    ["卯"] = false,
    ["辰"] = false,
    ["巳"] = false,
    ["午"] = false,
    ["未"] = false,
    ["申"] = false
}
MidDay = {
    ["酉"] = false,
    ["戌"] = true,
    ["亥"] = true,
    ["子"] = true,
    ["丑"] = true,
    ["寅"] = true,
    ["卯"] = false,
    ["辰"] = false,
    ["巳"] = false,
    ["午"] = false,
    ["未"] = false,
    ["申"] = false
}
MidHsDay = {
    ["申"] = false,
    ["酉"] = false,
    ["戌"] = false,
    ["亥"] = true,
    ["子"] = true,
    ["丑"] = true,
    ["寅"] = true,
    ["卯"] = true,
    ["辰"] = false,
    ["巳"] = false,
    ["午"] = false,
    ["未"] = false
}
MidYiliDay = {["申"] = true, ["寅"] = true}

WipeNoPerform = {
    ["guan bing"] = true,
    ["zhiqin bing"] = true,
    ["wu jiang"] = true,
    ["guan jia"] = true,
    ["ya yi"] = true,
    ["da yayi"] = true,
    ["huanggong shiwei"] = true,
    ["dali guanbing"] = true,
    ["dali wujiang"] = true,
    ["yu guangbiao"] = true,
    ["wu guangsheng"] = true,
    ["jia ding"] = true,
    ["ya huan"] = true,
    ["wu seng"] = true,
    ["daoyi chanshi"] = true,
    ["zhuang ding"] = true,
    ["heiyi bangzhong"] = true,
    ["xingxiu dizi"] = true,
    ["hufa lama"] = true,
    ["zayi lama"] = true,
    ["caihua zi"] = true,
    ["wudujiao dizi"] = true,
    ["wei shi"] = true
    -- ["jiao zhong"] = true,
}

-- ---------------------------------------------------------------
-- Exit Reverse ..
-- ---------------------------------------------------------------
dirReverse = {
    ["up"] = "down",
    ["down"] = "up",
    ["east"] = "west",
    ["west"] = "east",
    ["eastup"] = "westdown",
    ["westup"] = "eastdown",
    ["eastdown"] = "westup",
    ["westdown"] = "eastup",
    ["south"] = "north",
    ["north"] = "south",
    ["southup"] = "northdown",
    ["northup"] = "southdown",
    ["southdown"] = "northup",
    ["northdown"] = "southup",
    ["southeast"] = "northwest",
    ["southwest"] = "northeast",
    ["northeast"] = "southwest",
    ["northwest"] = "southeast",
    ["enter"] = "out",
    ["out"] = "enter",
}

dirCN = {
    ["北面"] = {"north","northup","northdown"},
	["北边"] = {"north","northup","northdown"},
	["东面"] = {"east","eastup","eastdown"},
	["东边"] = {"east","eastup","eastdown"},
	["南面"] = {"south","southup","southdown"},
	["南边"] = {"south","southup","southdown"},
	["西面"] = {"west","westup","westdown"},
	["西边"] = {"west","westup","westdown"},
	["北面"] = {"north","northup","northdown"},
	["北边"] = {"north","northup","northdown"},
	["西北"] = "nw",
	["东北"] = "ne",
	["东南"] = "se",
	["西南"] = "sw",
	["上面"] = "up",
	["下面"] = "down",
	["外面"] = "out",
	["里面"] = "enter",
}