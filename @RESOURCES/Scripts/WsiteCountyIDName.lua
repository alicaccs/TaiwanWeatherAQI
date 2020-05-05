function WsiteCountyIDName(county)
    local CountyName = {
        ["基隆市"] = "10017,基隆市,Keelung,Keelung City",
            ["基隆"] =   "10017,基隆市,Keelung,Keelung City",
            ["彭佳嶼"] = "10017,基隆市,Keelung,Keelung City",
        ["臺北市"] = "63,臺北市,Taipei,Taipei City",
            ["臺北"] =   "63,臺北市,Taipei,Taipei City",
            ["鞍部"] =   "63,臺北市,Taipei,Taipei City",
            ["陽明山"] = "63,臺北市,Taipei,Taipei City",
        ["新北市"] = "65,新北市,NewTaipeiCity,New Taipei City",
            ["板橋"] =   "65,新北市,NewTaipeiCity,New Taipei City",
        ["桃園市"] = "68,桃園市,Taoyuan,Taoyuan City",
            ["新屋"] =   "68,桃園市,Taoyuan,Taoyuan City",
        ["新竹市"] = "10018,新竹市,Hsinchu,Hsinchu City",
        ["新竹縣"] = "10004,新竹縣,Hsinchu,Hsinchu County",
            ["新竹"] =   "10004,新竹縣,Hsinchu,Hsinchu County",
        ["苗栗縣"] = "10005,苗栗縣,Miaoli,Miaoli County",
        ["臺中市"] = "66,臺中市,Taichung,Taichung City",
            ["臺中"] =   "66,臺中市,Taichung,Taichung City",
            ["梧棲"] =   "66,臺中市,Taichung,Taichung City",
        ["彰化縣"] = "10007,彰化縣,Changhua,Changhua County",
        ["南投縣"] = "10008,南投縣,Nantou,Nantou County",
            ["玉山"] =   "10008,南投縣,Nantou,Nantou County",
            ["日月潭"] = "10008,南投縣,Nantou,Nantou County",
        ["雲林縣"] = "10009,雲林縣,Yunlin,Yunlin County",
        ["嘉義市"] = "10020,嘉義市,Chiayi,Chiayi City",
            ["嘉義"] =   "10020,嘉義市,Chiayi,Chiayi City",
        ["嘉義縣"] = "10010,嘉義縣,Chiayi,Chiayi County",
            ["阿里山"] = "10010,嘉義縣,Chiayi,Chiayi County",
        ["臺南市"] = "67,臺南市,Tainan,Tainan City",
            ["臺南"] =   "67,臺南市,Tainan,Tainan City",
        ["高雄市"] = "64,高雄市,Kaohsiung,Kaohsiung City",
            ["高雄"] =   "64,高雄市,Kaohsiung,Kaohsiung City",
            ["南沙島"] = "64,高雄市,Kaohsiung,Kaohsiung City",
            ["東沙島"] = "64,高雄市,Kaohsiung,Kaohsiung City",
        ["屏東縣"] = "10013,屏東縣,Pingtung,Pingtung County",
            ["恆春"] =   "10013,屏東縣,Pingtung,Pingtung County",
        ["宜蘭縣"] = "10002,宜蘭縣,Yilan,Yilan County",
            ["蘇澳"] =   "10002,宜蘭縣,Yilan,Yilan County",
            ["宜蘭"] =   "10002,宜蘭縣,Yilan,Yilan County",
        ["花蓮縣"] = "10015,花蓮縣,Hualien,Hualien County",
            ["花蓮"] =   "10015,花蓮縣,Hualien,Hualien County",
        ["臺東縣"] = "10014,臺東縣,Taitung,Taitung County",
            ["大武"] =   "10014,臺東縣,Taitung,Taitung County",
            ["成功"] =   "10014,臺東縣,Taitung,Taitung County",
            ["蘭嶼"] =   "10014,臺東縣,Taitung,Taitung County",
            ["臺東"] =   "10014,臺東縣,Taitung,Taitung County",
        ["澎湖縣"] = "10016,澎湖縣,Penghu,Penghu County",
            ["東吉島"] = "10016,澎湖縣,Penghu,Penghu County",
            ["澎湖"] =   "10016,澎湖縣,Penghu,Penghu County",
        ["金門縣"] = "09020,金門縣,Kinmen,Kinmen County",
            ["金門"] =   "09020,金門縣,Kinmen,Kinmen County",
        ["連江縣"] = "09007,連江縣,Matsu,Lienchiang County",
            ["馬祖"] =   "09007,連江縣,Matsu,Lienchiang County"
    }
    if (CountyName[county] == nil) then
        return "63,地點有誤,Taipei,Taipei City"
    else
        return CountyName[county]
    end
end
