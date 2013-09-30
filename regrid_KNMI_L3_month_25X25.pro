pro regrid_KNMI_L3_month_25X25
;input data
nlon_g=1440*2
nlat_g=720*2
;global density
global = fltarr(nlon_g,nlat_g)

;output data,0.25X0.25
nlon = 720*2
nlat = 360*2
global_2 = fltarr(nlon,nlat)

flag = 0U
flag2 = 0U
For year = 2011, 2013 do begin
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


header = strarr(7,1)
filename = '/z6/satellite/OMI/no2/KNMI_L3_v2/no2_'+Yr4+Mon2+'.grd'
openr,lun,filename,/get_lun
readf,lun,header,global
close,/all
free_lun,lun


xj=0
;************omi
For J=0,nlat_g-2 do begin
xi=0
For I=0,nlon_g-2 do begin
sub = global[I:I+1,J:J+1]
loc = where(sub ge 0.0)
if Array_equal(loc,[-1]) then begin
global_2[xi,xj]= -999.0
endif else begin
global_2[xi,xj]=mean( sub[loc])
endelse
undefine,sub
undefine,loc
xi = xi+1
I = I+1
endfor
J=J+1
xj=xj+1
endfor

print,nymd,'mean of global',mean(global[where (global ge 0.0)])
print,nymd,'number of global',N_elements(global[where (global ge 0.0)])
print,nymd,'mean of global2',mean(global_2[where (global_2 ge 0.0)] )
print,nymd,'number of global2',N_elements(global_2[where (global_2 ge 0.0)])

outfile = '/home/liufei/Data/Satellite/NO2/OMI/no2_'+Yr4+Mon2+'_0.25x0.25.asc'
header_output =[ ['ncols 1440'],['nrows  720'],['xllcorner -180'],['yllcorner -90'],['cellsize 0.25'],['nodata_value -999.0']]
openw,lun,outfile,/get_lun
printf,lun,header_output
printf,lun,global_2
close,/all
free_lun,lun
endfor
endfor

end
