pro area_monthly_trend
;input data
nlon_g=2880/2
nlat_g=1440/2
cellsize=0.25
;global density
global = fltarr(nlon_g,nlat_g)

;area density
area='CEC_extend'
;area='Sichuan'
;area='PRD'
case area of 
'CEC_extend':limit = [30,110,40,123]
'Ningxia':limit = [36,103,40,107.5]
'Sichuan':limit = [25,102.25,31.75,107.75]
'Changsha':limit= [27.25,111.5,30,113.75]
'PRD':limit = [21.5,112,24,114.75]
'nation':limit=[10,70,60,150]
endcase


start_lon=limit[1]
end_lon=limit[3]
start_lat=limit[0]
end_lat=limit[2]

nlon =(end_lon-start_lon)/cellsize
nlat =(end_lat-start_lat)/cellsize
no2 = fltarr(nlon,nlat)
;star point of grid for area in global map
slon = (start_lon+180)/cellsize
slat = (90-end_lat)/cellsize

flag = 0U
For year = 2010, 2013 do begin
For month = 1,12 do begin

        Yr4  = string(year,format='(i4.4)')
        Mon2 = string(month,format='(i2.2)')
        nymd = year * 10000L + month * 100L + 1 * 1L
        if nymd eq 20040101 then continue
        if nymd eq 20040201 then continue
        if nymd eq 20040301 then continue
        if nymd eq 20040401 then continue
        if nymd eq 20040501 then continue
        if nymd eq 20040601 then continue
        if nymd eq 20040701 then continue
        if nymd eq 20040801 then continue
        if nymd eq 20040901 then continue

        if nymd eq 20130601 then continue
        if nymd eq 20130701 then continue
        if nymd eq 20130801 then continue
        if nymd eq 20130901 then continue
        if nymd eq 20131001 then continue
        if nymd eq 20131101 then continue
        if nymd eq 20131201 then continue

        header = strarr(6,1)
	filename='/home/liufei/Data/Satellite/NO2/OMI/no2_'+Yr4+Mon2+'_0.25x0.25.asc'
        openr,lun,filename,/get_lun
        readf,lun,header,global
        no2 = global[slon:slon+nlon-1,slat:slat+nlat-1]/100
	;exclude data <1*10^15
	loc=where(no2 le 1)
	if not array_equal(loc,[-1]) then begin
		no2[where(no2 le 1)]=-999.0
	endif

        if flag  then begin
        ;m is ddused foddr counting the total number of months
        m = m+1
        ;define no2_month to save no2 for all months
        no2_month =[ [no2_month],[no2] ]
        endif else begin
        m = 1U
        no2_month = no2
        flag = 1U
        endelse
        ;print,Yr4,Mon2
        close,/all

endfor
endfor
print,'m',m
print,'size of no2_month',size(no2_month)


;convert no2_month to 3-D array no2_data
no2_data =fltarr (nlon,nlat,m)
For num = 0,m-1 do begin
        no2_data[*,*,num] = no2_month[0:nlon-1,nlat*num:nlat*(num+1)-1]
endfor
;find no2_data with reasonable value( filter value < 0)
loc = where(no2_data lt 0)
if not array_equal(loc,[-1]) then begin
        no2_data[loc] = -999.0
endif
undefine,loc

area_data=fltarr (nlon,nlat,m)
area_data=no2_data
;calculate long-term avearage
Y=fltarr(m,1)
valid_num=fltarr(m,1)
For num = 0,m-1 do begin
        For J = 0,nlat-1 do begin
                FOR I = 0,nlon-1 do begin
                        if area_data[I,J,num] gt -999.0 then begin
                                Y[num]+=area_data[I,J,num]
                                valid_num[num]+=1
                        endif
                endfor
        endfor
endfor
Y=Y/valid_num
x=indgen(m)+1
print,'Y:',Y
plot,x,y,psym=2,$
        yrange=[min(y),max(y)],$
        title='area:'+string(area),xtitle='number of months',ytitle='no2/(10^15moles/cm2)'
image = tvrd(true =1)
write_jpeg,'monthly_trend_'+string(area)+'.jpg',image,true=1
end

