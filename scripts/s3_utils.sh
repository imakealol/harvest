#!/bin/sh

# 12/09/2020 (Argentino Trombin - Almaviva S.p.A)
# Modulo per il caricamento e lo scarico di files verso lo Storage S3 della BNCF


function check_download_integrity()
{

	file_to_download_to=$1
	file_to_download_to_md5=$2

	echo "Checking download integrity for " $file_to_download_to


	# Controllare che MD5 scaricato da S3 corrisonda ad MD5 generato dlocalmente dopo il download
	awk_command='
	    BEGIN    {
	        FS=" "; 
	    }
	 
	    FILENAME == ARGV[1] {
	        md5_AR[$1] = $1;
	        print "->S3    md5 " $1
	        next;
	    }
	    {
	    if ($1 in md5_AR)
	        {
	        print "->CHECK md5 " $1 " matches " 
	        next
	        }
	    else
	        {
	        print "CHECK md5 " $1 " DOES NOT match"
	        }
	    }' 

	# Create md5 checksum on downloaded file
	md5sum $file_to_download_to > $file_to_download_to_md5_check 

	# Check downloaded md5 against generated md5
	awk "$awk_command" $file_to_download_to_md5 $file_to_download_to_md5_check

} # end check_download_integrity








function dowbnload_warcs_from_s3()
{
	echo "--------------------------------"
	echo "Downloading warcs.gz from S3 storage"
	echo "warcs.gz will be downloaded with accociated .md5 file in same folder"

echo "TODO take in input download_dir (da dichiarare nei file di config) e s3_path_filename )"	


  #    while IFS='|' read -r -a array line
  #    do
  #          line=${array[0]}

  #         if [[ ${line:0:1} == "@" ]]; then # Ignore rest of file
  #           break
  #         fi

  #          # se riga comentata o vuota skip
  #          if [[ ${line:0:1} == "#" ]] || [[ ${line} == "" ]];  then
  #                continue
  #           fi

  #       local istituto=$(echo "${array[1]}" | cut -f 1 -d '.')
  #      	local warc_filename=$harvest_date_materiale"_"$istituto".warc.gz"
  #      	local file_to_download_to="/home/argentino/Downloads/"$warc_filename
  #      	local md5_file_to_download_to=$file_to_download_to".md5"
  #      	local s3_path_filename=""

		# if [ $ambiente == "sviluppo" ]; then
		# 	s3_path_filename="harvest/"$harvest_date_materiale"/sviluppo_"$warc_filename
		# elif [ $ambiente == "collaudo" ]; then 
		# 	s3_path_filename="harvest/"$harvest_date_materiale"/collaudo_"$warc_filename
		# elif [ $ambiente == "esercizio" ] || [ $ambiente == "nyovo_esercizio" ]; then
		# 	# Esercizio
		# 	s3_path_filename="harvest/"$harvest_date_materiale"/"$warc_filename
		# else
		# 		echo "ambiente '"$ambiente"' sconosciuto. STOP'"
		# 		return
		# fi

  #      	echo "istituto="$istituto
  #      	echo "ambiente="$ambiente
  #      	echo " warc_filename="$warc_filename
  #      	echo " harvest_date_materiale="$harvest_date_materiale
  #      	echo " file_to_download_to="$file_to_download_to
  #      	echo " md5_file_to_download_to="$md5_file_to_download_to
  #      	echo " s3_path_filename="$s3_path_filename


		# java -Damazons3.scanner.retrynumber=12 -Damazons3.scanner.maxwaittime=3 -Dcom.amazonaws.sdk.disableCertChecking \
		#     -cp "./bin/*" it.s3.s3clientMP.HighLevelMultipartUploadDownload \
		#     action=download \
		#     s3_keyname=$s3_path_filename \
		#     file_to_download_to=$file_to_download_to \


		# check_download_integrity $file_to_download_to $md5_file_to_download_to

  #    done < "$repositories_file"

} # End dowbnload_warcs_from_s3


function upload_warcs_to_s3()
{
	echo "--------------------------------"
	echo "Uploading warcs.gz to S3 storage"
	echo "warcs.gz must have accociated .md5 file in same folder"

     while IFS='|' read -r -a array line
     do
           line=${array[0]}

          if [[ ${line:0:1} == "@" ]]; then # Ignore rest of file
            break
          fi

           # se riga comentata o vuota skip
           if [[ ${line:0:1} == "#" ]] || [[ ${line} == "" ]];  then
                 continue
            fi

        local istituto=$(echo "${array[1]}" | cut -f 1 -d '.')

       	# file_to_upload=$warcs_dir"/"$harvest_date_materiale"_"$istituto".warc.gz"
       	local warc_filename=$harvest_date_materiale"_"$istituto".warc.gz"
       	local file_to_upload=$dest_warcs_dir"/"$warc_filename
       	local md5_file_to_upload=$file_to_upload".md5"
       	local s3_path_filename=""

       	echo "istituto="$istituto
       	echo "ambiente="$ambiente
       	echo " warc_filename="$warc_filename
       	echo " harvest_date_materiale="$harvest_date_materiale
       	echo " file_to_upload="$file_to_upload
       	echo " md5_file_to_upload="$md5_file_to_upload


		if [ $ambiente == "sviluppo" ]; then
			s3_path_filename="harvest/"$harvest_date_materiale"/warcs/sviluppo_"$warc_filename
		elif [ $ambiente == "collaudo" ]; then 
			s3_path_filename="harvest/"$harvest_date_materiale"/warcs/collaudo_"$warc_filename
		elif [ $ambiente == "esercizio" ] || [ $ambiente == "nuovo_esercizio" ]; then
			# Esercizio
			s3_path_filename="harvest/"$harvest_date_materiale"/warcs/"$warc_filename
		else
				echo "ambiente '"$ambiente"' sconosciuto. STOP'"
				exit
		fi

       	echo " s3_path_filename="$s3_path_filename




       	# Check if files to upload exist
	    if [ ! -f $file_to_upload ]; then
	        "Missing file to upload: "$file_to_upload" SKIPPING ...."
	        continue;
	    fi
	    if [ ! -f $md5_file_to_upload ]; then
	        "Missing md5 file to upload: "$md5_file_to_upload" SKIPPING ...."
	        continue;
	    fi

	    s3log_filename=$s3_dir"/"$harvest_date_materiale"."$istituto".upload.log"
echo "s3log_filename = " $s3log_filename

		java -Damazons3.scanner.retrynumber=12 -Damazons3.scanner.maxwaittime=3 -Dcom.amazonaws.sdk.disableCertChecking \
		    -cp "./bin/*" it.s3.s3clientMP.HighLevelMultipartUploadDownload \
		    action=upload \
		    file_to_upload=$file_to_upload \
		    s3_keyname=$s3_path_filename  > $s3log_filename



     done < "$repositories_file"
} # End  upload_warcs_to_s3





function upload_split_warcs_to_s3()
{

	echo "--------------------------------"
	echo "Uploading split warcs.gz to S3 storage"
	echo "warcs.gz must have accociated .md5 file in same folder"


	split_warcs_dir=$dest_warcs_dir"/split_dir"

	echo "split_warcs_dir="$split_warcs_dir

    for filename in $split_warcs_dir/*.gz.??; do
        if [ -s "$filename" ]
        then
# echo "filename="$filename
            # fname= basename $filename .seeds
            fname=$(basename -- "$filename")
            # extension="${fname##*.}"
            # fname="${fname%.*}"
# echo "------>fname="$fname

       	local warc_filename=$fname
       	local file_to_upload=$filename
       	local md5_file_to_upload=$file_to_upload".md5"
       	local s3_path_filename=""

		if [ $ambiente == "sviluppo" ]; then
			s3_path_filename="harvest/"$harvest_date_materiale"/warcs/sviluppo_"$warc_filename
		elif [ $ambiente == "collaudo" ]; then 
			s3_path_filename="harvest/"$harvest_date_materiale"/warcs/collaudo_"$warc_filename
		elif [ $ambiente == "esercizio" ] || [ $ambiente == "nuovo_esercizio" ]; then
			# Esercizio
			s3_path_filename="harvest/"$harvest_date_materiale"/warcs/"$warc_filename
		else
				echo "ambiente '"$ambiente"' sconosciuto. STOP'"
				exit
		fi

# echo "warc_filename="$warc_filename
# echo "file_to_upload="$file_to_upload
# echo "md5_file_to_upload="$md5_file_to_upload
echo " s3_path_filename="$s3_path_filename


	    if [ ! -f $md5_file_to_upload ]; then
	        # "Missing md5 file to upload: "$md5_file_to_upload" SKIPPING ...."
	        # continue;

	        echo "create md5 for:" $warc_filename
	        md5sum $file_to_upload > $md5_file_to_upload

	    fi

	    s3log_filename=$s3_dir"/"$warc_filename".upload.log"
echo "s3log_filename = " $s3log_filename


		java -Damazons3.scanner.retrynumber=12 -Damazons3.scanner.maxwaittime=3 -Dcom.amazonaws.sdk.disableCertChecking \
		    -cp "./bin/*" it.s3.s3clientMP.HighLevelMultipartUploadDownload \
		    action=upload \
		    file_to_upload=$file_to_upload \
		    md5_file_to_upload=$md5_file_to_upload \
		    s3_keyname=$s3_path_filename  > $s3log_filename

        else
        	echo "$filename is empty."
                # do something as file is empty
        fi
    done


} # End  upload_split_warcs_to_s3



function prepare_etd_warcs_list_to_upload()
{

find /mnt/volume2/warcs/etd/ -name *.gz > /mnt/volume2/warcs/etd_warcs.lst
sed '/recover.gz/d' /mnt/volume2/warcs/etd_warcs.lst > /mnt/volume2/warcs/etd_warcs.lst.clean

}


function upload_etd_warcs_to_S3()
{
	declare -i from_line=$1
	declare -i to_line=$2

	multipart_mode=$3


	echo "--------------------------------"
	echo "Uploading etd warcs.gz to S3 storage (harvests up to 10/2018)"
	



echo "Upload to S3 from line: "$from_line
echo "Upload to S3 to line: "$to_line

     # while IFS='|' read -r -a array line
    declare -i line_ctr=0; 
	while IFS= read -r line
    	do
    	
    	line_ctr=$((line_ctr+1))

    	if [ $line_ctr -lt  $from_line ]; then
    		continue;
    	fi

    	if [ $line_ctr -gt  $to_line ]; then
    		break;
    	fi




		if [[ ${line:0:1} == "@" ]]; then # Ignore rest of file
		break
		fi

		# se riga comentata o vuota skip
		if [[ ${line:0:1} == "#" ]] || [[ ${line} == "" ]];  then
		     continue
		fi

echo "line: "$line_ctr " --> "$line

base_name=$(basename -- "$line")

# echo "base_name: "$base_name

		filename=${line/\/mnt\/volume2\/warcs\//}
		# echo "filename="$filename
     	# local warc_filename=/mnt/volume2/warcs/etd/
       	local file_to_upload=$line
       	local md5_file_to_upload="tmp/"$base_name".md5"
       	local s3_path="harvest/warcs/"
      	local s3_path_filename=$s3_path$filename
# echo "file_to_upload: "$file_to_upload
# echo "md5_file_to_upload: "$md5_file_to_upload
# echo "s3_path_filename: "$s3_path_filename
       	# Check if files to upload exist
	    if [ ! -f $file_to_upload ]; then
	        "Missing file to upload: "$file_to_upload" SKIPPING ...."
	        continue;
	    fi



	    if [ ! -f $md5_file_to_upload ]; then
	        echo "create md5 :" $md5_file_to_upload
	        md5sum $file_to_upload > $md5_file_to_upload
	    fi

		# per avere il percorso completo sostituiamo lo / con _
		log_fname="${line//\//_}" 
	    s3log_filename=$s3_dir"/"$log_fname".upload.log"

# echo "s3log_filename = " $s3log_filename

	if [ $multipart_mode == "true" ]; then
		echo "Upload im multi part mode: "
		java -Damazons3.scanner.retrynumber=12 -Damazons3.scanner.maxwaittime=3 -Dcom.amazonaws.sdk.disableCertChecking \
		    -cp "./bin/*" it.s3.s3clientMP.HighLevelMultipartUploadDownload \
		    action=upload \
		    file_to_upload=$file_to_upload \
		    md5_file_to_upload=$md5_file_to_upload \
		    s3_keyname=$s3_path_filename  > $s3log_filename

	else
		echo "Upload im single part mode: "
		java -Damazons3.scanner.retrynumber=12 -Damazons3.scanner.maxwaittime=3 -Dcom.amazonaws.sdk.disableCertChecking \
		    -cp "./bin/*" it.s3.s3client.S3Client \
		    action=upload \
		    file_to_upload=$file_to_upload \
		    md5_file_to_upload=$md5_file_to_upload \
		    s3_keyname=$s3_path_filename  > $s3log_filename

	fi

     done < /mnt/volume2/warcs/etd_warcs.lst.clean

} # End upload_etd_warcs_to_S3


function prepare_s3_record()
{
	s3log_filename=$1
	s3_upd_ins=$2

grep -E -- '^file size|^Inizio|^Finito|^Object upload started|S3 info on|^Tempo impiegato' $s3log_filename  |  
awk -v split_warc="$split_warc" 'BEGIN{
    FS=" ";
    size_bytes="ND";
    size_mega="ND";
    size_giga="ND";
    data_inizio=""
    ora_inizio=""
    data_fine=""
    ora_fine=""
    nome_file=""
    file_da_caricare=""
    nome_file_s3=""
    tempo_caricamento=""
    }
    {
    	if ($2 == "size")
    		{
			size_bytes = substr($6,0,length($6)-1)
			size_mega = substr($7,0,length($7)-1)
			size_giga = $8
    		}
    	else if ($1 == "Inizio:")
    		{
    		gsub("/","-",$2)
    		data_inizio = $2
    		ora_inizio = $3
    		}
    	else if ($2 == "upload")
        		{
        		file_da_caricare = $5
        		n=split($5,A,"/"); 
        		nome_file = A[n]
        		}
    	else if ($1 == "Finito")
    		{
    		gsub("/","-",$3)
    		data_fine = $3
    		ora_fine = $4
    		}
    	else if ($1 == "Tempo")
    		{
    		tempo_caricamento = $6
    		}
    	else if ($1 == "S3")
    		{
    		nome_file_s3 = substr($4, 2, length($4) - 2)
    		}
    	else
    		{
            print $0;
    		}
    }
    END{

	if (nome_file_s3 == "")
		{
		nome_file_s3 = file_da_caricare
		sub("/mnt/volume2/", "harvest/", nome_file_s3 )
		}

	if (size_bytes == "ND")
		{
			# d=system("date")
			# print "date: " d >> "/dev/stderr" 

			# c = "stat -c %s " "/home/argentino/magazzini_digitali/harvest/tmp.txt";
			c = "stat -c %s " file_da_caricare
	        c |getline size;
	        # print "size=" size >> "/dev/stderr" ;
	        close( c );

	        size_bytes = size"(B)"

			mega = size/(1048576)
			size_mega=""
			size_mega =  sprintf (size_mega "%0.3f(MB)", mega)


			giga = size/(1073741824)
			size_giga=""
			size_giga =  sprintf (size_giga "%0.3f(GB)", giga)





			# print "-->get file size" >> "/dev/stderr" 

		}


    	# print "nome_file="nome_file	 >> "/dev/stderr"
    	# print "nome_file_md5="nome_file".md5"	 >> "/dev/stderr"
    	# print "nome_file_s3="nome_file_s3	 >> "/dev/stderr"
    	# print "nome file completo="file_da_caricare	 >> "/dev/stderr"
    	# print "split_warc="split_warc	 >> "/dev/stderr"
		# print "size_bytes=" size_bytes	 >> "/dev/stderr"
		# print "size_mega=" size_mega	 >> "/dev/stderr"
		# print "size_giga=" size_giga	 >> "/dev/stderr"
    	# print "data_inizio=" data_inizio " " ora_inizio	 >> "/dev/stderr"
    	# print "data_fine=" data_fine " " ora_fine	 >> "/dev/stderr"
    	# print "tempo_caricamento="tempo_caricamento	 >> "/dev/stderr"



# /mnt/volume2/warcs/etd/20131024-depositolegale/warcs/etd-20131028071735547-00000-28409~f1.depositolegale.it~8443.warc.gz
# /harvest/warcs/etd/20131024-depositolegale/warcs/etd-20131028071735547-00000-28409~f1.depositolegale.it~8443.warc.gz

print nome_file"|"nome_file".md5|"nome_file_s3"|"file_da_caricare"|"split_warc"|"size_bytes"|"size_mega"|"size_giga"|"data_inizio " " ora_inizio"|"data_fine " " ora_fine"|"tempo_caricamento


	                }' >> $s3_upd_ins
} # end prepare_s3_record()


# 20/10/2020
function prepare_harvest_record_AV()
{

# grep -E -- '^file size|^Inizio|^Finito|^Object upload started|S3 info on|^Tempo impiegato' 2020_08_05_tesi.unimib.upload.log

	echo "--------------------------------"
	echo "prepare_harvest_record_AV"

	s3_upd_ins=$s3_dir"/storageS3.upd_ins" 

	
    if [ -f $s3_upd_ins ]; then
        rm $s3_upd_ins
    fi

    touch $s3_upd_ins # Create file


     while IFS='|' read -r -a array line
     do
           line=${array[0]}

           # Remove whitespaces (empty lines)
    	   line=`echo $line | xargs`
 
          if [[ ${line:0:1} == "@" ]]; then # Ignore rest of file
            break
          fi

           # se riga comentata o vuota skip
           if [[ ${line:0:1} == "#" ]] || [[ ${line} == "" ]];  then
                 continue
            fi

        local istituto=$(echo "${array[1]}" | cut -f 1 -d '.')

       	# echo "istituto="$istituto

	    s3log_filename=$s3_dir"/"$harvest_date_materiale"."$istituto".upload.log"
	    s3log_split_filename_prefix=$s3_dir"/"$harvest_date_materiale"_"$istituto"*"
		
		# echo "s3log_filename = " $s3log_filename
		# echo "s3log_split_filename_prefix = " $s3log_split_filename_prefix

		# Cerchiamo se l'iistituto ha dei warc spl;ittati
		
		# declare -i log_files=$(ls -l $s3log_split_filename_prefix | wc -l )

		# echo "log_files per "$s3log_split_filename_prefix" sono "$log_files

		# Test if file with wildcard exists!!!
		if ls $s3log_split_filename_prefix 1> /dev/null 2>&1; then
			# echo "files do exist"
	        split_warc=si
	        
		    # Cicliamo sui log dei warc (splittati o no)
			for filename in $s3log_split_filename_prefix; do
			    echo "Working on "$filename
		        prepare_s3_record $filename $s3_upd_ins

				# grep -E -- '^file size|^Inizio|^Finito|^Object upload started|S3 info on|^Tempo impiegato' $filename > $filename".1"
			done

		else
	    	# echo "Abbiamo il log di un file non _splittato? "$s3log_filename 
		    if [ ! -f $s3log_filename ]; then
		        "Missing log file: "$s3log_filename" SKIPPING ...."
		        continue;
		    else
			    echo "Working on "$s3log_filename
		        split_warc=no

		        prepare_s3_record $s3log_filename $s3_upd_ins

		    fi

		fi


     done < "$repositories_file"
} # end prepare_harvest_record_AV



# 21/10/2020
function prepare_harvest_record_storico()
{

# grep -E -- '^file size|^Inizio|^Finito|^Object upload started|S3 info on|^Tempo impiegato' 2020_08_05_tesi.unimib.upload.log
	from=$1
	to=$2


	echo "--------------------------------"
	echo "prepare_harvest_record_storico"

	s3_lst_storico=$s3_dir"/storico/etd_warcs.lst.storico"
	s3_upd_ins=$s3_dir"/storageS3.upd_ins" 

	
    if [ -f $s3_upd_ins ]; then
        rm $s3_upd_ins
    fi

    touch $s3_upd_ins # Create file

    ctr=0
     while IFS='|' read -r -a array line
     do
       line=${array[0]}
		let "ctr=ctr+1" 

echo "Line ctr=" $ctr


	    if [[ $ctr < $from ]]; then
	    	continue
	    fi


       # Remove whitespaces (empty lines)
	   line=`echo $line | xargs`

      if [[ ${line:0:1} == "@" ]]; then # Ignore rest of file
        break
      fi

       # se riga comentata o vuota skip
       if [[ ${line:0:1} == "#" ]] || [[ ${line} == "" ]];  then
             continue
       fi

       # echo "LOG="$line


		# replace all / with _
		s3log_filename=$s3_dir"/storico/all/"${line//\//_}".upload.log"
		# echo "s3log_filename="$s3log_filename


	    echo "Working on "$s3log_filename
        split_warc=no
        prepare_s3_record $s3log_filename $s3_upd_ins


	    if [[ $ctr > $to ]]; then
	    	return
	    fi


     done < $s3_lst_storico
} # end prepare_harvest_record_storico


