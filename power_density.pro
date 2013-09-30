pro power_density
	
	nlon_g = 1440
        nlat_g = 720
        no2_g = fltarr(nlon_g,nlat_g)
	;limit=[10,70,60,150]
	nlon = 320
	nlat = 200
	no2 = fltarr(nlon,nlat)
	;no2_1 is grid with pp emission accounts for >0.6
	no2_1=fltarr(nlon,nlat)
	;no2_2 is grid with pp >=600MW in 2011
	no2_2=fltarr(nlon,nlat)
	;nox is 2010 total NO2 emssion from MEIC
	nox=fltarr(nlon,nlat)
	nox_power= fltarr(nlon,nlat)
	pp_LOC=fltarr(nlon,nlat)

	season='annual'
	year = 2012
	header = strarr(6,1)
	Yr4  = string(year,format='(i4.4)')
	filename ='/home/liufei/Data/Decline/no2_compare_'+Yr4+'_'+Season+'_0.25.asc'
	openr,lun,filename,/get_lun
	readf,lun,header,no2_g
	close,/all
	free_lun,lun
	no2=no2_g[(70+180)/0.25:(70+180)/0.25+nlon-1,(90-60)/0.25:(90-60)/0.25+nlat-1]

	;Emissions from power plants account for >60% emssions in 2010
        filename_all = '/home/liufei/Data/Decline/Input/2010__all__NOx_25.asc'
        header2 = strarr(6,1)
        openr,lun,filename_all,/get_lun
        readf,lun,header2,nox
        close,/all
        free_lun,lun

	filename_power = '/home/liufei/Data/Decline/Input/2010__power__NOx_25.asc'
	header2 = strarr(6,1)
	openr,lun,filename_power,/get_lun
        readf,lun,header2,nox_power
	close,/all
	free_lun,lun

	For I=0,nlon-1 do begin
		For J=0,nlat-1 do begin
			if (nox[I,J] gt 0.0) and (nox_power[I,J]/nox[I,J] gt 0.6) then begin
				no2_1[I,J]=no2[I,J]
			endif else begin
				no2_1[I,J]=-999.0
			endelse
		endfor
	endfor			
	
	header_output = [['ncols '+string(nlon)],['nrows '+string(nlat)],['xllcorner 70'],['yllcorner 10'],['cellsize 0.25'],['nodata_value -999.0']]
	outfile='/home/liufei/Data/Decline/no2_compare_'+Yr4+'_'+Season+'_PP_0.25.asc'
	openw,lun,outfile,/get_lun
	printf,lun,header_output,no2_1
	close,/all
	free_lun,lun

	print,'number of grids which PP emissions account for >60%',n_elements(where (no2_1 gt 0.0))	
	print,'average of no2_1',total(no2_1[where (no2_1 gt 0.0)])/n_elements(where (no2_1 gt 0.0))
	;outfile='/home/liufei/Data/Decline/test.asc'
	;openw,lun,outfile,/get_lun
        ;printf,lun,header_output,no2
        ;close,lun
	
	;Grids with power plants >=600 MW in 2011
	filename_LOC = '/home/liufei/Data/Decline/Input/pp_600_loc.asc'
        header2 = strarr(6,1)
        openr,lun,filename_LOC,/get_lun
        readf,lun,header2,PP_Loc
        close,/all
        free_lun,lun
	
	For I=0,nlon-1 do begin
                For J=0,nlat-1 do begin
                        if (PP_Loc[I,J] gt 0.0)  then begin
                                no2_2[I,J]=no2[I,J]
                        endif else begin
                                no2_2[I,J]=-999.0
                        endelse
                endfor
        endfor
	print,'average of no2_2',total(no2_2[where (no2_2 gt 0.0)])/n_elements(where (no2_2 gt 0.0))
	
	end	
