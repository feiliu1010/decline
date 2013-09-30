pro regrid_KNMI_L3_25X25
;input data
nlon_g=2880
nlat_g=1440
;global density
global = fltarr(nlon_g,nlat_g)
start_year=2011
nyear=2
;output data,0.25X0.25
nlon = 1440
nlat = 720
global_2 = fltarr(nlon,nlat)
no2_list= fltarr(nlon,nlat,nyear)

season='annual'
For year = start_year, start_year+nyear-1 do begin
	Yr4  = string(year,format='(i4.4)')
	filename='/home/liufei/Data/Decline/no2_'+Yr4+'_'+Season+'_average_0.125.asc'
	header = strarr(6,1)
	openr,lun,filename,/get_lun
	readf,lun,header,global
	close,/all
	free_lun,lun

	xj=0
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
		a=Temporary(sub)
		aa=Temporary(loc)
		xi = xi+1
		I = I+1
	    endfor
            J=J+1
	    xj=xj+1
	endfor
	
	no2_list[*,*,year-start_year]=global_2
	print,'mean of global',mean(global[where (global ge 0.0)])
	print,'number of global',N_elements(global[where (global ge 0.0)])
	print,'mean of global2',mean(global_2[where (global_2 ge 0.0)] )
	print,'number of global2',N_elements(global_2[where (global_2 ge 0.0)])

	outfile = '/home/liufei/Data/Decline/no2_'+Yr4+'_'+Season+'_average_0.25.asc'
	header_output =[ ['ncols 1440'],['nrows  720'],['xllcorner -180'],['yllcorner -90'],['cellsize 0.25'],['nodata_value -999.0']]
	openw,lun,outfile,/get_lun
	printf,lun,header_output
	printf,lun,global_2
	close,/all
	free_lun,lun
endfor

no2_com= fltarr(nlon,nlat)
for I = 0,nlon-1 do begin
        for J = 0,nlat-1 do begin
                if (no2_list[I,J,0] gt 1L) and (no2_list[I,J,1] gt 1L) then begin
                        no2_com[I,J]=no2_list[I,J,1]/no2_list[I,J,0]
                endif else begin
                        no2_com[I,J]=-999.0
                endelse
        endfor
endfor
outfile='/home/liufei/Data/Decline/no2_compare_'+Yr4+'_'+Season+'_0.25.asc'
header_output =[ ['ncols '+string(nlon)],['nrows '+string(nlat)],['xllcorner -180'],['yllcorner -90'],['cellsize 0.25'],['nodata_value -999.0']]
openw,lun,outfile,/get_lun
printf,lun,header_output
printf,lun,no2_com
close,/all
free_lun,lun
end
