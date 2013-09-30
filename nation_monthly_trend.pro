pro nation_monthly_trend
;input data
nlon_g=2880/2
nlat_g=1440/2
cellsize=0.25
;global density
global = fltarr(nlon_g,nlat_g)

limit=[10,70,60,150]

;select where pp control grids
;pp='yes'
pp='no'
case pp of 
'yes':pp_option=1
'no':pp_option=0
endcase
;select where urban control grids
urban='yes'
;urban='no'
case urban of 
'yes':urban_option=1
'no':urban_option=0
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

endyear=2012
endYr4=string(endyear,format='(i4.4)')
season='annual'

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

	loc= where(no2 le 1)
	if not array_equal(loc,[-1]) then begin
		no2[loc]=-999.0
	endif

        if flag  then begin
        ;m is used fod counting the total number of months
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
;mask China boundary
mask=fltarr (nlon,nlat)
header = strarr(6,1)
filename='/home/liufei/Data/Decline/Input/boundary_25.asc'
openr,lun,filename,/get_lun
readf,lun,header,mask
mask_3d=fltarr (nlon,nlat,m)
For i=0,m-1 do begin
        mask_3d[*,*,i]=mask
endfor
area_data[where(mask_3d ne -9999)]=-999.0
undefine,mask_3d


;mask pp control grids
if pp_option then begin
	mask=fltarr (nlon,nlat)
	header = strarr(6,1)
	filename='/home/liufei/Data/Decline/no2_compare_'+endYr4+'_'+Season+'_PP_0.25.asc'
	openr,lun,filename,/get_lun
	readf,lun,header,mask
	mask_3d=fltarr (nlon,nlat,m)
	For i=0,m-1 do begin
        	mask_3d[*,*,i]=mask
	endfor
	area_data[where(mask_3d lt 0.0)]=-999.0
	undefine,mask_3d
endif
;mask urban control grids
if urban_option then begin
        mask=fltarr (nlon,nlat)
        header = strarr(6,1)
        filename='/home/liufei/Data/Decline/Input/urbanpop_25.asc'
        openr,lun,filename,/get_lun
        readf,lun,header,mask
	mask[where(mask le 200000)]=-999.0
        ;exclude pp_control grids
        mask_pp=fltarr (nlon,nlat)
        header = strarr(6,1)
        filename='/home/liufei/Data/Decline/no2_compare_'+endYr4+'_'+Season+'_PP_0.25.asc'
        openr,lun,filename,/get_lun
        readf,lun,header,mask_pp
	mask[where(mask_pp gt 0.0)]=-999.0

	mask_3d=fltarr (nlon,nlat,m)
        For i=0,m-1 do begin
                mask_3d[*,*,i]=mask
        endfor
        area_data[where(mask_3d lt 0.0)]=-999.0
        undefine,mask_3d
endif

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
        xtitle='number of months',ytitle='no2/(10^15moles/cm2)'
image = tvrd(true =1)
write_jpeg,'monthly_trend.jpg',image,true=1
end

