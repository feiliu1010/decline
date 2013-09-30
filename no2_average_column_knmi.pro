pro no2_average_column_knmi

nlon_g=2880
nlat_g=1440
start_year=2011
nyear=2
no2_list= fltarr(nlon_g,nlat_g,nyear)
season='annual'
case season of
	'Jun2Agu':m=[6,7,8]
	'annual':m=[1,2,3,4,5,6,7,8,9,10,11,12]
endcase

For year = start_year, start_year+nyear-1 do begin
    no2= fltarr(nlon_g,nlat_g)
    num= fltarr(nlon_g,nlat_g)
    For month = m[0],m[n_elements(m)-1] do begin
	global = fltarr(nlon_g,nlat_g)
	Yr4  = string(year,format='(i4.4)')
	Mon2 = string(month,format='(i2.2)')
	nymd=year * 10000L + month * 100L + 1 * 1L
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

	for I = 0,nlon_g-1 do begin
	  for J = 0,nlat_g-1 do begin
	    if (global[I,J] gt 0) then begin
	       no2[I,J] += global[I,J] 
	       num[I,J] += 1
	    endif
	  endfor
	endfor

    endfor


    for I = 0,nlon_g-1 do begin
	  for J = 0,nlat_g-1 do begin
	    if (num[I,J] gt 0L) then begin            
	    	no2[I,J] /= (num[I,J]*100)          
	    endif else begin
		 no2[I,J] = -999.0
	    endelse
	  endfor
    endfor
    
    no2_list[*,*,year-start_year]=no2

    outfile='/home/liufei/Data/Decline/no2_'+Yr4+'_'+Season+'_average_0.125.asc'
    header_output =[ ['ncols '+string(nlon_g)],['nrows '+string(nlat_g)],['xllcorner -180'],['yllcorner -90'],['cellsize 0.125'],['nodata_value -999.0']]
    openw,lun,outfile,/get_lun
    printf,lun,header_output
    printf,lun,no2
    close,/all
    free_lun,lun
endfor

no2_com= fltarr(nlon_g,nlat_g)	
for I = 0,nlon_g-1 do begin
	for J = 0,nlat_g-1 do begin
		if (no2_list[I,J,0] gt 1L) and (no2_list[I,J,1] gt 1L) then begin
			no2_com[I,J]=no2_list[I,J,1]/no2_list[I,J,0]
		endif else begin
			no2_com[I,J]=-999.0
		endelse
	endfor
endfor
outfile='/home/liufei/Data/Decline/no2_compare_'+Yr4+'_'+Season+'_0.125.asc'
header_output =[ ['ncols '+string(nlon_g)],['nrows '+string(nlat_g)],['xllcorner -180'],['yllcorner -90'],['cellsize 0.125'],['nodata_value -999.0']]
openw,lun,outfile,/get_lun
printf,lun,header_output
printf,lun,no2_com
close,/all
free_lun,lun

end
