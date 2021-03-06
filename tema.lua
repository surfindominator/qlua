Settings =
 {
    Name = "*TEMA",
 	period = 21,
  	vType = "T",
   line =
     {
         {
          Name = "Line",
          Color = RGB(255,0,0),
          Type = TYPE_LINE,
          Width =1
         }
     }
 }

function dValue(i,param)
local v = param or "C"
	if  v == "O" then
		return O(i)
	elseif   v == "H" then
		return H(i)
	elseif   v == "L" then
		return L(i)
	elseif   v == "C" then
		return C(i)
	elseif   v == "V" then
		return V(i)
	elseif   v == "M" then
		return (H(i) + L(i))/2
	elseif   v == "T" then
		return (H(i) + L(i)+C(i))/3
	elseif   v == "W" then
		return (H(i) + L(i)+2*C(i))/4
	elseif   v == "ATR" then
		return math.max(math.abs(H(i) - L(i)), math.abs(H(i) - C(i-1)), math.abs(C(i-1) - L(i)))
	else
		return C(i)
	end 
end


 function Init()
	myTEMA = TEMA()
	return #Settings.line
 end

 function OnCalculate(index)
	return myTEMA(index, Settings.period, Settings.vType)
 end
 
 function TEMA()
	
	local cache_EMA1={}
	local cache_EMA2={}
	local cache_EMA3={}
	
	return function(ind, _p, _v)
		local index = ind
		local period = _p
		local vType = _v
		local k = 2/(_p+1)
		local value = 0
		local out = nil

		if index == 1 then
			cache_EMA1 = {}
			cache_EMA2 = {}
			cache_EMA3 = {}
			if CandleExist(index) then
				cache_EMA1[index]= dValue(index, vType)
				cache_EMA2[index]= dValue(index, vType)
				cache_EMA3[index]= dValue(index, vType)
			else 
				cache_EMA1[index]= 0
				cache_EMA2[index]= 0
				cache_EMA3[index]= 0
			end
			return out
		end
		
		if not CandleExist(index) then
			cache_EMA1[index] = cache_EMA1[index-1] 
			cache_EMA2[index] = cache_EMA2[index-1]
			cache_EMA3[index] = cache_EMA3[index-1]
			return nil
		end

		value = dValue(index, vType)	
		cache_EMA1[index]=k*value+(1-k)*cache_EMA1[index-1]
		cache_EMA2[index]=k*cache_EMA1[index]+(1-k)*cache_EMA2[index-1]
		cache_EMA3[index]=k*cache_EMA2[index]+(1-k)*cache_EMA3[index-1]
		
		out = 3*cache_EMA1[index] - 3*cache_EMA2[index] + cache_EMA3[index]
		
		return out
			
	end
end

function round(num, idp)
if idp and num then
   local mult = 10^(idp or 0)
   if num >= 0 then return math.floor(num * mult + 0.5) / mult
   else return math.ceil(num * mult - 0.5) / mult end
else return num end
end
