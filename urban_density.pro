pro urban_density
	
	nlon_g = 1440
        nlat_g = 720
        ratio_g = fltarr(nlon_g,nlat_g)
	no2_g_after=fltarr(nlon_g,nlat_g)
	no2_g_before=fltarr(nlon_g,nlat_g)
	;limit=[10,70,60,150]
	nlon = 320.0
	nlat = 200.0
	;mask is grids inside China's boundary
	mask = fltarr(nlon,nlat)
	no2_after=fltarr(nlon,nlat)
	no2_before=fltarr(nlon,nlat)
	ratio = fltarr(nlon,nlat)
	urbanpop=fltarr(nlon,nlat)
	totpop=fltarr(nlon,nlat)
	;region stands for 3 qu 9 qun
	region=fltarr(nlon,nlat)
	;pp is  grids which PP emissions account for >60%
	PP=fltarr(nlon,nlat)
	;pp_600 is grids with pp >=600 MW in 2011
	PP_600=fltarr(nlon,nlat)
	;array[ratio,urbanpop,totpop,region]
	array=fltarr(4,nlon,nlat)

	season='annual'
	year = 2012
	header = strarr(6,1)
	Yr4  = string(year,format='(i4.4)')
	filename ='/home/liufei/Data/Decline/no2_compare_'+Yr4+'_'+Season+'_0.25.asc'
	openr,lun,filename,/get_lun
	readf,lun,header,ratio_g
	close,/all
	free_lun,lun

        filename ='/home/liufei/Data/Decline/no2_'+Yr4+'_'+Season+'_average_0.25.asc'
        openr,lun,filename,/get_lun
        readf,lun,header,no2_g_after
        close,/all
        free_lun,lun

	Year4=string(year-1,format='(i4.4)')
        filename ='/home/liufei/Data/Decline/no2_'+Year4+'_'+Season+'_average_0.25.asc'
        openr,lun,filename,/get_lun
        readf,lun,header,no2_g_before
        close,/all
        free_lun,lun

	ratio=ratio_g[(70+180)/0.25:(70+180)/0.25+nlon-1,(90-60)/0.25:(90-60)/0.25+nlat-1]
	no2_after=no2_g_after[(70+180)/0.25:(70+180)/0.25+nlon-1,(90-60)/0.25:(90-60)/0.25+nlat-1]
	no2_before=no2_g_before[(70+180)/0.25:(70+180)/0.25+nlon-1,(90-60)/0.25:(90-60)/0.25+nlat-1]

        filename_mask = '/home/liufei/Data/Decline/Input/boundary_25.asc'
        openr,lun,filename_mask,/get_lun
        readf,lun,header,mask
        close,/all
        free_lun,lun

        filename_all = '/home/liufei/Data/Decline/Input/totalpop_25.asc'
        openr,lun,filename_all,/get_lun
        readf,lun,header,totpop
        close,/all
        free_lun,lun

	filename_urban = '/home/liufei/Data/Decline/Input/urbanpop_25.asc'
	openr,lun,filename_urban,/get_lun
        readf,lun,header,urbanpop
	close,/all
	free_lun,lun
	
	filename_region = '/home/liufei/Data/Decline/Input/regions_25.asc'
        openr,lun,filename_region,/get_lun
        readf,lun,header,region
        close,/all
        free_lun,lun

        filename_pp = '/home/liufei/Data/Decline/no2_compare_'+Yr4+'_'+Season+'_PP_0.25.asc'
        openr,lun,filename_pp,/get_lun
        readf,lun,header,pp
        close,/all
        free_lun,lun
	
	filename_region = '/home/liufei/Data/Decline/Input/pp_600_loc.asc'
        openr,lun,filename_region,/get_lun
        readf,lun,header,pp_600
        close,/all
        free_lun,lun

	after=0.0
	before=0.0
	pp_after=0.0
	pp_before=0.0
	pp_600_after=0.0
        pp_600_before=0.0
	totpop_after=0.0
	totpop_before=0.0
	urbanpop_after=0.0
	urbanpop_before=0.0
;	test_urban=fltarr(nlon,nlat)
;	test_tot=fltarr(nlon,nlat)
;	For I=0,nlon-1 do begin
;               For J=0,nlat-1 do begin
;			if (mask[I,J] gt 0.0) then begin
;				test_urban[I,J]=urbanpop[I,J]
;				test_tot[I,J]=totpop[I,J]
;			endif else begin
;				test_urban[I,J]=-999.0
;				test_tot[I,J]=-999.0
;			endelse
;		endfor
;	endfor
;	print,'China_urbanpop',total(test_urban[where (test_urban gt 0)])
;	print,'China_totalpop',total(test_tot[where (test_tot gt 0)])

	;array[ratio,urbanpop,totpop,regioni]
	;ratio file has exclude grids which NO2 column density < 1.0*10^15
	For I=0,nlon-1 do begin
		For J=0,nlat-1 do begin
			if (mask[I,J] gt 0.0) and (no2_after[I,J] gt 1.0) and (no2_before[I,J] gt 1.0) then begin
				after+=no2_after[I,J]
                                before+=no2_before[I,J]
				if  (pp[I,J] gt 0.0) then begin
					pp_after+=no2_after[I,J]
					pp_before+=no2_before[I,J]
				endif
				if  (pp_600[I,J] gt 0.0) then begin
                                        pp_600_after+=no2_after[I,J]
                                        pp_600_before+=no2_before[I,J]
                                endif
				if (totpop[I,J] gt 400000.0) then begin
					totpop_after+=no2_after[I,J]
					totpop_before+=no2_before[I,J]
				endif
				if (urbanpop[I,J] gt 200000.0) then begin
					urbanpop_after+=no2_after[I,J]
					urbanpop_before+=no2_before[I,J]
				endif
			endif

			if (mask[I,J] gt 0.0) and (pp[I,J] lt 0.0) then begin
				array[0,I,J]=ratio[I,J]
				array[1,I,J]=urbanpop[I,J]
				array[2,I,J]=totpop[I,J]
				array[3,I,J]=region[I,J]
			endif else begin
				array[*,I,J]=-999.0
				ratio[I,J]=-999.0			
			endelse
		endfor
	endfor	
	num=nlon*nlat
	array_new=fltarr(4,num)
	array_new=reform(array,4,num)
	test=array_new(2,*)
	print,'totpop',n_elements(where (test gt 0.0)),total(test[where (test gt 0.0)])
	outfile='/home/liufei/Data/Decline/no2_compare_'+Yr4+'_'+Season+'_Population_0.25.hdf'
	IF (HDF_EXISTS() eq 0) then message, 'HDF not supported'

	; Open the HDF file
	FID = HDF_SD_Start(Outfile,/RDWR,/Create)

	HDF_SETSD, FID, array_new, 'ratio_urbanpop_totpop_region', $
           FILL=-999.0

	HDF_SD_End, FID
	
	print,'sample number of grids which inside China boundary and not PP emissions',$
		n_elements(where (ratio gt 0.0))
;	print,'average of ratio',total(ratio[where (ratio gt 0.0)])/n_elements(where (ratio gt 0.0))
	print,'total 2012 column/2011 column',after/before	
	print,'pp 2012 column/2011 column',pp_after/pp_before	
	print,'pp_600 2012 column/2011 column',pp_600_after/pp_600_before
	print,'totpop_40 2012 column/2011 column',totpop_after/totpop_before
	print,'urbanpop_10 2012 column/2011 column',urbanpop_after/urbanpop_before
end	
