function CWBWarnAllName(code)
    local WarnAllName = {
        ["PWS"] = "災防告警",
        ["EQ"] = "地震報告",
        ["TY_WIND"] = "颱風強風",
        ["TY_WARN"] = "颱風警報",
        ["TY_NEWS"] = "颱風消息",
        ["W23"] = "熱帶性低氣壓",
        ["W24"] = "劇烈豪雨",
        ["W25"] = "陸上強風",
        ["W26"] = "降雨特報",
        ["W27"] = "濃霧特報",
        ["W28"] = "低溫特報",
        ["W29"] = "高溫資訊",
        ["W33"] = "大雷雨即時",
        ["W34"] = "即時天氣",
        ["W37"] = "長浪即時"
    }
    if (WarnAllName[code] == nil) then
        return ""
    else
        return WarnAllName[code]
    end
end
